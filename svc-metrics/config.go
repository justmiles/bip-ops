package main

import (
	"fmt"
	"os"
	"time"

	"gopkg.in/yaml.v3"
)

// BipOpsYAML is the top-level .bip-ops.yaml structure (only fields we need).
type BipOpsYAML struct {
	Metrics *MetricsConfig `yaml:"metrics"`
}

// MetricsConfig is the metrics: block in .bip-ops.yaml.
type MetricsConfig struct {
	Strategy string         `yaml:"strategy"`
	Interval string         `yaml:"interval"`
	RCON     *RCONConfig    `yaml:"rcon"`
	A2S      *A2SConfig     `yaml:"a2s"`
	Logregex *LogregexConfig `yaml:"logregex"`
	Ready    *ReadyConfig   `yaml:"ready"`
}

// RCONConfig holds the rcon: sub-block.
type RCONConfig struct {
	Command      string `yaml:"command"`
	PlayersRegex string `yaml:"players_regex"`
	PortEnv      string `yaml:"port_env"`
	PasswordEnv  string `yaml:"password_env"`
}

// A2SConfig holds the a2s: sub-block.
type A2SConfig struct {
	QueryPortEnv string `yaml:"query_port_env"`
}

// LogregexConfig holds the logregex: sub-block.
type LogregexConfig struct {
	JoinPattern  string `yaml:"join_pattern"`
	LeavePattern string `yaml:"leave_pattern"`
	LogFile      string `yaml:"log_file"`
}

// ReadyConfig holds the ready: sub-block.
type ReadyConfig struct {
	LogPattern string `yaml:"log_pattern"`
}

// loadConfig parses the .bip-ops.yaml at path and returns its metrics block.
// Returns nil metrics if the file has no metrics: block (strategy: none).
func loadConfig(path string) (*MetricsConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read %s: %w", path, err)
	}
	var top BipOpsYAML
	if err := yaml.Unmarshal(data, &top); err != nil {
		return nil, fmt.Errorf("parse %s: %w", path, err)
	}
	return top.Metrics, nil
}

// parseDuration parses a duration string, returning defaultDur on error.
func parseDuration(s string, defaultDur time.Duration) time.Duration {
	if s == "" {
		return defaultDur
	}
	d, err := time.ParseDuration(s)
	if err != nil {
		return defaultDur
	}
	return d
}
