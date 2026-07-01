# UI Flow & Fetch-Logic Audit

Cross-app review of screen-to-screen navigation and backend fetch→logic paths,
hunting for gaps. Findings were verified against the actual code; the
false-positives section records claims that did **not** hold up.

Status key: ✅ fixed · ⬜ open.

---

## ⚠️ False positives (verified NOT gaps)
- "ArticleProvider / SubscriptionProvider / ContactsProvider `.load()` is never
  called → screen always empty." **False.** All three call `load()` in their DI
  `update` callback on authentication
  (`repository_locator.dart` branches 9/13/14) — the standard
  `ChangeNotifierProxyProvider` pattern used app-wide. Articles feed, subscription
  plans/status, and contacts all load.
- Health/Assessment/Nutrition providers `load()` — also wired via DI `update`.

---

## 🔴 Critical (wrong data / data loss / broken flows)

1. ✅ **Tapping a medication row silently deletes it.**
   `medications_screen.dart` — `MedicationListTile.onTap` called
   `provider.delete(med.id)` with no confirmation and no detail screen.
   *Fix:* added a confirmation dialog before delete.

2. ✅ **Chat opened from a profile uses the wrong current-user id.**
   `chat/user_detail_screen.dart` — `ChatScreen(... userId: '123')` hardcoded the
   current user id, breaking message ownership/alignment for everyone but user
   123. *Fix:* use `context.read<AuthState>().userId`.

3. ✅ **Assessment history showed a fake result for every entry.**
   `health_assessment/assessment_history_stepper_screen.dart` — opened
   `AssessmentDetailScreen(disease: 'Tuberculosis', severity: urgent)` hardcoded,
   ignoring the entry's real AI result. *Fix:* pass the entry's actual
   disease/severity (falls back gracefully when the AI result is absent).

4. 🟡 **Subscription "Next" completes "payment" without paying.**
   `subscription/subscription_and_payment_screen.dart` — *Partly fixed:* the
   button now **awaits** `confirmSubscription()`, only navigates to the success
   screen on success, and shows an error SnackBar on failure (was
   fire-and-forget + navigate-regardless). *Still open:* it doesn't call the real
   `createPayment`/`confirmPayment` flow and the review uses hardcoded amounts —
   a full payment-gateway flow is a separate product change.

5. ✅ **AI chatbot message sticks on "Sending…" forever on failure.**
   *Fix:* added a `failed` delivery status; `AiAssistantProvider.send` no longer
   rethrows — it marks the message failed (via `_deliver`) and a new `retry(id)`
   re-sends it. The bubble now shows "Sending…/Sent/Failed — tap to retry" and a
   failed bubble is tappable to retry (`chatbot_screen.dart`).

---

## 🟠 Data layer exists but no UI consumes it
Providers load on auth, but nothing surfaces the data/actions:
- **Notifications** — ⬜ module unused; home bell icon `home_page_screen.dart:369`
  is a no-op; no notifications screen.
- **Ads** — ✅ `home/ad_widget.dart` now consumes `AdsProvider.ads`, records a
  click on tap, hides when empty, and renders `ad.title`/`ad.body` (also fixed a
  latent bug where every page showed `ads[_currentPage]` instead of `ads[index]`).
- **Articles extras** — ⬜ `recommended/bookmarks/comments/detail/toggleBookmark/
  likeArticle` not surfaced; comment "Post" is a no-op
  (`article_comment_screen.dart:378`); detail opens with `comments: const []`;
  like/overflow glyphs are static.
- **Subscription payments** — ⬜ `createPayment/confirmPayment/
  fetchPaymentHistory` never called by UI.
- **Assessment** — ⬜ `submitGuestAssessment/fetchEntry/deleteEntry` unreachable
  (no guest flow, no delete affordance, no single-entry refresh).

---

## 🟡 Dead controls & missing validation
- No-op buttons: chat & group `more: () {}` / attach (`chat_screen.dart:92,113`,
  `group_chat_screen.dart:87,107`), settings "FAQ" `onpressed: null`, health
  "Health Profiles" add/edit/row taps (`health_profile_screen.dart`), assessment
  **"Show nearest hospitals"** empty `onPressed`
  (`assessment_detail_screen.dart:81`), home "Consult our doctors" card empty
  branch (`blog_reccomendation._card.dart:33`), `user_detail_screen.dart` `more`
  + notification toggle.
