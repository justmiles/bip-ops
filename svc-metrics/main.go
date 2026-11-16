package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	slog.SetDefault(slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})))

	gameserver := os.Getenv("BIPOPS_GAMESERVER")
	if gameserver == "" || gameserver == "NONE" {
		slog.Info("BIPOPS_GAMESERVER not set, svc-metrics idle")
		idleUntilSignal()
		return
	}

	metricsURL := os.Getenv("BIPOPS_METRICS_URL")
	metricsToken := os.Getenv("BIPOPS_METRICS_TOKEN")

	cfgPath := "/gameservers/" + gameserver + "/.bip-ops.yaml"
	cfg, err := loadConfig(cfgPath)
	if err != nil {
		slog.Warn("config load failed, strategy: none", "error", err)
	}

	if cfg == nil || cfg.Strategy == "" || cfg.Strategy == "none" {
		slog.Info("metrics strategy: none, svc-metrics idle", "game", gameserver)
		idleUntilSignal()
		return
	}

	interval := parseDuration(cfg.Interval, 30*time.Second)

	go serveMetrics()

	strat, err := newStrategy(cfg)
	if err != nil {
		slog.Error("strategy init failed", "strategy", cfg.Strategy, "error", err)
		os.Exit(1)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer cancel()

	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	slog.Info("svc-metrics started", "game", gameserver, "strategy", strat.Name(), "interval", interval)

	for {
		select {
		case <-ctx.Done():
			slog.Info("svc-metrics stopping")
			return
		case <-ticker.C:
			sample, err := strat.Collect()
			if err != nil {
				slog.Warn("collect failed", "strategy", strat.Name(), "error", err)
				continue
			}
			slog.Debug("sample", "players", sample.ActivePlayerCount, "ready", sample.ServerReady)
			updatePrometheus(sample)
			if metricsURL != "" && metricsToken != "" {
				if err := pushMetrics(metricsURL, metricsToken, sample); err != nil {
					slog.Warn("push failed", "error", err)
				}
			}
		}
	}
}

// sleepN sleeps for n seconds. Used by logregex retry loop.
func sleepN(n int) {
	time.Sleep(time.Duration(n) * time.Second)
}

// idleUntilSignal blocks until the process receives SIGTERM/SIGINT. Unlike a
// bare `select {}`, it does not trip Go's "all goroutines are asleep - deadlock"
// panic, so the service idles cleanly (no s6 restart loop) for games with
// strategy: none until s6 stops the container.
func idleUntilSignal() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	<-ctx.Done()
}
