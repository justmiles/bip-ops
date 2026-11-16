package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"net"
	"regexp"
	"strings"
	"time"
)

const (
	rconTypeAuth    = 3
	rconTypeCommand = 2
	rconTypeResp    = 0
)

type rconStrategy struct {
	port         int
	password     string
	command      string
	playersRegex *regexp.Regexp
	ready        *ReadyConfig
	serverReady  bool
}

func newRCONStrategy(port int, password, command, playersRegex string, ready *ReadyConfig) Strategy {
	var re *regexp.Regexp
	if playersRegex != "" {
		re = regexp.MustCompile(playersRegex)
	}
	return &rconStrategy{
		port:         port,
		password:     password,
		command:      command,
		playersRegex: re,
		ready:        ready,
	}
}

func (s *rconStrategy) Name() string { return "rcon" }

func (s *rconStrategy) Collect() (Sample, error) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", s.port), 5*time.Second)
	if err != nil {
		return Sample{}, fmt.Errorf("rcon connect: %w", err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(10 * time.Second))

	if err := rconSend(conn, 1, rconTypeAuth, s.password); err != nil {
		return Sample{}, fmt.Errorf("rcon auth send: %w", err)
	}
	if _, _, err := rconRecv(conn); err != nil {
		return Sample{}, fmt.Errorf("rcon auth recv: %w", err)
	}

	if err := rconSend(conn, 2, rconTypeCommand, s.command); err != nil {
		return Sample{}, fmt.Errorf("rcon cmd send: %w", err)
	}
	_, body, err := rconRecv(conn)
	if err != nil {
		return Sample{}, fmt.Errorf("rcon cmd recv: %w", err)
	}

	count, names := s.parseResponse(body)
	s.serverReady = true

	return Sample{
		ActivePlayerCount: count,
		PlayerNames:       names,
		ServerReady:       s.serverReady,
	}, nil
}

func (s *rconStrategy) parseResponse(body string) (int, []string) {
	if s.playersRegex == nil {
		lines := strings.Split(strings.TrimSpace(body), "\n")
		count := 0
		for _, l := range lines {
			if strings.TrimSpace(l) != "" {
				count++
			}
		}
		return count, nil
	}
	matches := s.playersRegex.FindAllString(body, -1)
	return len(matches), nil
}

func rconSend(conn net.Conn, id, typ int, body string) error {
	var buf bytes.Buffer
	payload := body + "\x00\x00"
	size := int32(4 + 4 + len(payload))
	if err := binary.Write(&buf, binary.LittleEndian, size); err != nil {
		return err
	}
	if err := binary.Write(&buf, binary.LittleEndian, int32(id)); err != nil {
		return err
	}
	if err := binary.Write(&buf, binary.LittleEndian, int32(typ)); err != nil {
		return err
	}
	buf.WriteString(payload)
	_, err := conn.Write(buf.Bytes())
	return err
}

func rconRecv(conn net.Conn) (id int, body string, err error) {
	var size int32
	if err = binary.Read(conn, binary.LittleEndian, &size); err != nil {
		return
	}
	if size < 10 || size > 4096 {
		err = fmt.Errorf("rcon response size %d out of range", size)
		return
	}
	data := make([]byte, size)
	if _, err = readFull(conn, data); err != nil {
		return
	}
	idRaw := binary.LittleEndian.Uint32(data[0:4])
	id = int(idRaw)
	body = string(bytes.TrimRight(data[8:], "\x00"))
	return
}

func readFull(conn net.Conn, buf []byte) (int, error) {
	total := 0
	for total < len(buf) {
		n, err := conn.Read(buf[total:])
		total += n
		if err != nil {
			return total, err
		}
	}
	return total, nil
}
