#!/bin/bash
set -e

cd /game

# Container-aware JVM settings:
# - UseContainerSupport: JVM reads cgroup memory limits (default in JDK 17+)
# - MaxRAMPercentage: Use 75% of container memory limit for heap
# - InitialRAMPercentage: Start with 50% of container memory for heap
# These automatically adapt to whatever Docker --memory limit is set.
JAVA_ARGS="${MINECRAFT_JAVA_ARGS:--XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200}"

echo "Starting Minecraft Server..."
set -x
exec java ${JAVA_ARGS} -jar server.jar --nogui
