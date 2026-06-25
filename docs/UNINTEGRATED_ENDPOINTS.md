# Unintegrated Endpoints

The live backend exposes **81 endpoints** (Swagger
`https://pulsminds-healthpilot.chickenkiller.com/swagger.json`). As of the latest
pull the spec is unchanged — no new endpoints have been added (the
community↔chat link field the backend agreed to is **not yet shipped**).

Everything is now integrated **except the chat alias routes below**, which are
intentional duplicates of routes the app already uses.

---

## Chat — alias endpoints 🟡 (intentionally skipped)
The app already uses `/chat/private/{chatId}/messages/` and
`/chat/groups/{groupId}/messages/`. These are alternative shapes; integrate only
if the backend deprecates the current ones.

### `GET/POST /chat/direct/{id}/messages/`
Direct messages keyed by **peer user id** (not chat id). POST body → **Message**
(`{content}` required); GET paginated with `search`/`ordering`/`page`. Response
**Message**: `{ id, sender_id, sender_name, content, timestamp, is_deleted }`.

### `POST /chat/messages/`
Generic message send; request body undocumented in Swagger (`parameters: []`).
Needs a live probe to determine fields before integrating.

---

## Recently integrated (this pass)
- **Subscriptions payment**: `createPayment` (`POST /payment/` — `{amount,
  payment_method}`, methods: `bank|paypal|credit_card|stripe|other`),
  `confirmPayment` (`POST /payment/confirm/` — response is `{payment, membership}`,
  payment unwrapped), `fetchPaymentHistory` (`GET /payment/history/`). Also fixed
  `subscribe` to use the path form `POST /subscriptions/subscribe/{plan}/`.
- **Notifications** (new feature module): `fetchNotifications`, `unreadCount`
  (`{unread_count}`), `markRead({ids})` (omit ids → mark all), `registerDevice`
  (`{token, platform}`). Provider + DI wired behind `FF_NOTIFICATIONS`.
- **Ads** (new feature module): `fetchAds` (tolerant of `data:null` / list /
  `{results}`), `recordClick`. Provider + DI behind new `FF_ADS`. Ad shape has no
  Swagger schema, so `AdItem` maps common fields and keeps the raw payload.

## Notes
- All new providers auto-load on authentication via `ChangeNotifierProxyProvider`
  and use mock repos when their feature flag is off.
- UI surfacing for off-flag features (notifications centre, real ad widget,
  payment screen) is still deferred — these are data-layer + provider only.
