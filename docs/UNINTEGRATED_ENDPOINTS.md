# Unintegrated Endpoints — exact payload shapes

Endpoints exposed by the live backend (`/api/v1/...`) that the app does **not**
yet call, captured from live probes + the Swagger spec
(`https://pulsminds-healthpilot.chickenkiller.com/swagger.json`).

Conventions: most responses use the `{success, message, data}` envelope (the app
unwraps `data`); DRF list endpoints return `{count, next, previous, results}`
without the envelope. Decimal fields arrive as strings (e.g. `"9.99"`).

Status legend: 🔴 no repo at all · 🟡 feature has a repo, these methods missing.

---

## Subscriptions — payment 🟡  (FF_SUBSCRIPTIONS off)
Repo covers plans/status/subscribe/cancel. Missing:

### `POST /subscriptions/payment/`  — start a payment
Request (required): `{ "amount": 9.99, "payment_method": "card" }`
Response → **Payment**:
```json
{ "id": 0, "amount": "9.99", "currency": "USD", "payment_method": "card",
  "status": "pending", "external_ref": "…", "membership_days": 30,
  "created_at": "2026-…Z" }
```

### `POST /subscriptions/payment/confirm/`  — confirm a payment
Request (required): `{ "payment_id": 0 }` → returns the updated **Payment**.

### `GET /subscriptions/payment/history/`  — paginated
`{ "count": 0, "next": null, "previous": null, "results": [ Payment ] }`

### ⚠️ Existing bug to fix when integrating
`RemoteSubscriptionRepository.subscribe` POSTs to `/subscriptions/subscribe/`
with body `{plan_id}`, but the real route is **`POST /subscriptions/subscribe/{plan}/`**
(plan in the path, no body). Should be `'/subscriptions/subscribe/$planId/'`.

---

## Notifications 🔴  (FF_NOTIFICATIONS off — no repo/model/provider)

### `GET /notifications/`  — paginated
results item → **Notification**:
```json
{ "id": 0, "title": "…", "body": "…", "notif_type": "…",
  "data": { }, "is_read": false, "created_at": "2026-…Z" }
```

### `GET /notifications/unread-count/`
`{ "unread_count": 0 }`  (not enveloped)

### `POST /notifications/read/`  — mark notifications read
Empty body works (marks all). Response: `{ "success": true, "message":
"Notifications marked as read." }`. Optionally accepts notification ids.

### `POST /notifications/device/register/`  — register a push device
Request (required): `{ "token": "<fcm/apns token>" }` (plus optional platform).

---

## Ads 🔴  (no feature flag, no repo)

### `GET /ads/`
Currently returns `{ "success": true, "data": null }` (no ads seeded). The Ad
object shape is **not** in Swagger and unknown until ads exist — model loosely
when integrating.

### `POST /ads/{id}/click/`
Records a click on ad `{id}`. Body/response shape TBD (no live ad to test).

---

## Chat — alias endpoints 🟡  (FF_CHAT on; these duplicate integrated routes)
The app already uses `/chat/private/{chatId}/messages/` and
`/chat/groups/{groupId}/messages/`. These are alternative shapes, integrate only
if the backend deprecates the current ones:

### `GET/POST /chat/direct/{id}/messages/`
Direct messages keyed by **peer user id** (not chat id). POST body → **Message**
(`{content}` required); GET is paginated with `search`/`ordering`/`page`. Response
**Message**:
```json
{ "id": "uuid", "sender_id": "23", "sender_name": "…", "content": "…",
  "timestamp": "2026-…Z", "is_deleted": false }
```

### `POST /chat/messages/`
Generic message send; request body undocumented in Swagger (`parameters: []`).
Needs a live probe to determine fields before integrating.

---

## Already integrated (for reference — do NOT re-add)
auth (login, register, activate, resend, token/refresh, logout, guest, me
get/patch, **password change/reset/confirm, me/delete**), profile (me, doctors,
emergency-contacts), health (symptoms, vitals, goals, summaries, dashboard),
nutrition (history, settings, summary, search, meals), chat (users, private,
groups, **groups/discover**, messages), community (peers, **groups**),
assessments (list, create, delete, **guest, detail**), articles (feed,
**recommended, bookmarks, detail, like, bookmark, comments**), medications
(list, create, update, delete, reminders, doses, **detail**), subscriptions
(plans, status, subscribe, cancel), AI chat.
