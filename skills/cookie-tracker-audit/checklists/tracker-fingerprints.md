# Common Tracker Fingerprint Reference

Known cookie patterns, script signatures, and pixel identifiers for common tracking vendors. Use this checklist when performing Steps 1-3 (Cookie Inventory, Third-Party Script Inventory, Pixel & Beacon Detection) of the Cookie & Tracker Audit.

---

## Analytics Vendors

### Google Analytics 4 (GA4)

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_ga` (2 years), `_ga_<container-id>` (2 years), `_gid` (24 hours), `_gac_<property-id>` (90 days) | Analytics |
| **Script** | `gtag.js` from `googletagmanager.com/gtag/js`, `analytics.js` (legacy UA) from `google-analytics.com/analytics.js` | Analytics |
| **npm** | `@google-analytics/data`, `react-ga4`, `vue-gtag` | Analytics |
| **Pixel/Beacon** | `POST` to `google-analytics.com/g/collect` or `analytics.google.com/g/collect` | Analytics |
| **Code patterns** | `gtag('config', 'G-...')`, `gtag('event', ...)`, `window.dataLayer.push(...)` | Analytics |
| **Server-side** | Google Measurement Protocol: `POST` to `www.google-analytics.com/mp/collect` with `api_secret` parameter | Analytics |

### Plausible Analytics

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | None (cookieless by design) | Analytics |
| **Script** | `plausible.io/js/script.js` or self-hosted variant | Analytics |
| **npm** | `plausible-tracker` | Analytics |
| **Code patterns** | `plausible(...)`, `<script data-domain="..." src=".../plausible.js">` | Analytics |
| **Note** | Cookieless but still processes personal data (IP address, User-Agent). Some DPAs consider this sufficient for analytics exemption; others do not. Flag as requiring legal review. | — |

### Mixpanel

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `mp_<token>_mixpanel` (1 year), `mp_optout` | Analytics |
| **Script** | `cdn.mxpnl.com/libs/mixpanel-*` | Analytics |
| **npm** | `mixpanel-browser`, `mixpanel` | Analytics |
| **Code patterns** | `mixpanel.init(...)`, `mixpanel.track(...)`, `mixpanel.identify(...)`, `mixpanel.people.set(...)` | Analytics |

### PostHog

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `ph_<token>_posthog` (1 year) — or none if `persistence: "memory"` | Analytics |
| **Script** | `us.i.posthog.com/static/array.js` or `eu.i.posthog.com/static/array.js` | Analytics |
| **npm** | `posthog-js`, `posthog-node` | Analytics |
| **Code patterns** | `posthog.init(...)`, `posthog.capture(...)`, `posthog.identify(...)`, `posthog.opt_out_capturing()` | Analytics |
| **Note** | `persistence: "memory"` mode avoids cookies/localStorage — check init config | — |

### Amplitude

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `AMP_<api-key>` (10 years default — flag expiry), `amp_*` | Analytics |
| **Script** | `cdn.amplitude.com/libs/amplitude-*` | Analytics |
| **npm** | `@amplitude/analytics-browser`, `amplitude-js` | Analytics |
| **Code patterns** | `amplitude.init(...)`, `amplitude.track(...)`, `amplitude.setUserId(...)` | Analytics |

---

## Advertising Vendors

### Meta Pixel (Facebook)

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_fbp` (90 days), `_fbc` (90 days), `fr` (90 days, third-party `.facebook.com`) | Advertising |
| **Script** | `connect.facebook.net/en_US/fbevents.js` | Advertising |
| **npm** | `react-facebook-pixel` (community) | Advertising |
| **Pixel** | `fbq('init', ...)`, `fbq('track', 'PageView')`, `fbq('track', 'Purchase', {value, currency})` | Advertising |
| **Server-side** | Meta Conversions API: `POST` to `graph.facebook.com/v*/[pixel-id]/events` with `access_token` | Advertising |
| **Code patterns** | `fbq(...)`, `window.fbq`, `<noscript><img src="facebook.com/tr?...">` | Advertising |

