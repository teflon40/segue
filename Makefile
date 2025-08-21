# Makefile for Segue

APP_NAME=segue
IMAGE_NAME=segue:latest
CONTAINER_NAME=segue_container

# Default target
.PHONY: all
all: build

# Build the docker image
.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

# Run the container with X11 forwarding + host networking
.PHONY: run
run:
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		--net=host \
		-e DISPLAY=$DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $$HOME/.Xauthority:/root/.Xauthority \
		$(IMAGE_NAME)

.PHONY: run-dev
run-dev:
	docker build -t segue-dev --target dev .
	docker run -it --rm	\
		--name $(CONTAINER_NAME)_dev \
		--net=host \
        -e DISPLAY=$(DISPLAY) \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $$HOME/.Xauthority:/root/.Xauthority \
        segue-dev

# Build a local binary without Docker
.PHONY: build-local
build-local:
	go build -o bin/$(APP_NAME) ./cmd/$(APP_NAME)

# Run local binary
.PHONY: run-local
run-local: build-local
	./bin/$(APP_NAME)

# Clean up docker stuff and binaries
.PHONY: clean
clean:
	docker rm -f $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi -f $(IMAGE_NAME) 2>/dev/null || true
	rm -rf bin/
