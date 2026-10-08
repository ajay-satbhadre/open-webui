#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit

# Debug: print environment and ensure DATA_DIR/PYTHONPATH defaults
echo "[startup] SCRIPT_DIR=$SCRIPT_DIR"
echo "[startup] Initial envs: DATA_DIR=${DATA_DIR:-}<unset> PYTHONPATH=${PYTHONPATH:-}<unset> HOME=${HOME:-}<unset> USER=${USER:-}<unset>"

# Copy the application tree, including hidden files, into the writable home path.
echo "[startup] Copying /app contents to /home/openwebui/"
if mkdir -p /home/openwebui && cp -a /app/. /home/openwebui/; then
    echo "[startup] Application copy completed"
else
    echo "[startup] ERROR: Could not copy /app contents to /home/openwebui/"
    exit 1
fi


PYTHON_CMD=$(command -v python3 || command -v python)
UVICORN_WORKERS="${UVICORN_WORKERS:-1}"

# If script is called with arguments, use them; otherwise use default workers
if [ "$#" -gt 0 ]; then
    ARGS=("$@")
else
    ARGS=(--workers "$UVICORN_WORKERS")
fi

PORT="${PORT:-8080}"
HOST="${HOST:-0.0.0.0}"

# Run uvicorn
WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY" exec "$PYTHON_CMD" -m uvicorn open_webui.main:app \
    --host "$HOST" \
    --port "$PORT" \
    --forwarded-allow-ips "${FORWARDED_ALLOW_IPS:-*}" \
    "${ARGS[@]}"
