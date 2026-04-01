# Consent Category Classification Guide

Reference for classifying cookies, scripts, pixels, and other tracking technologies into consent categories. Use this checklist when performing all steps of the Cookie & Tracker Audit.

---

## Four Consent Categories

The four-category model is the most widely adopted framework, aligned with CNIL guidelines, ICO guidance, and most CMP implementations.

### 1. Strictly Necessary

**Definition:** Storage or access that is strictly necessary for the provision of an information society service explicitly requested by the user. No consent required under ePrivacy Art. 5(3).

**Key test (ePrivacy Art. 5(3)):** Would the service the user explicitly requested fail to function without this cookie/storage? "Fail to function" means the service cannot be delivered at all — not merely that it would be less convenient or less optimised.

| Qualifies | Does NOT Qualify |
|-----------|-----------------|
| Session authentication cookies | Analytics cookies (even "essential analytics") |
| CSRF protection tokens | A/B testing cookies |
| Shopping cart cookies (during active session) | Social media login cookies (unless user clicked "Login with...") |
| Load balancer cookies | Performance monitoring cookies |
| User language preference cookies (if set by explicit user action) | Advertising cookies |
| CMP consent state cookies | Session replay cookies |
| Security cookies (rate limiting, bot detection) | Personalisation cookies (unless user explicitly requested personalisation) |

**Common strictly necessary cookies:**

| Cookie | Purpose | Justification |
|--------|---------|---------------|
| Session ID (`connect.sid`, `PHPSESSID`, `_session_id`) | Server session management | Authentication and stateful interaction require server session |
| CSRF token (`_csrf`, `XSRF-TOKEN`) | Cross-site request forgery protection | Security mechanism required for form submission |
| Cart/basket (`cart_id`, `basket`) | Shopping cart persistence | User explicitly adds items to cart; cart cannot function without state |
| Consent cookie (`CookieConsent`, `OptanonConsent`) | Stores consent choice | Consent mechanism cannot function without storing the choice |
| Load balancer (`SERVERID`, `__cf_bm`, `__cflb`) | Server routing / bot management | Infrastructure required to serve the page. Note: `__cfduid` was retired by Cloudflare in May 2021 — replaced by `__cf_bm` (Bot Management) and `__cflb` (Load Balancer). |

**Red flags for false "strictly necessary" claims:**
- Cookie persists longer than the session or user interaction
- Cookie contains a cross-site identifier (e.g., a UUID that is also sent to a third party)
- Cookie is set before the user has taken any action (pre-consent)
- The claimed purpose is "improving performance" or "enhancing experience" — these are analytics/functional, not strictly necessary

### 2. Functional / Preferences

**Definition:** Cookies that enable enhanced functionality or personalisation based on the user's explicit choices, but are not strictly necessary for the core service. Consent required.

| Examples | Why Functional, Not Strictly Necessary |
|----------|---------------------------------------|
| Language preference cookie (auto-detected, not user-selected) | Service can function with default language; preference is convenience |
| Persistent login / "remember me" | Session cookie handles authentication; persistent login is a convenience feature |
| Volume/playback preferences | Default settings serve the core function; preferences enhance experience |
| Font size / accessibility preferences set via toggle | Service functions at default settings; toggle is an enhancement |
| Region/location preference (not geo-IP) | Service can function without location personalisation |
| Chat widget state (open/closed) | Chat functions without state persistence |

### 3. Analytics / Performance

**Definition:** Cookies and trackers used to understand how users interact with the service — page views, traffic sources, error rates, performance metrics. Consent required.

| Examples | Consent Category |
|----------|-----------------|
| Google Analytics (`_ga`, `_gid`, `_gat`) | Analytics |
| Plausible Analytics (cookieless — but still processes IP/UA) | Analytics |
| PostHog (`ph_*_posthog`) | Analytics |
| Mixpanel (`mp_*_mixpanel`) | Analytics |
| Amplitude (`AMP_*`) | Analytics |
| HotJar session replay (`_hj*`) | Analytics |
| FullStory session replay (`fs_uid`) | Analytics |
| Microsoft Clarity (`_clck`, `_clsk`) | Analytics |
| Segment CDP (`ajs_*`) | Analytics (downstream destinations may be advertising) |
| Internal telemetry (`navigator.sendBeacon` to own API) | Analytics |
| Error tracking (Sentry, Bugsnag — when collecting user context) | Analytics |

**ICO/CNIL position:** Analytics cookies always require consent, including first-party analytics. The "analytics exemption" proposed in the ePrivacy Regulation draft has not been adopted — the draft regulation has been stalled since 2017 with no adoption timeline, and should not be relied upon for compliance planning. Some DPAs (e.g., CNIL) allow limited analytics exemption for audience measurement tools that meet strict criteria (first-party only, no cross-site, limited retention, user information) — but this is jurisdiction-specific and narrow.

**Edge case — error tracking:** Error tracking tools (Sentry, Bugsnag) that collect only stack traces and error metadata without user identifiers may be classified as strictly necessary (monitoring the service the user requested). However, if they collect user context (IP, user ID, session data, breadcrumbs with PII), they are analytics. Check the SDK configuration.