- **Profile edits lost**: ✅ phone field wired (state + `IntlMobileField`
  `initialValue`/`onChanged`) and sent as `phoneE164` in `_save()`. ✅ avatar
  upload now supported client-side — multipart `PATCH /auth/me/` with a
  `profile_picture` file via Dio `FormData` (`RemoteProfileRepository.uploadAvatar`
  + provider passthrough + `_save` call); `profile_picture` URL is parsed into
  `UserProfile.profilePictureUrl` and the avatar shows local-pick → server URL →
  default. Verified live (upload returns the hosted URL). No backend change
  needed.
- **Signup**: ✅ `_register()` now calls `_formKey.validate()` and enforces the
  "agree to terms" checkbox before submitting
  (`onboarding/signup_and_login_screen.dart`).
- **Forgot-password**: ✅ API errors now surfaced via `ApiException.userMessage`
  in the controller + reset + change-password screens. ⬜ reset email still
  can't deep-link (token never supplied to `ResetPasswordScreen`).
- **Health symptoms**: row `onTap: () {}` — can't open/delete a symptom though
  `deleteSymptom` exists; add-symptom has no error handling.
- **Guest resume**: a returning guest with `isOnboardingCompleted == false` is
  routed into health onboarding instead of Home (`main.dart` resume logic).

---

## Latent (won't bite until backend ships the community↔chat link)
- **"Open group chat" can dead-end.** `community_groups_screen.dart` `_openChat`
  joins by `chatGroupId` then pushes `GroupChatScreen`, but `findGroup` returns
  null if that chat group wasn't already discovered → "Group Not Found".
  Harmless today (`chatGroupId` always null); fix when the link lands.

---

## Progress log
- **Pass 1** — Critical #1 (medication delete confirm), #2 (chat userId), #3
  (real assessment result).
- **Pass 2** — #5 (chatbot failed status + retry), #4 (subscription
  await/guard/no-navigate-on-failure — payment-gateway flow still open), signup
  validation + terms, forgot-password real error messages, profile phone now
  saved, ads widget wired to `AdsProvider`.

- **Pass 3** — avatar upload (client-side multipart `PATCH /auth/me/`,
  `profile_picture` file) + model `profilePictureUrl` + avatar display fallback.
- **Pass 6** — two field-reported bugs:
  1. **Avatar not shown after fetch** — `GET /auth/me/` returns a *relative*
     `/media/...` path (uploads return absolute), so `Image.network` couldn't
     load it. `UserAvatar.resolveUrl` now joins relative paths to the API host
     (used by all avatar sites + the profile-edit `Image.network`).
  2. **"You" appeared as a chat peer** — the private-chat peer-discovery loop
     added *both* participants; it now skips `_currentUserId`, so you no longer
     show up as a peer whose thread displays the real peer's messages.
- **Pass 5** — group chat sender identity: `DirectMessage` now captures
  `sender_name` (was dropped; group bubbles showed a raw numeric id), persisted
  via a `sender_name` DB column (schema v2 + onUpgrade). New `_GroupMessageBubble`
  component shows the sender's avatar + a colour-coded name on incoming group
  messages so members are easy to tell apart.
- **Pass 4** — avatars now *displayed* everywhere they're fetched (previously all
  showed the hardcoded `devsImage`/`personel.png`). Added a reusable
  `UserAvatar` (network URL → asset fallback on null/error); parsed avatars into
  `SuggestedPeer.profilePicture`, `ConnectionRequest.{from,to}UserAvatar` +
  `peerAvatarOf`, and `ChatThread.avatarUrl`. Wired: chat All/People tiles, 1:1
  chat app bar, connection requests, user-detail header, community peer cards +
  hub connection tiles, profile header, public-profile editor. (Group chat keeps
  a placeholder — groups have no avatar.) Payloads verified to carry the URLs
  (`user.profile_picture`, `requester/receiver.profile_picture`, chat `avatar`).

**Still open:** #4 full payment flow; notifications/articles-extras/subscription-
payments/assessment-guest UIs; reset-email deep link; assorted no-op buttons and
the latent "Open group chat" dead-end.
