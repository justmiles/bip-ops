package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"sync/atomic"
)

var (
	atomicPlayerCount atomic.Int64
	atomicServerReady atomic.Int32
)

// serveMetrics starts a local Prometheus /metrics endpoint on :9091.
func serveMetrics() {
	mux := http.NewServeMux()
	mux.HandleFunc("/metrics", handleMetrics)
	slog.Info("metrics endpoint listening", "addr", "127.0.0.1:9091")
	if err := http.ListenAndServe("127.0.0.1:9091", mux); err != nil {
		slog.Error("metrics server error", "error", err)
	}
}

func handleMetrics(w http.ResponseWriter, _ *http.Request) {
	count := atomicPlayerCount.Load()
	ready := atomicServerReady.Load()
	w.Header().Set("Content-Type", "text/plain; version=0.0.4")
	_, _ = fmt.Fprintf(w, "# HELP active_player_count Number of players currently connected\n")
	_, _ = fmt.Fprintf(w, "# TYPE active_player_count gauge\n")
	_, _ = fmt.Fprintf(w, "active_player_count %d\n", count)
	_, _ = fmt.Fprintf(w, "# HELP server_ready 1 if the game server is ready to accept players\n")
	_, _ = fmt.Fprintf(w, "# TYPE server_ready gauge\n")
	_, _ = fmt.Fprintf(w, "server_ready %d\n", ready)
}

func updatePrometheus(s Sample) {
	atomicPlayerCount.Store(int64(s.ActivePlayerCount))
	if s.ServerReady {
		atomicServerReady.Store(1)
	} else {
		atomicServerReady.Store(0)
	}
}
