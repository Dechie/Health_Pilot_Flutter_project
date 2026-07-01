#!/usr/bin/env bash
#
# Chat API smoke test for HealthPilot backend.
#
# Logs in, captures the JWT, then walks the private + group chat endpoints,
# printing each request and its (envelope-unwrapped) response payload.
#
# Requires: curl, jq
#
# Usage:
#   ./scripts/chat_api_smoke.sh
#   BASE_URL=http://localhost:9000 ./scripts/chat_api_smoke.sh
#   EMAIL=foo@bar.com PASSWORD=secret ./scripts/chat_api_smoke.sh

set -uo pipefail

# --- Config (from healthpilot/dart_defines.json) ----------------------------
BASE_URL="${BASE_URL:-https://pulsminds-healthpilot.chickenkiller.com}"
BASE_URL="${BASE_URL%/}"                       # strip any trailing slash
API="$BASE_URL/api/v1"
EMAIL="${EMAIL:-dechassa0@gmail.com}"
PASSWORD="${PASSWORD:-StrongPass123!}"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required (apt install jq)"; exit 1; }

# --- Pretty helpers ----------------------------------------------------------
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
step()  { printf '\n\033[1;36m=== %s ===\033[0m\n' "$*"; }
info()  { printf '\033[2m%s\033[0m\n' "$*"; }

ACCESS=""

# call METHOD PATH [JSON_BODY]
# Prints the request line, HTTP status, and the response body (pretty if JSON).
call() {
  local method="$1" path="$2" body="${3:-}"
  local url="$API$path"
  info "→ $method $url${body:+  $body}"

  local tmp http
  tmp="$(mktemp)"
  if [[ -n "$body" ]]; then
    http="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" "$url" \
      -H "Authorization: Bearer $ACCESS" \
      -H 'Content-Type: application/json' \
      -d "$body")"
  else
    http="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" "$url" \
      -H "Authorization: Bearer $ACCESS" \
      -H 'Content-Type: application/json')"
  fi

  printf '  HTTP %s\n' "$http"
  if jq -e . "$tmp" >/dev/null 2>&1; then
    jq . "$tmp"
  else
    cat "$tmp"; echo
  fi
  # Stash last body for the caller to parse out IDs.
  LAST_BODY="$(cat "$tmp")"
  rm -f "$tmp"
}

# --- 0. Login ----------------------------------------------------------------
step "0. Login  ($EMAIL)"
info "→ POST $API/auth/login/"
LOGIN_RESP="$(curl -sS -X POST "$API/auth/login/" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")"
echo "$LOGIN_RESP" | jq . 2>/dev/null || echo "$LOGIN_RESP"

# Envelope is {success, message, data:{access, refresh}}; tolerate flat shape too.
ACCESS="$(echo "$LOGIN_RESP" | jq -r '.data.access // .access // empty')"
REFRESH="$(echo "$LOGIN_RESP" | jq -r '.data.refresh // .refresh // empty')"

if [[ -z "$ACCESS" ]]; then
  echo; bold "✗ Login failed — no access token returned. Aborting."; exit 1
fi
bold "✓ Got access token (${#ACCESS} chars)"

# --- 1. Connected peers ------------------------------------------------------
step "1. GET /chat/users/  (connected peers)"
call GET "/chat/users/"
PEER_ID="$(echo "$LAST_BODY" | jq -r '(.data // .results // . // [])[0].id // empty' 2>/dev/null)"
info "first peer id = ${PEER_ID:-<none>}"

# --- 2. Start a private chat -------------------------------------------------
step "2. POST /chat/private/  (start private chat)"
if [[ -n "$PEER_ID" ]]; then
  call POST "/chat/private/" "{\"user_id\": $PEER_ID}"
  CHAT_ID="$(echo "$LAST_BODY" | jq -r '.data.id // .data.chat_id // .chat_id // .id // empty' 2>/dev/null)"
else
  info "No connected peer found — skipping private-chat creation."
  info "(Connect with a user via community first, then re-run.)"
  CHAT_ID=""
fi
info "chat_id = ${CHAT_ID:-<none>}"

# --- 3 & 4. Send + read private messages -------------------------------------
if [[ -n "$CHAT_ID" ]]; then
  step "3. POST /chat/private/$CHAT_ID/messages/  (send)"
  call POST "/chat/private/$CHAT_ID/messages/" '{"content": "Hello from smoke test!"}'

  step "4. GET /chat/private/$CHAT_ID/messages/  (read)"
  call GET "/chat/private/$CHAT_ID/messages/"
else
  info "Skipping send/read private messages (no chat_id)."
fi

# --- 5. List all private chats ----------------------------------------------
step "5. GET /chat/private/  (list private chats)"
call GET "/chat/private/"

# --- 6. Reuse (or, opt-in, create) a group -----------------------------------
# By default this REUSES an existing group from discovery so repeat runs don't
# pollute the backend with duplicate "Diabetes Support" groups (the chat API has
# no delete endpoint). Set CREATE_GROUP=1 to force-create a fresh group.
GROUP_ID=""
if [[ "${CREATE_GROUP:-0}" == "1" ]]; then
  step "6. POST /chat/groups/  (create group — CREATE_GROUP=1)"
  call POST "/chat/groups/" '{"name": "Diabetes Support", "description": "Support group"}'
  GROUP_ID="$(echo "$LAST_BODY" | jq -r '.data.id // .data.group_id // .group_id // .id // empty' 2>/dev/null)"
else
  step "6. GET /chat/groups/discover/  (reuse an existing group)"
  call GET "/chat/groups/discover/"
  GROUP_ID="$(echo "$LAST_BODY" | jq -r '(.data // .results // . // [])[0].id // empty' 2>/dev/null)"
  info "reusing group_id = ${GROUP_ID:-<none>}  (set CREATE_GROUP=1 to create a new one)"
fi

# --- 7. List all groups ------------------------------------------------------
step "7. GET /chat/groups/  (list groups)"
call GET "/chat/groups/"

# Fallback: if create didn't return an id, grab one from the list.
if [[ -z "$GROUP_ID" ]]; then
  GROUP_ID="$(echo "$LAST_BODY" | jq -r '(.data // .results // . // [])[0].id // empty' 2>/dev/null)"
  info "using group_id from list = ${GROUP_ID:-<none>}"
fi

# --- 8-11. Join / send / read / leave group ----------------------------------
if [[ -n "$GROUP_ID" ]]; then
  step "8. POST /chat/groups/$GROUP_ID/join/"
  call POST "/chat/groups/$GROUP_ID/join/"

  step "9. POST /chat/groups/$GROUP_ID/messages/  (send)"
  call POST "/chat/groups/$GROUP_ID/messages/" '{"content": "Hi everyone!"}'

  step "10. GET /chat/groups/$GROUP_ID/messages/  (read)"
  call GET "/chat/groups/$GROUP_ID/messages/"

  step "11. POST /chat/groups/$GROUP_ID/leave/"
  call POST "/chat/groups/$GROUP_ID/leave/"
else
  info "Skipping group join/send/read/leave (no group_id)."
fi

step "Done."
