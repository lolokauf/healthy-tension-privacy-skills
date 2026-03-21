# Consent Flow Review — Multi-Surface Analytics Opt-In Example

A worked example demonstrating the Consent Flow Reviewer skill applied to a fictional multi-surface productivity app with analytics consent across web, mobile, and backend workers.

---

## Input Description

A productivity SaaS application ("TaskFlow") with three surfaces and a background worker:

- **Web app (React):** Analytics opt-in toggle on the account creation screen. Toggle defaults to OFF (opt-in). PostHog SDK initialised client-side with `persistence: "memory"`. Toggle state saved via `PATCH /api/user/analytics` and stored in the `users` table as `analytics_opted_in` (boolean, default `false`).
- **Mobile app (React Native):** Separate analytics toggle in Settings > Privacy. Reads consent state from its own `AsyncStorage` key `analytics_consent`. Does NOT call the backend API to sync — consent is device-local. Mixpanel SDK initialised at app launch regardless of consent state; events are queued and sent unconditionally.
- **Backend (Express):** `trackEvent()` utility function called from 12 route handlers. Sends events to PostHog server-side. The function accepts a `userId` parameter and checks `user.analyticsOptedIn` from the database before sending — but 3 of the 12 call sites pass events without a userId (system events), bypassing the consent check entirely.
- **Retention worker (cron):** Runs daily at 3 AM UTC. Processes inactive accounts for deletion. Logs a `retention_check_performed` event to PostHog for each account processed, using the account's userId. Does not check `analyticsOptedIn` before logging.

---

## Expected Output

### Summary

- **Consent mechanisms found:** 2
- **Pre-consent violations:** 1
- **Dark patterns found:** 1
- **Enforcement gaps:** 4
- **Withdrawal issues:** 1

---

### Section 1: Consent Mechanism Inventory

| Mechanism | Type | Legal Basis | Granularity | Revocable? | Art. 4(11) Failures | Confidence |
|-----------|------|-------------|-------------|------------|---------------------|------------|
| Web analytics toggle (account creation) | Analytics opt-in | Consent (Art. 6(1)(a)) | Single purpose (analytics only) | Yes — toggle in Settings > Privacy | None identified | HIGH |
| Mobile analytics toggle (Settings > Privacy) | Analytics opt-in | Consent (Art. 6(1)(a)) | Single purpose (analytics only) | Yes — same toggle | None identified | HIGH |

---

### Section 2: Pre-Consent Violations

| Script / Pixel | Loads Before Consent? | Data Transmitted | Strictly Necessary? | Severity | Confidence |
|---------------|----------------------|------------------|---------------------|----------|------------|
| Mixpanel SDK (mobile) | Yes — `Mixpanel.init()` called in `App.tsx` `useEffect` at launch, before user reaches Settings > Privacy | Device ID, OS version, app version, IP address | No — analytics serves the controller's interest | CRITICAL | HIGH |

---

### Section 3: Dark Pattern Findings

| Pattern | EDPB Category | Sub-Type | Code Evidence | Severity | Confidence |
|---------|--------------|----------|---------------|----------|------------|
| Mobile: withdrawal requires Settings > Privacy > Analytics toggle > Confirm dialog (4 taps). Granting requires a single toggle tap on the same screen when first presented. The confirm dialog ("Are you sure? This helps us improve TaskFlow for you.") adds friction and uses emotional steering. | Hindering + Stirring | Longer than necessary (4.2) + Emotional steering (3.1) | `PrivacySettings.tsx:89` — `if (!newValue) setShowConfirmDialog(true)` (no confirm on opt-in). `ConfirmDialog.tsx:12` — copy includes "helps us improve TaskFlow for you" | HIGH | HIGH (friction), LOW (emotional steering — copy assessment) |

---

### Section 4: Consent Enforcement Map

| Capture Point | Data Sent | Consent Required | Enforcement Point | Enforced? | Gap? | Confidence |
|--------------|-----------|------------------|-------------------|-----------|------|------------|
| `web/src/lib/analytics.ts:15` — `posthog.capture('page_view')` | Page URL, referrer, session ID | Analytics consent | `web/src/lib/analytics.ts:12` — `if (!user.analyticsOptedIn) return` | Yes | No | HIGH |
| `web/src/lib/analytics.ts:28` — `posthog.capture('task_created')` | Task metadata (no PII) | Analytics consent | `web/src/lib/analytics.ts:12` — same guard | Yes | No | HIGH |
| `web/src/lib/analytics.ts:41` — `posthog.capture('subscription_upgraded')` | Plan name, price | Analytics consent | `web/src/lib/analytics.ts:12` — same guard | Yes | No | HIGH |
| `mobile/src/analytics.ts:8` — `Mixpanel.track('screen_view')` | Screen name, device ID, OS | Analytics consent | NONE — Mixpanel initialised unconditionally, no consent gate | No | **Yes** | HIGH |
| `mobile/src/analytics.ts:22` — `Mixpanel.track('task_completed')` | Task count, device ID | Analytics consent | NONE — same as above | No | **Yes** | HIGH |
| `backend/src/routes/tasks.ts:45` — `trackEvent('task_api_created', { userId })` | userId, event name | Analytics consent | `backend/src/utils/analytics.ts:8` — checks `user.analyticsOptedIn` in DB | Yes | No | HIGH |
| `backend/src/routes/auth.ts:78` — `trackEvent('login_success', { userId })` | userId, IP address, user agent | Analytics consent | `backend/src/utils/analytics.ts:8` — same guard | Yes | No | HIGH |
| `backend/src/routes/health.ts:12` — `trackEvent('health_check')` | Timestamp, response time | None (no userId) | `backend/src/utils/analytics.ts:8` — guard checks userId; no userId means guard is bypassed | N/A | No — system event, no personal data | HIGH |
| `backend/src/routes/billing.ts:34` — `trackEvent('payment_failed')` | Error code, timestamp | None (no userId) | Same bypass as above | N/A | No — no personal data in event | HIGH |
| `backend/src/routes/export.ts:22` — `trackEvent('data_export', { userId, exportSize })` | userId, export file size | Analytics consent | `backend/src/utils/analytics.ts:8` — same guard | Yes | No | HIGH |
| `retention-worker/src/index.ts:45` — `posthog.capture('retention_check_performed', { distinctId: userId })` | userId, account age, inactive days | Analytics consent | NONE — worker does not import or check `analyticsOptedIn` | No | **Yes** | HIGH |
| `retention-worker/src/index.ts:62` — `posthog.capture('account_deleted', { distinctId: userId })` | userId, deletion reason | Analytics consent | NONE — same as above | No | **Yes** | HIGH |

