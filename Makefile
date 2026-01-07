TAG := latest

.PHONY: build publish all

build:
	podman build -t justmiles/bip-ops:latest .

publish: build
	podman tag justmiles/bip-ops:latest justmiles/bip-ops:$(TAG)
	podman push justmiles/bip-ops:$(TAG)

all: build publish
