# Cookie & Tracker Audit — E-Commerce with Marketing Stack Example

A worked example demonstrating the Cookie & Tracker Audit skill applied to a Next.js e-commerce application with a typical marketing technology stack.

---

## Input Description

A Next.js 14 e-commerce application for a fashion retailer with:

- **Authentication:** NextAuth.js with session cookies
- **Analytics:** Google Analytics 4 via `@next/third-parties` package, loaded in root layout
- **Advertising:** Meta Pixel loaded via `<Script>` component, Google Ads conversion tag via gtag
- **Session replay:** HotJar loaded via inline `<script>` in `_document.tsx`
- **CDP:** Segment `analytics-next` npm package, forwarding to GA4 + Klaviyo + Meta CAPI
- **CMP:** OneTrust banner configured, but analytics script loads before OneTrust initialises
- **Email:** Klaviyo tracking pixel on order confirmation page
- **Bot protection:** reCAPTCHA v3 on login and checkout forms
- **Server-side:** Meta Conversions API (CAPI) sends purchase events server-to-server
- **No GPC handling** — `Sec-GPC` header not checked anywhere

---

## Expected Output

### Cookie & Tracker Audit — Fashion Retailer E-Commerce

#### Summary
- **Total cookies found:** 14 (12 first-party domain, 2 third-party domain)
- **Third-party scripts:** 6
- **Tracking pixels/beacons:** 4
- **Fingerprinting techniques:** 1 (reCAPTCHA — dual purpose)
- **Server-side tracking:** 1 (Meta Conversions API)
- **Consent enforcement gaps:** 5
- **Pre-consent violations:** 3

#### Section 1: Cookie Inventory (key rows)

| Cookie Name | Domain | Set By | Expiry | Attributes | Purpose | Consent Category | Confidence |
|------------|--------|--------|--------|------------|---------|-----------------|------------|
| `next-auth.session-token` | 1P | Server (NextAuth) | 30 days | HttpOnly, Secure, SameSite=Lax | Session authentication | Strictly necessary | HIGH |
| `next-auth.csrf-token` | 1P | Server (NextAuth) | Session | HttpOnly, Secure, SameSite=Lax | CSRF protection | Strictly necessary | HIGH |
| `OptanonConsent` | 1P | Client (OneTrust) | 1 year | Secure, SameSite=Lax | CMP consent state | Strictly necessary | HIGH |
| `_ga` | 1P | Client (gtag.js) | 2 years | — | GA4 user identification | Analytics | HIGH |
| `_ga_G-XXXXXX` | 1P | Client (gtag.js) | 2 years | — | GA4 session tracking | Analytics | HIGH |
| `_gid` | 1P | Client (gtag.js) | 24 hours | — | GA4 session distinction | Analytics | HIGH |
| `_fbp` | 1P | Client (fbevents.js) | 90 days | — | Meta Pixel browser ID | Advertising | HIGH |
| `_fbc` | 1P | Client (fbevents.js) | 90 days | — | Meta click attribution | Advertising | HIGH |
| `_gcl_au` | 1P | Client (gtag.js) | 90 days | — | Google Ads attribution | Advertising | HIGH |
| `fr` | 3P — .facebook.com | Third-party | 90 days | — | Meta advertising ID | Advertising | HIGH |
| `_hjSessionUser_*` | 1P | Client (hotjar.js) | 1 year | — | HotJar user identification | Analytics | HIGH |
| `_hjSession_*` | 1P | Client (hotjar.js) | 30 min | — | HotJar session tracking | Analytics | HIGH |
| `li_sugr` | 3P — .linkedin.com | Third-party | 90 days | — | LinkedIn Insight tracking | Advertising | MEDIUM |
| `ajs_anonymous_id` | 1P | Client (Segment) | 1 year | — | Segment anonymous user ID | Analytics | HIGH |

**Findings:**
- `_ga` cookie has 2-year expiry — exceeds CNIL 13-month maximum (HIGH)
- `_ga`, `_fbp`, `_gcl_au`, `_hjSessionUser_*` missing HttpOnly/Secure attributes (MEDIUM)
- 8 third-party domain cookies identified from `.facebook.com` and `.linkedin.com`

#### Section 2: Third-Party Script Inventory (key rows)