#### Exempt Entries

| Capture Point | Exemption Justification | Strictly Necessary Because | User-Requested Purpose | Service Cannot Function Without |
|--------------|------------------------|---------------------------|----------------------|-------------------------------|
| `backend/src/routes/health.ts:12` — `trackEvent('health_check')` | System monitoring event with no personal data | Contains only timestamp and response time — no userId, IP, or device identifiers | Infrastructure monitoring (not user-facing) | N/A — exempt because no personal data is transmitted, not because it is strictly necessary |
| `backend/src/routes/billing.ts:34` — `trackEvent('payment_failed')` | System error event with no personal data | Contains only error code and timestamp — no userId or payment details | N/A — operational alerting | N/A — exempt because no personal data is transmitted |

---

### Section 5: Withdrawal Trace

| Mechanism | Withdrawal Path | Clicks to Withdraw | Clicks to Grant | As Easy as Granting? | Data Purged? | Confidence |
|-----------|----------------|-------------------|-----------------|---------------------|-------------|------------|
| Web analytics toggle | Settings > Privacy > Toggle off | 3 (navigate to settings, click privacy section, click toggle) | 1 (toggle on account creation screen) | No — 3 clicks vs 1, but no additional friction beyond navigation | No — existing PostHog events not deleted on withdrawal (Art. 17 erasure is a separate right, not triggered by withdrawal) | HIGH |
| Mobile analytics toggle | Settings > Privacy > Toggle off > Confirm dialog | 4 (navigate to settings, tap privacy, tap toggle, tap confirm) | 1 (tap toggle when first presented) | No — 4 taps vs 1, plus confirmation dialog with emotional steering copy | No — Mixpanel data not deleted; additionally, Mixpanel SDK continues running after withdrawal (no `Mixpanel.optOut()` call) | HIGH |

---

### Section 6: Cross-Surface Sync

| Surface | Consent Mechanism | Sync Method | Consistent? | Confidence |
|---------|------------------|-------------|-------------|------------|
| Web | Analytics toggle → `PATCH /api/user/analytics` → DB `analyticsOptedIn` | Backend API (source of truth) | Yes — reads from DB on each request | HIGH |
| Mobile | Analytics toggle → `AsyncStorage` only | None — device-local, no backend sync | **No** — mobile consent state is independent of web consent state | HIGH |
| Backend | Reads `user.analyticsOptedIn` from DB | N/A — is the source of truth | Yes — consistent with web | HIGH |
| Retention worker | None — does not check consent | None | **No** — fires analytics events for users who may have opted out | HIGH |

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| Mobile Mixpanel initialises before consent | Step 2 (Pre-Consent) | `Mixpanel.init()` runs at app launch, transmitting device ID and IP to Mixpanel servers before the user has any opportunity to visit Settings > Privacy. Even if the user never opts in, Mixpanel has already received personal data. The fix: defer `Mixpanel.init()` until after consent is granted, or use Mixpanel's `optOutTrackingByDefault` configuration. |
| Mobile consent not synced to backend | Step 6 (Cross-Surface) | A user who opts out on the web (via the API) remains opted in on mobile (AsyncStorage still says `true`). A user who opts out on mobile has no effect on backend-side tracking. This means consent is not a single coherent state but two independent booleans that can contradict each other. The fix: mobile must call `PATCH /api/user/analytics` and read consent state from the backend on each app launch. |
| Retention worker bypasses consent | Step 4 (Enforcement) | The worker sends `retention_check_performed` and `account_deleted` events to PostHog using the user's `userId` as `distinctId` — but never queries whether the user opted in to analytics. This is an enforcement gap: the capture point exists, the consent control exists, but no enforcement point connects them. The fix: the worker must query `analyticsOptedIn` before calling `posthog.capture()`, or these events must be restructured as system events without `distinctId`. |
| Withdrawal asymmetry with emotional steering | Steps 3 + 5 (Dark Patterns + Withdrawal) | On mobile, opting in is a single tap. Opting out requires navigating to settings (2 taps), toggling off (1 tap), and confirming through a dialog that says "This helps us improve TaskFlow for you" (1 tap) — 4 taps total with emotional friction. Art. 7(3) requires withdrawal to be as easy as granting. The confirm dialog should be removed or made symmetric (also shown on opt-in). |
| Enforcement map as primary artifact | Step 4 (Enforcement) | The 12-row enforcement map reveals that 6 capture points are properly gated, 4 have gaps, and 2 are legitimately exempt. Without this map, the mobile and worker gaps would be invisible — the web consent flow works correctly, creating a false sense of full compliance. The enforcement map is the artifact that exposes system-level gaps that surface-level reviews miss. |
