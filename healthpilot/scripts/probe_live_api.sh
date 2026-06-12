#!/usr/bin/env bash
# Probe HealthPilot live GET endpoints.
#
# Usage:
#   ./scripts/probe_live_api.sh
#   ACCESS_TOKEN='eyJ...' ./scripts/probe_live_api.sh
#   ./scripts/probe_live_api.sh --guest   # guest login, then probe (403 on most features)
#
set -euo pipefail

BASE="${APP_BASE_URL:-https://pulsminds-healthpilot.chickenkiller.com}"
BASE="${BASE%/}"

if [[ "${1:-}" == "--guest" ]]; then
  echo "Creating guest session..."
  ACCESS_TOKEN="$(curl -sf -X POST "$BASE/api/v1/auth/guest/" \
    -H "Content-Type: application/json" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['access'])")"
  echo "Guest access token acquired."
fi

auth_header=()
if [[ -n "${ACCESS_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: Bearer $ACCESS_TOKEN")
  echo "Using ACCESS_TOKEN from environment."
else
  echo "No ACCESS_TOKEN — probing unauthenticated (expect 401)."
fi

paths=(
  "/health/"
  "/api/v1/assessments/"
  "/api/v1/chat/ai/history/"
  "/api/v1/chat/users/"
  "/api/v1/chat/private/"
  "/api/v1/chat/groups/"
  "/api/v1/nutrition/history/"
  "/api/v1/nutrition/meals/"
  "/api/v1/nutrition/settings/"
  "/api/v1/nutrition/goals/"
  "/api/v1/health/symptoms/"
  "/api/v1/auth/me/"
)

for path in "${paths[@]}"; do
  code="$(curl -s -o /tmp/hp_probe.json -w "%{http_code}" "${auth_header[@]}" "$BASE$path")"
  echo ""
  echo "=== $code GET $path ==="
  python3 - <<'PY'
import json, pathlib
raw = pathlib.Path("/tmp/hp_probe.json").read_text()
try:
    import pprint
    pprint.pp(json.loads(raw), width=100, depth=4)
except json.JSONDecodeError:
    print(raw[:500])
PY
done
