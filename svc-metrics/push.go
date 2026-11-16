package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"time"
)

// MetricsPayload is the JSON body sent to the bipops-ui ingest endpoint.
type MetricsPayload struct {
	ActivePlayerCount int      `json:"active_player_count"`
	ServerReady       bool     `json:"server_ready"`
	PlayerNames       []string `json:"player_names"`
	Hibernating       bool     `json:"hibernating"`
	SampledAt         string   `json:"sampled_at"`
}

var httpClient = &http.Client{Timeout: 10 * time.Second}

// pushMetrics encodes the sample as JSON and POSTs it to metricsURL.
func pushMetrics(metricsURL, token string, s Sample) error {
	names := s.PlayerNames
	if names == nil {
		names = []string{}
	}
	payload := MetricsPayload{
		ActivePlayerCount: s.ActivePlayerCount,
		ServerReady:       s.ServerReady,
		PlayerNames:       names,
		SampledAt:         time.Now().UTC().Format(time.RFC3339),
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal payload: %w", err)
	}

	req, err := http.NewRequest(http.MethodPut, metricsURL, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("http push: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		slog.Warn("metrics push: server rejected payload", "status", resp.StatusCode, "url", metricsURL)
	}
	return nil
}
