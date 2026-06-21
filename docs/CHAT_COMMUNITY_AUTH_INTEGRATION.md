# Chat, Community & Auth — Backend Integration Notes

Living record of the live-backend integration work for the chat, community, and
auth features, plus the architectural relationship between them. Base URL and
envelope conventions come from `healthpilot/dart_defines.json`
(`https://pulsminds-healthpilot.chickenkiller.com`); responses are wrapped in a
`{success, message, data}` envelope that `EnvelopeInterceptor` unwraps, except
DRF list endpoints which return `{count, next, previous, results}`.

Verification is done with `flutter analyze` + the curl scripts in `scripts/`
(`api_probe.sh`, `chat_api_smoke.sh`). `flutter test` is blocked on this machine
by the sqlite3 native-asset build hook, so unit tests are left for CI.

---

## 1. Chat ↔ Community architecture

The app has **two parallel domains** that partly connect.

### Community = social graph / discovery layer
- **Peers**: `suggested → connect (request) → accept/decline → connections`
  (`/community/peers/...`, integer user IDs).
- **Community groups**: support groups with `condition_tags`, `member_count`,
  join/leave (`/community/groups/`, integer IDs) — **no messaging**.

### Chat = messaging layer
- **Chat users**: people you can DM (string IDs).
- **Private chats** and **chat groups**: real message send/read, join/leave,
  discover (`/chat/...`, group IDs are UUIDs).

### The working bridge: peers → chat users
Accepting a connection turns a community peer into a DM-able chat user:
- `connection_requests_screen.dart` calls `startPrivateChat(peerId)` +
  `addConnection(...)` on accept.
- `general_chat_screen._refreshCommunity()` runs
  `community.refreshConnections()` then `chat.syncAcceptedConnections(...)`.
- Backend reinforces it: `GET /chat/users/` returns accepted connections.
- The chat screen is the unified hub: **All / People / Groups** tabs, a
  connection-requests badge, and a link to `SimilarPeopleScreen` (peer discovery).

### ⚠️ Known gap: two disjoint "group" concepts
| | Chat groups | Community groups |
|---|---|---|
| Endpoint | `/chat/groups/` (+ `/discover/`) | `/community/groups/` |
| ID type | UUID | int |
| Messaging | yes | **none** |
| Metadata | participants, last_message | condition_tags, member_count |
| Create flow | `general_chat_screen` dialog | `CommunityGroupsScreen` dialog |

These are **unlinked** — no shared ID or cross-reference field. Joining a
community group does nothing to chat groups, and vice versa. A user can be a
member of a community group with no way to message it. Likely intended model: a
community group is the *entity* and a chat group is its *conversation*, linked
1:1 — but the backend currently exposes them as unrelated resources.

**Open question for backend:** should a community group carry a
`chat_group_id`/`slug` link to its conversation? That answer decides whether to
unify the two "Groups" surfaces or just rename them ("Support Groups" vs "Group
Chats").

---

## 2. Chat feature — fixes & additions

### Parsing fixes (were crashing / silently wrong against live API)
- `ChatUser.fromJson` now reads the live peer shape `{id, full_name, avatar}`
  (int id → string), with legacy keys as fallback. Previously expected
  `user_id/display_name/...` and **crashed** (`Null is not a subtype of String`),
  which took down the whole chat screen on load.
- `ChatGroup.fromJson` maps `participants[]` → `membersId`, reads
  `participant_count` (exposed as `memberCount`), and derives `isJoined` from
  `is_member`/participant membership.

### Group discovery (`GET /chat/groups/discover/`)
`/chat/groups/` only returns joined groups; `/discover/` returns all groups with
an `is_member` flag. `ChatProvider.load()` now sources groups from
`discoverGroups()` (fallback to `fetchGroups()`), so the Groups tab can offer
joinable groups with a Join button.

### Reliability / UX fixes
- **Group chat live updates**: `GroupChatScreen` now fetches on open, polls every
  15s, and marks read — mirroring private chat (previously group messages only
  loaded once at startup).
- **Message ordering**: merged local+remote lists are sorted by timestamp.
- **Crash-proofing**: sender checks use string compare instead of
  `int.parse(...)`.
- **Unread redesign**: replaced the in-memory counter (lost on restart,
  set-vs-add inconsistency, marked-read-by-fetch) with a **persisted last-read
  marker** (SharedPreferences). `unreadCount(id)` = messages from others newer
  than last read; `markRead` persists.
- **Auto-scroll** to newest on open/new message; pagination (`next`) followed for
  message lists; `leaveGroup` clears local cache; rapid identical double-send no
  longer collapses (matched by unique client timestamp); unread badge threshold
  fixed (`>9 → 9+`).

---

## 3. Community feature — groups added

Peers were already integrated; **community groups** were not. Added:
- `CommunityGroup` model `{id, name, slug, description, condition_tags,
  member_count, is_member, is_active}`.
- Repo methods: `fetchGroups` (`GET`), `createGroup` (`POST {name, slug,
  description}`), `joinGroup`/`leaveGroup` (`POST .../join|leave/`).
- `CommunityProvider`: `groups`/`joinedGroups` getters + create/join/leave
  (groups load best-effort so the peers screen never breaks).
- `CommunityGroupsScreen`: list with member count + tags, Join/Leave, create
  dialog (auto-slug from name), pull-to-refresh. Entry point: groups icon on
  `SimilarPeopleScreen`.

Verified live: list/detail/create/join/leave all return 2xx with expected shapes.

---

## 4. Auth — account management

The forgot-password UI existed but was a **pure stub** (`submitEmail()` only
advanced the step, never called the API). Wired it up and filled the gaps.

| Endpoint | Method | Body |
|---|---|---|
| `/auth/password/change/` | POST | `{old_password, new_password, new_password2}` |
| `/auth/password/reset/` | POST | `{email}` |
| `/auth/password/reset/confirm/` | POST | `{token, new_password, new_password2}` |
| `/auth/me/delete/` | DELETE | — |

- Data layer: `IAuthRepository` + remote/mock + `AuthState` methods
  (`changePassword`, `requestPasswordReset`, `confirmPasswordReset`,
  `deleteAccount` — the last also tears down the local session).
- UI: forgot-password flow now calls `requestPasswordReset`; new
  `ResetPasswordScreen` (token + new password) and `ChangePasswordScreen`
  (old → new). Settings "Change Password" now opens the real change screen (it
  previously mis-opened the email-reset flow). "Delete Account" tile added with a
  confirmation dialog.

Verified live: password change round-trips (change → log in with new → restore).

---

## 5. Status / follow-ups
- UI for off-flag features (notifications, ads, article/medication/subscription
  extras) is deferred; data-layer integration tracked separately.
- The community-group ↔ chat-group link question (section 1) is the main
  architectural decision still open.