| Script/SDK | Vendor | Load Method | Data Transmitted | Consent Category | Consent Gate? | Confidence |
|-----------|--------|-------------|------------------|-----------------|---------------|------------|
| `gtag.js (G-XXXXXX)` | Google | `<Script strategy="afterInteractive">` in root layout | Page URL, user agent, events, user ID | Analytics | No — loads before OneTrust | HIGH |
| `fbevents.js` | Meta | `<Script>` component in root layout | Page URL, device ID, purchase events | Advertising | No — loads before OneTrust | HIGH |
| `gtag.js (AW-XXXXXX)` | Google Ads | Shared gtag with GA4 | Conversion events, order value | Advertising | No — shared script with GA4 | HIGH |
| `hotjar-*.js` | HotJar | Inline `<script>` in `_document.tsx` | Mouse movements, clicks, scrolls, page content, form inputs | Analytics | No — inline script in document head | HIGH |
| `analytics.min.js` | Segment | npm import (`@segment/analytics-next`) | User traits, page views, events | Analytics | No — initialised in app bootstrap | HIGH |
| `li.lms-analytics/insight.min.js` | LinkedIn | `<Script>` component in root layout | Page URL, LinkedIn member ID | Advertising | No | HIGH |

**Critical finding:** All 6 third-party scripts load without consent gates. OneTrust banner renders, but scripts are already loaded and executing before OneTrust initialises.

#### Section 3: Pixel & Beacon Inventory (key rows)

| Pixel/Beacon | Vendor | Type | Trigger | Data Payload | Consent Category | Consent Gate? | Confidence |
|-------------|--------|------|---------|-------------|-----------------|---------------|------------|
| `fbq('track', 'PageView')` | Meta | Script API | Every page load | Page URL, fbp cookie, user agent | Advertising | No | HIGH |
| `fbq('track', 'Purchase')` | Meta | Script API | Order confirmation | Value, currency, content_ids, user email (hashed) | Advertising | No | HIGH |
| `gtag('event', 'conversion', {send_to: 'AW-...'})` | Google Ads | Script API | Order confirmation | Conversion value, order ID | Advertising | No | HIGH |
| `analytics.track('Order Completed')` | Segment | fetch POST | Order confirmation | Order value, items, user ID, email | Analytics (but forwarded to advertising destinations) | No | HIGH |

#### Section 4: Fingerprinting & Advanced Tracking

| Technique | Code Evidence | Purpose | Consent Category | Consent Gate? | Severity | Confidence |
|-----------|--------------|---------|-----------------|---------------|----------|------------|
| reCAPTCHA v3 risk scoring | `grecaptcha.execute()` in `login.tsx:34`, `checkout.tsx:78` | Bot protection + Google uses interaction data | Dual: strictly necessary (bot protection) + analytics (Google data use) | No — loads unconditionally | MEDIUM | HIGH |

**Note:** reCAPTCHA v3 is a dual-purpose tracker. Bot protection justifies strictly necessary classification, but Google's privacy policy states reCAPTCHA data may be used for "improving Google products and services." Flag dual purpose for legal review.

#### Web Storage Usage

| Storage Type | Key | Purpose | Contains Identifier? | Consent Category | Confidence |
|-------------|-----|---------|---------------------|-----------------|------------|
| localStorage | `ajs_anonymous_id` | Segment anonymous user identification | Yes (UUID) | Analytics | HIGH |
| localStorage | `ajs_user_id` | Segment identified user | Yes (user ID) | Analytics | HIGH |
| localStorage | `_hjSessionUser_*` | HotJar user identification backup | Yes (UUID) | Analytics | HIGH |

#### Section 5: Server-Side Tracking

| Mechanism | Cookie/Endpoint | Data Transmitted | Bypasses Client Consent? | Consent Gate? | Severity | Confidence |
|-----------|----------------|------------------|-------------------------|---------------|----------|------------|
| Meta Conversions API | `POST graph.facebook.com/v18.0/[pixel-id]/events` | Hashed email, hashed phone, event name, value, currency, IP, user agent | Yes — fires from server regardless of client consent state | No | HIGH | HIGH |

**Critical finding:** Meta CAPI sends purchase events server-to-server with hashed PII. This bypasses the client-side consent mechanism entirely — even if the user refuses advertising cookies on the CMP, Meta still receives purchase data with hashed identifiers.

#### Section 6: Consent Enforcement Matrix (key rows)

