#!/usr/bin/env bash
set -e

CONTAINER_NAME="mom-sandbox"
DATA_DIR="$(pwd)/data"
HRSYSTEM_DIR="${HRSYSTEM_DIR:-/c/Users/tonyh/Desktop/hrsystem}"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Verify project dir exists (bind-mounted into the container so the agent can edit it)
if [ ! -d "$HRSYSTEM_DIR" ]; then
    echo "Error: HRSYSTEM_DIR not found: $HRSYSTEM_DIR"
    echo "Override with: HRSYSTEM_DIR=/path/to/project ./dev.sh"
    exit 1
fi

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Check if it's running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Starting existing container: $CONTAINER_NAME"
        docker start "$CONTAINER_NAME"
    else
        echo "Container $CONTAINER_NAME already running"
    fi
else
    echo "Creating container: $CONTAINER_NAME"
    MSYS_NO_PATHCONV=1 docker run -d \
        --name "$CONTAINER_NAME" \
        -v "$DATA_DIR:/workspace" \
        -v "$HRSYSTEM_DIR:/workspace/hrsystem" \
        alpine:latest \
        tail -f /dev/null
fi

# Run mom with tsx watch mode
echo "Starting mom in dev mode..."
npx tsx --watch-path src --watch src/main.ts --sandbox=docker:$CONTAINER_NAME ./data
