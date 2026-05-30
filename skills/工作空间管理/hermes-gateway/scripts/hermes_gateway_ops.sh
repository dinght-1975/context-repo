#!/usr/bin/env bash
# Hermes gateway ops for one AI_STUDIO workspace (.hermes profile).
# Aligned with platform-api hermes_gateway.py

set -euo pipefail

CMD="${1:-status}"
WS="$(cd "${2:-.}" && pwd)"
HERMES_DIR="$WS/.hermes"
GATEWAY_JSON="$HERMES_DIR/gateway.json"
ENV_FILE="$HERMES_DIR/.env"
LOG_FILE="$HERMES_DIR/gateway.log"
HOME_DIR="${HOME:?HOME is not set}"

export HOME="$HOME_DIR"
export HERMES_HOME="$HERMES_DIR"
export TERMINAL_CWD="$WS"
export HERMES_ACCEPT_HOOKS=1

die() {
  echo "error: $*" >&2
  exit 1
}

need_hermes() {
  command -v hermes >/dev/null 2>&1 || die "hermes CLI not found in PATH"
}

ensure_layout() {
  mkdir -p "$HERMES_DIR/skills"
}

read_gateway() {
  if [[ ! -f "$GATEWAY_JSON" ]]; then
    echo ""
    return 0
  fi
  python3 - "$GATEWAY_JSON" <<'PY'
import json, sys
p = sys.argv[1]
with open(p, encoding="utf-8") as f:
    d = json.load(f)
print(d.get("api_host", "127.0.0.1"))
print(d.get("api_port", ""))
print(d.get("api_key", ""))
PY
}

mask_key() {
  local key="$1"
  if [[ ${#key} -le 8 ]]; then
    echo "****"
  else
    echo "${key:0:8}…"
  fi
}

health_check() {
  local host="$1" port="$2" key="$3"
  [[ -n "$port" && -n "$key" ]] || return 1
  local code
  code=$(curl -s -o /tmp/hermes_health_$$.json -w "%{http_code}" \
    -H "Authorization: Bearer $key" \
    "http://${host}:${port}/health" || echo "000")
  if [[ "$code" == "200" ]]; then
    cat /tmp/hermes_health_$$.json
    echo
    rm -f /tmp/hermes_health_$$.json
    return 0
  fi
  rm -f /tmp/hermes_health_$$.json
  return 1
}

gateway_cli_status() {
  hermes gateway status 2>&1 || true
}

cmd_status() {
  need_hermes
  ensure_layout
  echo "workspace: $WS"
  echo "hermes_home: $HERMES_HOME"
  echo "terminal_cwd: $TERMINAL_CWD"
  echo "--- hermes gateway status ---"
  gateway_cli_status
  if [[ ! -f "$GATEWAY_JSON" ]]; then
    echo "--- gateway.json: (missing, not provisioned yet) ---"
    return 0
  fi
  mapfile -t gw < <(read_gateway)
  local host="${gw[0]:-127.0.0.1}"
  local port="${gw[1]:-}"
  local key="${gw[2]:-}"
  echo "--- gateway.json ---"
  echo "  host: $host"
  echo "  port: $port"
  echo "  api_key: $(mask_key "$key")"
  echo "--- HTTP /health ---"
  if health_check "$host" "$port" "$key"; then
    echo "health: OK"
  else
    echo "health: FAIL"
    return 1
  fi
}

cmd_start() {
  need_hermes
  ensure_layout
  cd "$WS"
  echo "starting gateway (workspace=$WS)..."
  hermes gateway start 2>&1 || true
  sleep 1
  if cmd_status >/dev/null 2>&1; then
    echo "gateway started and healthy"
    return 0
  fi
  echo "fallback: hermes gateway run --accept-hooks (log: $LOG_FILE)"
  {
    echo ""
    echo "--- gateway run $(date -Iseconds) ---"
  } >>"$LOG_FILE"
  nohup hermes gateway run --accept-hooks >>"$LOG_FILE" 2>&1 &
  sleep 2
  cmd_status
}

cmd_stop() {
  need_hermes
  cd "$WS"
  echo "stopping gateway..."
  hermes gateway stop 2>&1 || true
}

cmd_restart() {
  cmd_stop
  sleep 1
  cmd_start
}

cmd_test() {
  cmd_status
  mapfile -t gw < <(read_gateway)
  local host="${gw[0]:-127.0.0.1}"
  local port="${gw[1]:-}"
  local key="${gw[2]:-}"
  [[ -n "$port" && -n "$key" ]] || die "gateway.json missing or incomplete"
  echo "--- POST /v1/chat/completions (smoke) ---"
  local resp
  resp=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $key" \
    -H "Content-Type: application/json" \
    -d '{"model":"hermes-agent","messages":[{"role":"user","content":"reply with OK only"}],"stream":false}' \
    "http://${host}:${port}/v1/chat/completions")
  local body="${resp%$'\n'*}"
  local code="${resp##*$'\n'}"
  echo "HTTP $code"
  echo "$body" | head -c 500
  echo
  [[ "$code" == "200" ]] || die "chat completions test failed"
  echo "test: OK"
}

case "$CMD" in
  status) cmd_status ;;
  start) cmd_start ;;
  stop) cmd_stop ;;
  restart) cmd_restart ;;
  test) cmd_test ;;
  *)
    die "usage: $0 <status|start|stop|restart|test> [workspace_root]"
    ;;
esac
