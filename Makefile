IMAGE_NAME := bip-ops
REGISTRY := docker.io/justmiles
TAG := latest

.PHONY: build publish all

build:
	podman build -t localhost/$(IMAGE_NAME):$(TAG) .

publish: build
	podman tag localhost/$(IMAGE_NAME):$(TAG) $(REGISTRY)/$(IMAGE_NAME):$(TAG)
	podman push $(REGISTRY)/$(IMAGE_NAME):$(TAG)

all: build publish