| Tracker | Consent Category | Pre-Consent? | Consent Gate | Withdrawal Cleans Up? | Gap? | Severity | Confidence |
|---------|-----------------|-------------|-------------|----------------------|------|----------|------------|
| GA4 (`_ga`, `_gid`) | Analytics | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| Meta Pixel (`_fbp`, `fbq`) | Advertising | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| Google Ads (`_gcl_au`, conversion) | Advertising | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| HotJar (`_hj*`) | Analytics | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| Segment (`ajs_*`) | Analytics | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| LinkedIn Insight | Advertising | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| Meta CAPI (server-side) | Advertising | N/A (server) | NONE | N/A | Yes | HIGH | HIGH |
| NextAuth session | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |
| CSRF token | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |
| OneTrust consent | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |
| reCAPTCHA v3 | Dual | No (form-only) | No | No | Partial | MEDIUM | HIGH |

#### Section 7: Recommended Fixes (top items)

1. **[BLOCKING]** Fix OneTrust script loading order — move all analytics and advertising scripts behind OneTrust consent gate. Use OneTrust's `optanon-category-*` class or consent callback API to conditionally load scripts only after consent is granted. Currently all scripts load before OneTrust initialises. — CRITICAL, HIGH confidence
2. **[BLOCKING]** Gate Meta Conversions API on consent — add server-side consent check before firing CAPI events. Query the user's consent state (from consent cookie or database) before sending purchase data to Meta. Server-side tracking that bypasses client consent is a consent enforcement gap. — HIGH, HIGH confidence
3. **[BLOCKING]** Implement GPC signal handling — check `Sec-GPC` header in middleware and suppress advertising trackers (Meta Pixel, Google Ads, LinkedIn Insight) when GPC is set. Per CCPA §7025, GPC must be honoured for sale and sharing opt-out. — HIGH, HIGH confidence
4. **[BLOCKING]** Add consent gate for HotJar — move inline script from `_document.tsx` to a consent-gated loader. HotJar captures mouse movements, clicks, scrolls, and page content including form inputs — it must not operate without analytics consent. — CRITICAL, HIGH confidence
5. **[BLOCKING]** Add consent-gated Segment initialisation — defer `analytics.load()` until analytics consent is granted. Configure Segment to also gate advertising destinations (Meta CAPI, Klaviyo) on advertising consent separately. — CRITICAL, HIGH confidence
6. Reduce `_ga` cookie expiry from 2 years to 13 months maximum to comply with CNIL guidelines — HIGH, HIGH confidence
7. Add Secure and SameSite attributes to all first-party tracking cookies (`_ga`, `_fbp`, `_gcl_au`, `_hjSessionUser_*`) — MEDIUM, HIGH confidence
8. Implement consent withdrawal cleanup — when user withdraws analytics or advertising consent, delete corresponding cookies and clear localStorage entries (`ajs_anonymous_id`, `ajs_user_id`, `_hjSessionUser_*`) — HIGH, HIGH confidence
9. Flag reCAPTCHA v3 dual purpose in cookie notice — disclose that reCAPTCHA data may be used by Google beyond bot protection — MEDIUM, HIGH confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| CMP present but scripts load before CMP initialises | Steps 2, 6 | OneTrust is installed, creating a false sense of compliance, but all trackers fire before it renders. The CMP is decorative — it collects consent choices but does not enforce them. This is a common pattern and a CRITICAL finding. |
| Meta CAPI bypasses client consent | Step 5 | Server-side tracking specifically designed to operate independently of client-side cookie blocking. Even a perfectly configured CMP does not prevent server-to-server data transmission. Consent must be checked server-side before CAPI events fire. |
| HotJar in document head | Steps 2, 6 | Inline scripts in `_document.tsx` (Next.js) load before any React component — including the CMP. This is a structural problem: HotJar captures PII (form inputs, text content) without consent. |
| Segment as hidden advertising pipeline | Steps 2, 3 | Segment is classified as analytics, but it forwards data to Meta (via CAPI destination) and Klaviyo. The downstream destinations determine the true consent category — Segment-to-Meta is advertising, not analytics. |
| No GPC handling with active advertising | Step 6 | Five advertising trackers active with no GPC signal detection. CCPA §7025 requires GPC to be honoured as a valid opt-out. |
| GA4 cookie exceeds 13-month maximum | Step 1 | Google's default `_ga` cookie expiry is 2 years. CNIL guidelines cap cookie duration at 13 months. This is a configuration fix — set `cookie_expires` in gtag config. |
