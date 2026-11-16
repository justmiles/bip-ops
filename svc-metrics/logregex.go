package main

import (
	"bufio"
	"fmt"
	"io"
	"log/slog"
	"os"
	"regexp"
	"sort"
	"strings"
	"sync"
)

type logregexStrategy struct {
	logFile      string
	joinRegex    *regexp.Regexp
	leaveRegex   *regexp.Regexp
	ready        *ReadyConfig
	readyPattern *regexp.Regexp

	mu          sync.Mutex
	players     map[string]int // internal key -> display index (0-based)
	nextIdx     int
	serverReady bool
}

func newLogregexStrategy(logFile, joinPattern, leavePattern string, ready *ReadyConfig) Strategy {
	s := &logregexStrategy{
		logFile: logFile,
		players: make(map[string]int),
		ready:   ready,
	}
	if joinPattern != "" {
		s.joinRegex = regexp.MustCompile(joinPattern)
	}
	if leavePattern != "" {
		s.leaveRegex = regexp.MustCompile(leavePattern)
	}
	if ready != nil && ready.LogPattern != "" {
		s.readyPattern = regexp.MustCompile(ready.LogPattern)
	}

	go s.tailLog()
	return s
}

func (s *logregexStrategy) Name() string { return "logregex" }

func (s *logregexStrategy) Collect() (Sample, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Report "Player N" labels instead of raw identifiers (which may be Steam IDs
	// or other internal keys that shouldn't be surfaced in the UI).
	labels := make([]string, 0, len(s.players))
	for _, idx := range s.players {
		labels = append(labels, fmt.Sprintf("Player %d", idx+1))
	}
	sort.Strings(labels)
	return Sample{
		ActivePlayerCount: len(s.players),
		PlayerNames:       labels,
		ServerReady:       s.serverReady,
	}, nil
}

// tailLog follows the log file, reopening it when it is rotated or briefly
// disappears. Retries on open failure (file may not exist yet during boot).
func (s *logregexStrategy) tailLog() {
	for {
		if err := s.streamLog(); err != nil {
			slog.Debug("logregex: stream ended, retrying", "error", err)
		}
		// Wait before retry; avoids a tight loop when the file is absent.
		waitForFile(s.logFile, 5)
	}
}

// streamLog reads the log from the beginning, then follows appended lines,
// polling on EOF. Reading from the start (rather than seeking to the end)
// reconstructs the current player set and catches the readiness line even if the
// server became ready before svc-metrics attached. bufio.Scanner cannot follow a
// growing file, so we poll with a bufio.Reader and accumulate partial lines.
// Returns so tailLog can reopen when the log is rotated.
func (s *logregexStrategy) streamLog() error {
	f, err := os.Open(s.logFile)
	if err != nil {
		return err
	}
	defer f.Close()

	startInfo, _ := f.Stat()

	reader := bufio.NewReader(f)
	var pending strings.Builder
	for {
		chunk, rerr := reader.ReadString('\n')
		switch rerr {
		case nil:
			// Complete line (chunk ends in '\n'), completing any held partial.
			pending.WriteString(chunk)
			s.processLine(strings.TrimRight(pending.String(), "\r\n"))
			pending.Reset()
		case io.EOF:
			// Hold any newline-less tail until the rest is written.
			pending.WriteString(chunk)
			if logRotated(s.logFile, startInfo) {
				return nil
			}
			sleepN(1)
		default:
			return rerr
		}
	}
}

// logRotated reports whether the path now resolves to a different file than the
// one we opened (s6-log rotation replaces `current` with a fresh inode).
func logRotated(path string, start os.FileInfo) bool {
	if start == nil {
		return false
	}
	fi, err := os.Stat(path)
	if err != nil {
		return false
	}
	return !os.SameFile(start, fi)
}

func (s *logregexStrategy) processLine(line string) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.readyPattern != nil && s.readyPattern.MatchString(line) {
		s.serverReady = true
	}

	if s.joinRegex != nil {
		if m := s.joinRegex.FindStringSubmatch(line); m != nil {
			name := captureOrFull(m)
			if _, exists := s.players[name]; !exists {
				s.players[name] = s.nextIdx
				s.nextIdx++
			}
		}
	}

	if s.leaveRegex != nil {
		if m := s.leaveRegex.FindStringSubmatch(line); m != nil {
			name := captureOrFull(m)
			delete(s.players, name)
		}
	}
}

// captureOrFull returns the first capture group if present, else the full match.
func captureOrFull(m []string) string {
	if len(m) > 1 {
		return m[1]
	}
	return m[0]
}

// waitForFile polls until logFile exists, checking every checkSec seconds.
func waitForFile(path string, checkSec int) {
	for {
		if _, err := os.Stat(path); err == nil {
			return
		}
		sleepN(checkSec)
	}
}
