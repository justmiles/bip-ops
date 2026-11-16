package main

import (
	"bufio"
	"io"
	"log/slog"
	"os"
	"regexp"
	"sync"
)

type logregexStrategy struct {
	logFile      string
	joinRegex    *regexp.Regexp
	leaveRegex   *regexp.Regexp
	ready        *ReadyConfig
	readyPattern *regexp.Regexp

	mu          sync.Mutex
	players     map[string]struct{}
	serverReady bool
}

func newLogregexStrategy(logFile, joinPattern, leavePattern string, ready *ReadyConfig) Strategy {
	s := &logregexStrategy{
		logFile: logFile,
		players: make(map[string]struct{}),
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

	names := make([]string, 0, len(s.players))
	for name := range s.players {
		names = append(names, name)
	}
	return Sample{
		ActivePlayerCount: len(s.players),
		PlayerNames:       names,
		ServerReady:       s.serverReady,
	}, nil
}

// tailLog opens the log file, seeks to the end, and streams new lines.
// Retries on open failure (file may not exist yet during server boot).
func (s *logregexStrategy) tailLog() {
	for {
		if err := s.streamLog(); err != nil {
			slog.Debug("logregex: stream ended, retrying", "error", err)
		}
		// Wait before retry; avoids tight loop when file absent during boot.
		waitForFile(s.logFile, 5)
	}
}

func (s *logregexStrategy) streamLog() error {
	f, err := os.Open(s.logFile)
	if err != nil {
		return err
	}
	defer f.Close()

	// Seek to end so we only process lines written after startup.
	if _, err := f.Seek(0, io.SeekEnd); err != nil {
		return err
	}

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		s.processLine(line)
	}
	return scanner.Err()
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
			s.players[name] = struct{}{}
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
