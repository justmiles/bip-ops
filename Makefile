TAG := latest

.PHONY: build publish all

build:
	docker build -t justmiles/bipops:latest .

publish: build
	docker tag justmiles/bipops:latest justmiles/bipops:$(TAG)
	docker push justmiles/bipops:$(TAG)

all: build publish
