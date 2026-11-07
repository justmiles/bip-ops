TAG := latest

.PHONY: build publish all verify

build:
	docker build -t justmiles/bipops:latest .

publish: build
	docker tag justmiles/bipops:latest justmiles/bipops:$(TAG)
	docker push justmiles/bipops:$(TAG)

all: build publish

# Readiness gate: boot a game server and confirm it binds a listening socket.
# Usage: make verify GAMESERVER=icarus [VERIFY_ARGS="--port 17777"]
verify:
	bash scripts/verify-gameserver.sh $(GAMESERVER) $(VERIFY_ARGS)
