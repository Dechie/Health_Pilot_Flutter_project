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
member of a community group with no way to message it.

**Backend's answer (confirmed):** there is **no link between them in the
database**, and the team acknowledges this as a **design gap**. Their framing:

- **CommunityGroup** = *identity / membership* — "I belong to the diabetes
  community." For discovery / peer-matching. Has `members`, `condition_tags`,
  `slug`. API: `/api/v1/community/groups/`.
- **GroupChat** = *communication channel* — "I want to talk in this room right
  now." For real-time messaging. Has `participants`, `Message` objects. API:
  `/api/v1/chat/groups/`.

Joining a CommunityGroup does **not** create or join a GroupChat (or vice
versa). Ideally joining a CommunityGroup would grant access to a linked
GroupChat; until the backend adds that link, **the Flutter client must call both
APIs separately**.

**Implication for the app / open decision:**
- Proper fix is server-side: add a `chat_group_id` (or shared `slug`) on
  CommunityGroup so the two can be resolved 1:1.
- Interim client-side options (no backend change):
  1. Keep them separate and **rename for clarity** — "Support Groups"
     (community) vs "Group Chats" (chat) — so users aren't confused by two
     "Groups". Lowest risk.
  2. Best-effort bridge: on community-group join, also create/join a chat group
     of the same name. **Fragile** — names aren't unique (the live data already
     has several groups literally named "Diabetes Support"), so this can join the
     wrong room. Not recommended without a real link field.

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

## 5. Additional endpoint integrations (data layer)

These complete previously-partial features. All are data-layer only (repository +
model + interface + mock); UI wiring for off-flag features is deferred.

### Assessments (`/assessments/`, FF on)
- `submitGuestAssessment` → `POST /assessments/guest/` (body reuses
  `AssessmentSummary.toApiJson()`, which includes the required `symptoms`).
- `fetchEntry(id)` → `GET /assessments/{id}/` (single assessment detail).

### Articles (`/articles/`, FF off)
The article model and feed repo were **stale/broken** against the live API and
are now fixed plus extended:
- `ArticleFeedItem.fromJson` now maps the live shape `{id:int, headline,
  summary|body, image_url, read_time_minutes, published_at}` (was expecting
  `title/body/read_minutes` with a String id → would have crashed). Added
  `copyWith`.
- `fetchArticles` previously read `response.data['data']` (wrong — `ApiClient`
  already returns unwrapped data) → now parses `results` and follows `next`
  pagination.
- Added: `fetchRecommended` (`/recommended/`), `fetchBookmarks` (`/bookmarks/`),
  `fetchArticle(id)` (`/{id}/`), `toggleBookmark(id)` (`POST /{id}/bookmark/`),
  `fetchComments(id)` + `addComment(id, text)` (`/{id}/comments/`, body `{text}`).
- `likeArticle(id)` now returns `bool` (the endpoint returns `{liked}`, not a
  full article); the provider adjusts the local like count accordingly.
- New `ArticleComment` model `{id, author_name→authorName, text, created_at,
  parent}`.

### Medications (`/medications/`, FF off)
- `fetchMedication(id)` → `GET /medications/{id}/` (single medication detail).

## 6. Dedicated Community hub + community↔chat link

### Community↔chat group link (forward-compatible)
- `CommunityGroup` now carries a nullable `chatGroupId` (parsed from
  `chat_group_id`/`group_chat_id`). It's null today, so nothing renders until the
  backend ships the field.
- Decision agreed with backend: **link, don't auto-join.** Joining a community
  group stays membership-only; the linked GroupChat is **opt-in**. The community
  group card shows an "Open group chat" action only when `chatGroupId != null`,
  which joins the chat room (idempotent) then opens it.

### CommunityHubScreen (new)
A dedicated, first-class Community surface (`community_hub_screen.dart`) with
tabs **For You / People / Groups**, reached from: the assessment result
("Go to Community" → For You), the chat hub's person-search FAB, and a Home
"Community" card. Composes existing pieces (`DiscoverablePeerCard`,
`CommunityGroupsBody`/`CommunityGroupCard`, `ConnectionRequestsScreen`).

### ⚠️ HELD: Chat page vs Community hub overlap (to reconcile)
The existing **chat page** has tabs **All / People / Groups**; the new
**Community hub** has **For You / People / Groups**. These now **overlap**:
- "People" exists on both (chat = who I message; community = discover + my
  connections).
- "Groups" exists on both but they're *different resources* — chat = **Group
  Chats** (conversations, UUID), community = **Support Groups** (membership,
  int). This is the two-"Groups" confusion, now duplicated across two screens.

Two near-identical 3-tab surfaces is redundant. **Intended end-state — one job
each:**
- **Chat = inbox.** Only active conversations (All / DMs / Group Chats). No peer
  discovery, no group browsing/join.
- **Community hub = discovery + identity.** Find people, manage
  connections/requests, browse/join Support Groups; bridge *into* chat via
  "Message" / "Open group chat".
- Rename to kill the word collision: Chat "Groups" → **Group Chats**, Community
  "Groups" → **Support Groups**.

**Decision pending** (user to choose): slim the chat page down to the inbox
(remove its People-discovery + Groups-browse role), **or** keep both surfaces and
only relabel. Not yet actioned — the hub was built first; the chat page still
carries its old discovery role.

## 7. Status / follow-ups
- Remaining unintegrated endpoints (subscriptions payment, notifications, ads,
  chat message aliases) are catalogued with exact payload shapes in
  `docs/UNINTEGRATED_ENDPOINTS.md`.
- UI for off-flag features (notifications, ads, article/medication/subscription
  extras) is deferred; those are data-layer only.
- Community↔chat link: awaiting the backend `chat_group_id` field (client side
  ready).
- **Chat vs Community overlap (section 6) is the main open UX decision.**