> **⚠ Session Replay Warning**
>
> Session replay tools (HotJar, FullStory, Microsoft Clarity) remain classified as **Analytics** in the four-category model, but warrant elevated treatment:
>
> - **Data captured:** keystrokes, mouse movements, scroll behaviour, and full page content — including text typed into form fields, chat messages, and dynamically rendered PII.
> - **CNIL draft recommendation (Feb 2026, consultation open until April 2026):** CNIL published draft guidance on session replay requiring (1) prior explicit consent, (2) structured masking of all form fields and sensitive page areas by default, and (3) retention limits proportional to the stated analysis purpose. This is draft guidance, not final — but signals regulatory direction.
> - **Default audit severity:** classify session replay findings as **HIGH minimum** regardless of consent category. If replay captures unmasked form inputs, health data, or financial data, escalate to **CRITICAL**.
> - **Consent enforcement:** session replay scripts must not load before consent is granted. Inline `<script>` loading in document head (common with HotJar) is a pre-consent violation.

### 4. Advertising / Targeting

**Definition:** Cookies and trackers used for cross-context behavioural advertising, retargeting, conversion tracking, audience building, or any purpose related to showing personalised advertisements. Consent required. Under CCPA, opt-out mechanism required.

| Examples | Consent Category |
|----------|-----------------|
| Meta Pixel (`_fbp`, `_fbc`, `fbq(...)`) | Advertising |
| Google Ads (`_gcl_*`, `__gads`, `AW-` conversion tags) | Advertising |
| LinkedIn Insight Tag (`li_sugr`, `bcookie`) | Advertising |
| TikTok Pixel (`_ttp`, `ttq.track(...)`) | Advertising |
| Pinterest Tag (`_pinterest_sess`, `pintrk(...)`) | Advertising |
| Criteo (`cto_bundle`, `cto_lwid`) | Advertising |
| DoubleClick/Google Ad Manager (`IDE`, `test_cookie`, `.doubleclick.net`) | Advertising |
| Google AdSense (`__gads`, `__gpi`) | Advertising |
| Retargeting pixels (any vendor) | Advertising |
| Conversion tracking pixels (any vendor) | Advertising |
| Cross-site identifiers shared with ad networks | Advertising |
| Data enrichment services (LiveRamp, Oracle Data Cloud) | Advertising |
| Social sharing buttons that track before click (Facebook Like, Twitter embed) | Advertising |

**Key distinction — analytics vs. advertising:** The classification depends on data destination and purpose, not the function name in code:
- `gtag('event', 'page_view')` sent only to GA4 property → **Analytics**
- `gtag('event', 'conversion', {send_to: 'AW-...'})` sent to Google Ads → **Advertising**
- `analytics.track('Purchase')` sent to Segment → depends on Segment destinations. If forwarded to Meta Pixel or Google Ads → **Advertising** for those destinations.

---

## Classification Decision Tree

```
Is the cookie/tracker strictly necessary for the service the user explicitly requested?
├── YES → Does the service fail to function entirely without it?
│   ├── YES → STRICTLY NECESSARY (no consent needed)
│   └── NO → Re-evaluate: likely FUNCTIONAL
├── NO → Does it measure site usage, performance, or errors?
│   ├── YES → Does it share data with third parties for their own purposes?
│   │   ├── YES → ADVERTISING (consent + CCPA opt-out required)
│   │   └── NO → ANALYTICS (consent required)
│   └── NO → Does it enable cross-context behavioural advertising?
│       ├── YES → ADVERTISING (consent + CCPA opt-out required)
│       └── NO → Does it enhance functionality based on user choice?
│           ├── YES → FUNCTIONAL (consent required)
│           └── NO → UNKNOWN — flag for manual review
```

---

## Dual-Category Trackers

Some trackers serve multiple purposes and may need dual classification:

| Tracker | Primary Category | Secondary Category | How to Handle |
|---------|-----------------|-------------------|---------------|
| GA4 with Google Ads linking | Analytics | Advertising | If `AW-` ID is configured or Google Signals is enabled, classify as Advertising |
| Segment with advertising destinations | Analytics | Advertising | Classify Segment itself as Analytics; classify each advertising destination independently |
| Session replay with PII capture | Analytics | Requires elevated treatment (CNIL draft recommendation, Feb 2026) | CNIL draft guidance requires mandatory prior consent for session replay. Flag as HIGH minimum; escalate to CRITICAL if replay captures unmasked form inputs, health data, or financial data. |
| reCAPTCHA | Strictly necessary (bot protection) | Analytics (Google uses interaction data) | Flag dual purpose; strictly necessary justification requires Google's data use to be limited to bot protection |

---

## Data-Mapping Taxonomy → Consent Category Mapping

If using the data-mapping skill's PII Category Taxonomy as input:

| Data-Mapping Category | Typical Consent Category | Notes |
|-----------------------|-------------------------|-------|
| `session_data` | Strictly necessary (if auth) or Analytics | Depends on whether session data is used for tracking |
| `behavioral` | Analytics or Advertising | Depends on whether data is shared with ad networks |
| `identifier` | Varies by purpose | Auth identifier = strictly necessary; ad identifier = advertising |
| `consent_preference` | Strictly necessary | CMP consent state storage |
| `location` | Analytics or Advertising | IP-derived = analytics; precise GPS = likely advertising |
