package main

import (
	"fmt"
	"os"
	"strconv"
)

// Sample holds a single metrics reading from a strategy.
type Sample struct {
	ActivePlayerCount int
	PlayerNames       []string
	ServerReady       bool
}

// Strategy collects one Sample per call.
type Strategy interface {
	Collect() (Sample, error)
	// Name returns the strategy identifier for logging.
	Name() string
}

// newStrategy constructs the Strategy described by cfg.
func newStrategy(cfg *MetricsConfig) (Strategy, error) {
	switch cfg.Strategy {
	case "rcon":
		if cfg.RCON == nil {
			return nil, fmt.Errorf("strategy rcon requires rcon: block")
		}
		port, err := resolveIntEnv(cfg.RCON.PortEnv, 25575)
		if err != nil {
			return nil, fmt.Errorf("rcon port_env %q: %w", cfg.RCON.PortEnv, err)
		}
		password := resolveStrEnv(cfg.RCON.PasswordEnv, "")
		return newRCONStrategy(port, password, cfg.RCON.Command, cfg.RCON.PlayersRegex, cfg.Ready), nil

	case "a2s":
		if cfg.A2S == nil {
			return nil, fmt.Errorf("strategy a2s requires a2s: block")
		}
		port, err := resolveIntEnv(cfg.A2S.QueryPortEnv, 27015)
		if err != nil {
			return nil, fmt.Errorf("a2s query_port_env %q: %w", cfg.A2S.QueryPortEnv, err)
		}
		return newA2SStrategy(port, cfg.Ready), nil

	case "logregex":
		if cfg.Logregex == nil {
			return nil, fmt.Errorf("strategy logregex requires logregex: block")
		}
		logFile := cfg.Logregex.LogFile
		if logFile == "" {
			logFile = "/var/log/gameserver/current"
		}
		return newLogregexStrategy(logFile, cfg.Logregex.JoinPattern, cfg.Logregex.LeavePattern, cfg.Ready), nil

	default:
		return nil, fmt.Errorf("unknown strategy %q", cfg.Strategy)
	}
}

// resolveIntEnv reads an env var by name and converts it to int.
// Falls back to defaultVal when the var is empty or unset.
func resolveIntEnv(envVar string, defaultVal int) (int, error) {
	if envVar == "" {
		return defaultVal, nil
	}
	val := os.Getenv(envVar)
	if val == "" {
		return defaultVal, nil
	}
	n, err := strconv.Atoi(val)
	if err != nil {
		return 0, fmt.Errorf("parse %q=%q as int: %w", envVar, val, err)
	}
	return n, nil
}

// resolveStrEnv reads an env var by name. Falls back to defaultVal when empty.
func resolveStrEnv(envVar, defaultVal string) string {
	if envVar == "" {
		return defaultVal
	}
	val := os.Getenv(envVar)
	if val == "" {
		return defaultVal
	}
	return val
}
