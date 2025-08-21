# -------------------------------
# Stage 1: Build
# -------------------------------
FROM golang:1.24-alpine AS builder

# Install dependencies needed to build robotgo
#   - build-base : compilers + libc headers (similar to gcc + make)
#   - x11-dev    : X11 headers for input/output
#   - libxtst-dev: XTest headers for simulating key/mouse
#   - libxkbcommon-dev: keyboard handling libs
#   - libpng-dev : bitmap/screenshot support
RUN apk add --no-cache \
    build-base \
    libx11-dev \
    libxtst-dev \
    libxkbcommon-dev \
    libpng-dev \
    xclip \
    xsel

# Set working directory inside container
WORKDIR /app

# Copy Go module files first (better layer caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Segue binary
RUN go build -o segue ./cmd/segue

# -------------------------------
# Stage 2: Runtime
# -------------------------------
FROM alpine:latest

# Install only runtime dependencies (no compilers or dev headers)
#   - libx11        : base X11 runtime libs
#   - libxtst       : runtime for XTest
#   - libxkbcommon  : runtime for keyboard events
#   - libpng        : runtime for bitmap/screenshot
#   - xclip, xsel   : optional, for clipboard support
RUN apk add --no-cache \
    libx11 \
    libxtst \
    libxkbcommon \
    libpng \
    xclip \
    xsel

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/segue /usr/local/bin/segue

# Run Segue by default
ENTRYPOINT ["segue"]


# -------------------------------
# Stage 3: Dev (for go run)
# -------------------------------
FROM golang:1.24-alpine AS dev

RUN apk add --no-cache \
    libx11-dev \
    libxtst-dev \
    libxkbcommon-dev \
    libpng-dev \
    xclip \
    xsel

WORKDIR /app

COPY . .

ENTRYPOINT ["go", "run", "./cmd/segue"]
