TAG := latest

.PHONY: build publish all

build:
	podman build -t justmiles/bipops:latest .

publish: build
	podman tag justmiles/bipops:latest justmiles/bipops:$(TAG)
	podman push justmiles/bipops:$(TAG)

all: build publish
