package main

import (
	"fmt"
	"net"
	"time"
)

// a2sQuery is the A2S_INFO request payload.
var a2sQuery = []byte{0xFF, 0xFF, 0xFF, 0xFF, 0x54, 'S', 'o', 'u', 'r', 'c', 'e', ' ', 'E', 'n', 'g', 'i', 'n', 'e', ' ', 'Q', 'u', 'e', 'r', 'y', 0x00}

type a2sStrategy struct {
	port        int
	ready       *ReadyConfig
	serverReady bool
}

func newA2SStrategy(port int, ready *ReadyConfig) Strategy {
	return &a2sStrategy{port: port, ready: ready}
}

func (s *a2sStrategy) Name() string { return "a2s" }

func (s *a2sStrategy) Collect() (Sample, error) {
	addr := fmt.Sprintf("127.0.0.1:%d", s.port)
	conn, err := net.DialTimeout("udp", addr, 5*time.Second)
	if err != nil {
		return Sample{}, fmt.Errorf("a2s dial: %w", err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(5 * time.Second))

	if _, err := conn.Write(a2sQuery); err != nil {
		return Sample{}, fmt.Errorf("a2s send: %w", err)
	}

	buf := make([]byte, 1400)
	n, err := conn.Read(buf)
	if err != nil {
		return Sample{}, fmt.Errorf("a2s recv: %w", err)
	}

	count, err := parseA2SInfo(buf[:n])
	if err != nil {
		return Sample{}, fmt.Errorf("a2s parse: %w", err)
	}

	s.serverReady = true
	return Sample{
		ActivePlayerCount: count,
		ServerReady:       s.serverReady,
	}, nil
}

// parseA2SInfo extracts the player count from an A2S_INFO (0x49) response.
// Response layout (after 4-byte FF prefix):
//
//	[0x49] [protocol] [name\0] [map\0] [folder\0] [game\0] [2 bytes appid] [1 byte players] ...
func parseA2SInfo(data []byte) (int, error) {
	if len(data) < 6 {
		return 0, fmt.Errorf("response too short (%d bytes)", len(data))
	}
	// Skip 4-byte prefix (0xFF x4) + 1 byte type + 1 byte protocol
	off := 6
	if data[4] != 0x49 {
		// May be a challenge (0x41) if the server requires one; not handled here.
		return 0, fmt.Errorf("unexpected response type 0x%02x (expected 0x49)", data[4])
	}
	// Skip 4 null-terminated strings: name, map, folder, game
	for i := 0; i < 4; i++ {
		idx := indexByte(data, off, 0x00)
		if idx < 0 {
			return 0, fmt.Errorf("malformed A2S_INFO response (missing string %d)", i)
		}
		off = idx + 1
	}
	// Skip 2-byte app ID
	off += 2
	if off >= len(data) {
		return 0, fmt.Errorf("response truncated before player count")
	}
	return int(data[off]), nil
}

func indexByte(data []byte, start int, b byte) int {
	for i := start; i < len(data); i++ {
		if data[i] == b {
			return i
		}
	}
	return -1
}
