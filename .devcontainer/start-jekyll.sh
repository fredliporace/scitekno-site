#!/bin/bash
set -uo pipefail

LOG="/tmp/jekyll.log"
PORT=4000
WORKSPACE="/workspaces/scitekno-site"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG}"
}

cd "${WORKSPACE}" || { log "ERROR: Cannot cd to ${WORKSPACE}"; exit 1; }

log "=== Starting Jekyll autostart script ==="
log "PWD: $(pwd)"
log "USER: $(whoami)"

if [ -f /tmp/jekyll.pid ]; then
  OLD_PID=$(cat /tmp/jekyll.pid)
  if ps -p "${OLD_PID}" > /dev/null 2>&1; then
    log "Jekyll already running with PID ${OLD_PID}."
    exit 0
  else
    log "Stale PID file found (PID ${OLD_PID} not running). Cleaning up."
    rm -f /tmp/jekyll.pid
  fi
fi

log "Checking if port ${PORT} is in use..."
if command -v ss >/dev/null 2>&1; then
  if ss -tlnp | grep -q ":${PORT} "; then
    log "Port ${PORT} already in use. Assuming Jekyll is running."
    exit 0
  fi
elif command -v netstat >/dev/null 2>&1; then
  if netstat -tlnp 2>/dev/null | grep -q ":${PORT} "; then
    log "Port ${PORT} already in use. Assuming Jekyll is running."
    exit 0
  fi
fi

log "Loading shell environment..."
if [ -f ~/.bashrc ]; then
  source ~/.bashrc || true
fi

if [ -f ~/.profile ]; then
  source ~/.profile || true
fi

log "Checking for bundle..."
if ! command -v bundle >/dev/null 2>&1; then
  log "ERROR: bundle not found in PATH."
  log "PATH: ${PATH}"
  exit 1
fi

log "Running bundle install..."
bundle install >>"${LOG}" 2>&1 || log "WARNING: bundle install failed"

log "Starting Jekyll..."
nohup bundle exec jekyll serve --livereload --host 0.0.0.0 --port "${PORT}" >>"${LOG}" 2>&1 &
NEW_PID=$!
echo "${NEW_PID}" > /tmp/jekyll.pid
log "Jekyll started with PID ${NEW_PID}."

sleep 3

if ps -p "${NEW_PID}" > /dev/null 2>&1; then
  log "Jekyll is running (PID ${NEW_PID})."
else
  log "ERROR: Jekyll process exited immediately. Check ${LOG} for details."
  tail -n 50 "${LOG}"
  exit 1
fi