### Google Ads

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_gcl_au` (90 days), `_gcl_aw` (90 days), `_gac_*` (90 days), `__gads` (13 months), `__gpi` (13 months) | Advertising |
| **Script** | `googletagmanager.com/gtag/js` (shared with GA4 — check config for `AW-` conversion ID) | Advertising |
| **Pixel** | `gtag('event', 'conversion', {send_to: 'AW-...'})`, `gtag('event', 'purchase', ...)` | Advertising |
| **Code patterns** | `AW-` prefixed IDs in gtag config, `google_conversion_*` variables, `googleadservices.com/pagead/conversion/` | Advertising |

### LinkedIn Insight Tag

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `li_sugr` (90 days), `bcookie` (1 year), `lidc` (24 hours), `UserMatchHistory` (30 days) — third-party `.linkedin.com` | Advertising |
| **Script** | `snap.licdn.com/li.lms-analytics/insight.min.js` | Advertising |
| **Code patterns** | `_linkedin_partner_id`, `window.lintrk`, `lintrk('track', {conversion_id: ...})` | Advertising |

### TikTok Pixel

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_ttp` (13 months), `_tt_enable_cookie` (13 months) | Advertising |
| **Script** | `analytics.tiktok.com/i18n/pixel/events.js` | Advertising |
| **Code patterns** | `ttq.load(...)`, `ttq.track(...)`, `ttq.identify(...)`, `ttq.page()` | Advertising |

### Pinterest Tag

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_pinterest_sess` (1 year), `_pin_unauth` (1 year) | Advertising |
| **Script** | `s.pinimg.com/ct/core.js` | Advertising |
| **Code patterns** | `pintrk('load', ...)`, `pintrk('track', ...)`, `pintrk('page')` | Advertising |

---

## Session Replay & Heatmap Vendors

### HotJar

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_hj*` family: `_hjSessionUser_<id>` (1 year), `_hjSession_<id>` (30 min), `_hjAbsoluteSessionInProgress` (30 min), `_hjIncludedInSessionSample_<id>` | Analytics |
| **Script** | `static.hotjar.com/c/hotjar-*.js` | Analytics |
| **npm** | `@hotjar/browser` | Analytics |
| **Code patterns** | `hj('identify', ...)`, `hj('stateChange', ...)`, `hj('event', ...)`, Hotjar site ID in config | Analytics |
| **Note** | Session replay captures keystrokes, mouse movements, and full page content — constitutes processing of personal data even without explicit PII fields. CNIL published draft session replay guidance (Feb 2026, consultation open until April 2026) requiring prior consent, structured masking, and retention limits. Default audit severity: **HIGH minimum**. Escalate to CRITICAL if replay captures unmasked form inputs, health data, or financial data. | — |

### FullStory

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `fs_uid` (1 year) | Analytics |
| **Script** | `fullstory.com/s/fs.js` | Analytics |
| **npm** | `@fullstory/browser` | Analytics |
| **Code patterns** | `FS.init(...)`, `FS.identify(...)`, `FS.event(...)`, `FS.setUserVars(...)` | Analytics |
| **Note** | Session replay tool — same elevated treatment as HotJar. CNIL draft session replay guidance (Feb 2026) applies. Default audit severity: **HIGH minimum**. FullStory captures DOM mutations, clicks, and form interactions. | — |

### Microsoft Clarity

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `_clck` (1 year), `_clsk` (1 day), `CLID` (1 year) | Analytics |
| **Script** | `clarity.ms/tag/` | Analytics |
| **Code patterns** | `clarity('set', ...)`, `clarity('identify', ...)`, `clarity('consent')` | Analytics |
| **Note** | Session replay tool — same elevated treatment as HotJar. CNIL draft session replay guidance (Feb 2026) applies. Default audit severity: **HIGH minimum**. Clarity captures clicks, scroll, and page content. Note: `clarity('consent')` signals user consent to Clarity but does not gate loading — the script must still be consent-gated at load time. | — |

---

## Customer Data Platforms (CDPs)

### Segment

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `ajs_user_id` (1 year), `ajs_anonymous_id` (1 year), `ajs_group_id` (1 year) | Analytics (but downstream destinations determine final category) |
| **Script** | `cdn.segment.com/analytics.js/v1/<write-key>/analytics.min.js` | Analytics |
| **npm** | `@segment/analytics-next`, `analytics-node` | Analytics |
| **Code patterns** | `analytics.identify(...)`, `analytics.track(...)`, `analytics.page(...)`, `analytics.group(...)` | Analytics |
| **Note** | Segment is a CDP — it forwards data to downstream destinations. Each destination (Google Analytics, Meta Pixel, Amplitude, etc.) must be classified independently. Segment itself may qualify as a service provider, but its destinations may not. | — |

