package main

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

// TestLogregexFollowsNecesse reproduces the deployed failure: the readiness line
// is written BEFORE svc-metrics attaches, and joins/leaves are appended AFTER.
// The tailer must still report ready and the correct live player count.
// Log format verified against live Necesse 1.3.3 server output:
//
//	join:  Client "76561198813665297" connected on slot 1/4
//	leave: Player 76561198813665297 ("justMiles2") disconnected with message: Quit
func TestLogregexFollowsNecesse(t *testing.T) {
	logPath := filepath.Join(t.TempDir(), "current")

	// Boot/readiness line exists before the strategy attaches.
	must(t, os.WriteFile(logPath,
		[]byte("[2026-11-16 00:00:00] Started server using port 14159 with 10 slots on world \"default.zip\"\n"), 0o644))

	s := newLogregexStrategy(logPath,
		`Client "([0-9]+)" connected on slot`,
		`Player ([0-9]+) \(`,
		&ReadyConfig{LogPattern: "Started server using port"},
	).(*logregexStrategy)

	appendLine := func(line string) {
		f, err := os.OpenFile(logPath, os.O_APPEND|os.O_WRONLY, 0o644)
		must(t, err)
		_, err = f.WriteString(line + "\n")
		must(t, err)
		must(t, f.Close())
	}

	// Pre-existing boot line must be read (read-from-start), so ready flips true.
	waitFor(t, func() bool { sm, _ := s.Collect(); return sm.ServerReady }, "server_ready from pre-existing boot line")

	// A join appended AFTER attach must be followed.
	appendLine(`[t] Client "76561190000000001" connected on slot 0/10`)
	waitFor(t, func() bool { sm, _ := s.Collect(); return sm.ActivePlayerCount == 1 }, "count==1 after first player joins")

	appendLine(`[t] Client "76561190000000002" connected on slot 1/10`)
	waitFor(t, func() bool { sm, _ := s.Collect(); return sm.ActivePlayerCount == 2 }, "count==2 after second player joins")

	// logregex never exposes internal identifiers as player names.
	sm, _ := s.Collect()
	if len(sm.PlayerNames) != 0 {
		t.Errorf("logregex should not report player names, got %v", sm.PlayerNames)
	}

	// A disconnect must decrement by the same captured Steam ID.
	appendLine(`[t] Player 76561190000000001 ("Alice") disconnected with message: Quit`)
	waitFor(t, func() bool { sm, _ := s.Collect(); return sm.ActivePlayerCount == 1 }, "count==1 after first player leaves")
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}

func waitFor(t *testing.T, cond func() bool, desc string) {
	t.Helper()
	deadline := time.Now().Add(8 * time.Second)
	for time.Now().Before(deadline) {
		if cond() {
			return
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("timeout waiting for: %s", desc)
}
