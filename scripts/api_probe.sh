#!/usr/bin/env bash
#
# Endpoint probe for HealthPilot backend — auth, profile, health, nutrition.
# Logs in, then GETs each read endpoint and exercises safe create→delete
# writes, printing every response so payload shapes can be compared against
# the app's parsing code.
#
# Requires: curl, jq
# Usage: ./scripts/api_probe.sh   (optional EMAIL=… PASSWORD=… BASE_URL=…)

set -uo pipefail

BASE_URL="${BASE_URL:-https://pulsminds-healthpilot.chickenkiller.com}"
BASE_URL="${BASE_URL%/}"
API="$BASE_URL/api/v1"
EMAIL="${EMAIL:-dechassa0@gmail.com}"
PASSWORD="${PASSWORD:-StrongPass123!}"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq required"; exit 1; }

step()  { printf '\n\033[1;36m=== %s ===\033[0m\n' "$*"; }
info()  { printf '\033[2m%s\033[0m\n' "$*"; }
ACCESS=""; REFRESH=""; LAST_BODY=""

call() {
  local method="$1" path="$2" body="${3:-}"
  local url="$API$path" tmp http
  info "→ $method $url${body:+  $body}"
  tmp="$(mktemp)"
  if [[ -n "$body" ]]; then
    http="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" "$url" \
      -H "Authorization: Bearer $ACCESS" -H 'Content-Type: application/json' -d "$body")"
  else
    http="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" "$url" \
      -H "Authorization: Bearer $ACCESS" -H 'Content-Type: application/json')"
  fi
  printf '  HTTP %s\n' "$http"
  if jq -e . "$tmp" >/dev/null 2>&1; then jq . "$tmp"; else cat "$tmp"; echo; fi
  LAST_BODY="$(cat "$tmp")"; rm -f "$tmp"
}

# --- Login -------------------------------------------------------------------
step "LOGIN"
LOGIN_RESP="$(curl -sS -X POST "$API/auth/login/" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")"
ACCESS="$(echo "$LOGIN_RESP" | jq -r '.data.access // .access // empty')"
REFRESH="$(echo "$LOGIN_RESP" | jq -r '.data.refresh // .refresh // empty')"
[[ -z "$ACCESS" ]] && { echo "$LOGIN_RESP"; echo "LOGIN FAILED"; exit 1; }
info "got token (${#ACCESS} chars), user id $(echo "$LOGIN_RESP" | jq -r '.data.user.id')"

############################  AUTH  ############################
step "AUTH: GET /auth/me/"
call GET "/auth/me/"

step "AUTH: PATCH /auth/me/ (no-op echo of current allergies)"
CUR_ALLERGIES="$(echo "$LAST_BODY" | jq -r '.data.allergies // ""')"
call PATCH "/auth/me/" "{\"allergies\": $(jq -Rn --arg a "$CUR_ALLERGIES" '$a')}"

step "AUTH: POST /auth/token/refresh/"
call POST "/auth/token/refresh/" "{\"refresh\": \"$REFRESH\"}"

step "AUTH: POST /auth/register/ (existing email → expect validation error shape)"
call POST "/auth/register/" "{\"email\":\"$EMAIL\",\"first_name\":\"x\",\"last_name\":\"y\",\"password\":\"$PASSWORD\",\"password2\":\"$PASSWORD\"}"

step "AUTH: POST /auth/resend-activation/ (already active → observe shape)"
call POST "/auth/resend-activation/" "{\"email\":\"$EMAIL\"}"

############################  PROFILE  ############################
step "PROFILE: GET /profile/me/"
call GET "/profile/me/"

step "PROFILE: PATCH /profile/me/ (echo current is_visible_in_community)"
VIS="$(echo "$LAST_BODY" | jq -r '.data.is_visible_in_community // true')"
call PATCH "/profile/me/" "{\"is_visible_in_community\": $VIS}"

############################  HEALTH  ############################
step "HEALTH: GET /health/symptoms/"
call GET "/health/symptoms/"

step "HEALTH: POST /health/symptoms/ (create temp)"
call POST "/health/symptoms/" '{"name":"__probe_symptom","severity":3,"logged_at":"2026-06-21T10:00:00Z"}'
SYMPTOM_ID="$(echo "$LAST_BODY" | jq -r '.data.id // .id // empty')"
info "created symptom id = ${SYMPTOM_ID:-<none>}"

if [[ -n "$SYMPTOM_ID" ]]; then
  step "HEALTH: DELETE /health/symptoms/$SYMPTOM_ID/ (cleanup)"
  call DELETE "/health/symptoms/$SYMPTOM_ID/"
fi

step "HEALTH: GET /health/conditions/ (app says this doesn't exist — verify)"
call GET "/health/conditions/"

############################  NUTRITION  ############################
step "NUTRITION: GET /nutrition/settings/"
call GET "/nutrition/settings/"

step "NUTRITION: GET /nutrition/history/"
call GET "/nutrition/history/"

step "Done. (logout intentionally skipped to keep refresh token valid)"