### Rudderstack

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `rl_user_id`, `rl_trait`, `rl_anonymous_id`, `rl_group_id`, `rl_group_trait` | Analytics |
| **npm** | `rudder-sdk-js`, `@rudderstack/analytics-js` | Analytics |
| **Code patterns** | `rudderanalytics.identify(...)`, `rudderanalytics.track(...)`, `rudderanalytics.page(...)` | Analytics |

---

## Tag Managers

### Google Tag Manager (GTM)

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | None directly (but loads tags that set cookies) | N/A (container — classify loaded tags individually) |
| **Script** | `googletagmanager.com/gtm.js?id=GTM-*` | N/A |
| **Code patterns** | `window.dataLayer = window.dataLayer \|\| []`, `dataLayer.push(...)`, `GTM-` container ID | N/A |
| **Note** | GTM itself is a tag container — it does not track users. But tags loaded via GTM (GA4, Meta Pixel, etc.) do. The audit must identify all tags deployed through GTM. If GTM container JSON is available, parse it for tag inventory. If not, flag as RUNTIME-DEPENDENT (LOW confidence for tags loaded only via GTM). | — |

---

## Consent Management Platforms (CMPs)

### OneTrust

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `OptanonConsent` (1 year), `OptanonAlertBoxClosed` (1 year), `eupubconsent-v2` (TCF — v2.2 strings pre-Feb 2026 remain valid; new strings must be v2.3 per IAB mandate effective Feb 28, 2026) | Strictly necessary |
| **Script** | `cdn.cookielaw.org/scripttemplates/otSDKStub.js` | Strictly necessary |
| **Code patterns** | `OneTrust.ToggleInfoDisplay()`, `OptanonWrapper()`, `OneTrust.IsAlertBoxClosed()` | Strictly necessary |

### Cookiebot

| Signal | Pattern | Consent Category |
|--------|---------|-----------------|
| **Cookies** | `CookieConsent` (1 year) | Strictly necessary |
| **Script** | `consent.cookiebot.com/uc.js` | Strictly necessary |
| **Code patterns** | `Cookiebot.consent.marketing`, `Cookiebot.consent.statistics`, `Cookiebot.consent.preferences` | Strictly necessary |

### CMP Consent Cookies (generic)

CMP cookies that store the user's consent choice are classified as **strictly necessary** — they are required for the consent mechanism itself to function. Common patterns:

| Cookie Pattern | Purpose | Strictly Necessary? |
|---------------|---------|-------------------|
| `*consent*`, `*cookie_consent*` | Stores consent choice | Yes |
| `*opt_out*`, `*optout*` | Stores opt-out preference | Yes |
| `*tcf*`, `*eupubconsent*` | IAB TCF consent string | Yes |
| `*cc_cookie*` | Cookie consent state | Yes |

---

## Fingerprinting API Patterns

These are not vendor-specific but indicate fingerprinting techniques. Any code using these APIs for tracking purposes (not core functionality) should be flagged.

| API | Fingerprinting Technique | Code Pattern |
|-----|------------------------|-------------|
| `canvas.toDataURL()` | Canvas fingerprinting | Draw hidden canvas, extract as data URL, hash the result |
| `canvas.toBlob()` | Canvas fingerprinting | Alternative to `toDataURL()` |
| `gl.getParameter()` | WebGL fingerprinting | Query `RENDERER`, `VENDOR`, `UNMASKED_RENDERER_WEBGL`, `UNMASKED_VENDOR_WEBGL` |
| `gl.getExtension()` | WebGL fingerprinting | Enumerate supported WebGL extensions |
| `new AudioContext()` | AudioContext fingerprinting | Create oscillator, process audio, extract frequency data |
| `navigator.plugins` | Plugin enumeration | Iterate plugin list (deprecated but still used) |
| `navigator.hardwareConcurrency` | Hardware profiling | CPU core count |
| `navigator.deviceMemory` | Hardware profiling | Device RAM estimate |
| `navigator.maxTouchPoints` | Device profiling | Touch capability detection |
| `screen.width`, `screen.height` | Screen fingerprinting | Screen dimensions + `screen.colorDepth` |
| `Intl.DateTimeFormat().resolvedOptions().timeZone` | Timezone fingerprinting | Precise timezone string |
| `document.fonts.check()` | Font enumeration | Test for presence of specific fonts |
| `navigator.connection` | Network profiling | Connection type, downlink speed, RTT |

**Known fingerprinting libraries:** FingerprintJS (`@fingerprintjs/fingerprintjs`), ClientJS (`clientjs`), Valve's `fingerprintjs2`. Import of these libraries is HIGH confidence fingerprinting.
