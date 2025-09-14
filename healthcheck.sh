#!/bin/bash

function exitmsg() {
    echo "EXITING..."
}

trap exitmsg EXIT

# one-time healthchecks
# TODO: add healthchecks here

echo "GAME RUNNING (NOT REALLY)!"

# Recurring healthchecks
while true; do
	sleep 20
done
