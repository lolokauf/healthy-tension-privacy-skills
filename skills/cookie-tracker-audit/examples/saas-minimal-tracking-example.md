# Cookie & Tracker Audit — SaaS Application with Minimal Tracking Example

A worked example demonstrating the Cookie & Tracker Audit skill applied to a SaaS application with intentionally minimal tracking — showing that even privacy-conscious applications have findings.

---

## Input Description

A React + Express SaaS application (project management tool) with:

- **Authentication:** express-session with PostgreSQL store, HttpOnly session cookie
- **Analytics:** Plausible Analytics (self-hosted, cookieless mode) loaded via `<script>` tag
- **Error tracking:** Sentry with user context (`userId`, `email`) in breadcrumbs
- **No advertising trackers** — no Meta Pixel, Google Ads, LinkedIn, etc.
- **No session replay** — no HotJar, FullStory, etc.
- **No CMP** — application does not use a consent banner
- **PostHog** recently added by a developer for feature flag evaluation, using `persistence: "localStorage"`
- **CSRF token** via CSRF middleware (double-submit cookie pattern)
- **Rate limiting** via `express-rate-limit` with IP-based Redis store

---

## Expected Output

### Cookie & Tracker Audit — SaaS Project Management Tool

#### Summary
- **Total cookies found:** 3 (3 first-party, 0 third-party)
- **Third-party scripts:** 2 (Plausible self-hosted, Sentry)
- **Tracking pixels/beacons:** 1 (PostHog capture events)
- **Fingerprinting techniques:** 0
- **Server-side tracking:** 0
- **Consent enforcement gaps:** 2
- **Pre-consent violations:** 2

#### Section 1: Cookie Inventory

| Cookie Name | Domain | Set By | Expiry | Attributes | Purpose | Consent Category | Confidence |
|------------|--------|--------|--------|------------|---------|-----------------|------------|
| `connect.sid` | 1P | Server (express-session) | 24 hours | HttpOnly, Secure, SameSite=Lax | Session authentication | Strictly necessary | HIGH |
| `_csrf` | 1P | Server (CSRF middleware) | Session | HttpOnly, Secure, SameSite=Strict | CSRF protection | Strictly necessary | HIGH |
| `ph_phc_*_posthog` | 1P | Client (posthog-js) | 1 year | — | PostHog device identification | Analytics | HIGH |

**Findings:**
- PostHog cookie set despite `persistence: "localStorage"` configuration — check PostHog init options. If `persistence` is set to `"localStorage"`, the cookie should not be set. Verify PostHog version and configuration. (MEDIUM confidence — may be a configuration error)
- Only 3 cookies total — minimal cookie footprint

#### Section 2: Third-Party Script Inventory

| Script/SDK | Vendor | Load Method | Data Transmitted | Consent Category | Consent Gate? | Confidence |
|-----------|--------|-------------|------------------|-----------------|---------------|------------|
| `plausible.js` (self-hosted) | Plausible | `<script data-domain>` in index.html | Page URL, referrer, user agent, screen size (no cookies, IP not stored) | Analytics | No — loads on every page | HIGH |
| `@sentry/browser` | Sentry | npm import, initialised in `app.tsx` | Error stack traces, user context (userId, email), breadcrumbs (page URLs, clicks, console logs) | Analytics | No — initialised at app bootstrap | HIGH |

#### Section 3: Pixel & Beacon Inventory

| Pixel/Beacon | Vendor | Type | Trigger | Data Payload | Consent Category | Consent Gate? | Confidence |
|-------------|--------|------|---------|-------------|-----------------|---------------|------------|
| `posthog.capture()` | PostHog | fetch POST to `eu.i.posthog.com` | Event name, properties, distinct_id, device_id, IP, user agent | Analytics | No — captures events unconditionally | HIGH |

#### Section 4: Fingerprinting & Advanced Tracking

| Technique | Code Evidence | Purpose | Consent Category | Consent Gate? | Severity | Confidence |
|-----------|--------------|---------|-----------------|---------------|----------|------------|
| None identified | — | — | — | — | — | — |

#### Web Storage Usage

| Storage Type | Key | Purpose | Contains Identifier? | Consent Category | Confidence |
|-------------|-----|---------|---------------------|-----------------|------------|
| localStorage | `ph_phc_*_posthog` | PostHog device identification, feature flag cache | Yes (distinct_id UUID) | Analytics | HIGH |
| localStorage | `sentry-*` | Sentry session replay ID (if enabled) | Possibly (session ID) | Analytics | MEDIUM |

#### Section 5: Server-Side Tracking

| Mechanism | Cookie/Endpoint | Data Transmitted | Bypasses Client Consent? | Consent Gate? | Severity | Confidence |
|-----------|----------------|------------------|-------------------------|---------------|----------|------------|
| Rate limiter IP logging | Redis store | IP address, request count, timestamps | Yes — server middleware, no consent concept | N/A (security) | LOW | HIGH |

**Note:** The rate limiter stores IP addresses in Redis for abuse prevention. This is a security mechanism and likely qualifies as strictly necessary (legitimate interest for service protection). However, IP addresses are personal data under GDPR — document the processing in the privacy notice.

#### Section 6: Consent Enforcement Matrix

| Tracker | Consent Category | Pre-Consent? | Consent Gate | Withdrawal Cleans Up? | Gap? | Severity | Confidence |
|---------|-----------------|-------------|-------------|----------------------|------|----------|------------|
| Plausible (self-hosted) | Analytics | Yes | NONE | N/A | Yes | HIGH | HIGH |
| Sentry (with user context) | Analytics | Yes | NONE | N/A | Yes | HIGH | HIGH |
| PostHog | Analytics | Yes | NONE | N/A | Yes | CRITICAL | HIGH |
| express-session | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |
| CSRF token | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |
| Rate limiter | Strictly necessary | N/A | N/A | N/A | No | — | HIGH |

#### Strictly Necessary Justifications

| Tracker | Claimed Justification | User-Requested Service | Service Cannot Function Without? | Valid? | Confidence |
|---------|----------------------|----------------------|--------------------------------|--------|------------|
| `connect.sid` | Session authentication | Authenticated project management app | Yes — stateful auth requires server session | Yes | HIGH |
| `_csrf` | CSRF protection | Form submission across the app | Yes — CSRF tokens are a security necessity for stateful forms | Yes | HIGH |
| Rate limiter | Abuse prevention | All endpoints | Yes — without rate limiting, the service is vulnerable to abuse/DoS | Yes (but document IP processing in privacy notice) | HIGH |

#### Section 7: Recommended Fixes (ordered by severity)

1. **[BLOCKING]** Add consent mechanism for PostHog — PostHog sets cookies, writes to localStorage, and sends behavioural data (page views, clicks, custom events) to `eu.i.posthog.com`. This is analytics tracking that requires consent under ePrivacy Art. 5(3). Either: (a) add a consent banner gating PostHog initialisation, or (b) configure PostHog with `persistence: "memory"` AND `opt_out_capturing_by_default: true` and only enable after consent. — CRITICAL, HIGH confidence
2. **[BLOCKING]** Gate Sentry user context on consent — Sentry with `setUser({id, email})` and breadcrumbs containing page URLs and click targets constitutes analytics processing of personal data. Option A: remove user context and PII from Sentry config (stack traces without user context may qualify as strictly necessary error monitoring). Option B: add consent gate for Sentry with user context enabled. — HIGH, HIGH confidence
3. Add consent mechanism or legal basis documentation for Plausible — while Plausible is cookieless and privacy-friendly, it still processes IP addresses and user agents. Some DPAs (CNIL) provide a narrow analytics exemption for audience measurement tools meeting strict criteria. Document the legal basis (exemption or legitimate interest) and present it for legal review. If exemption does not apply, add consent gate. — HIGH, HIGH confidence
4. Review PostHog configuration — `persistence: "localStorage"` still creates localStorage entries with device identifiers. If feature flags are the only use case, consider `persistence: "memory"` to eliminate persistent identifiers entirely. — HIGH, HIGH confidence
5. Add privacy notice disclosure for IP-based rate limiting — rate limiter stores IP addresses in Redis, which constitutes processing of personal data. Disclose in privacy notice under "security measures" or similar. — LOW, HIGH confidence
6. Clean up PostHog cookie — if `persistence: "localStorage"` is correctly configured, the `ph_*_posthog` cookie should not be set. Investigate whether PostHog version or configuration is causing unexpected cookie creation. — MEDIUM, MEDIUM confidence

---

## Key Findings Demonstrated

| Finding | Step | Why It Matters |
|---------|------|---------------|
| No CMP + analytics trackers = consent gap | Step 6 | Even privacy-conscious applications need consent mechanisms when they process personal data for analytics. The absence of a CMP is itself a finding when analytics trackers are present. |
| Plausible is cookieless but not consent-free | Steps 2, 6 | "Cookieless" does not mean "no consent required." Plausible processes IP addresses (personal data under GDPR). The CNIL analytics exemption is narrow and jurisdiction-specific — it cannot be assumed. |
| Sentry with user context crosses the line | Step 2 | Sentry for error monitoring (stack traces only) may be strictly necessary. Sentry with `setUser({id, email})` and behavioural breadcrumbs is analytics. The configuration determines the consent category, not the tool name. |
| PostHog added without privacy review | Steps 1, 3, 6 | A developer added PostHog for feature flags without a privacy review. This introduced a cookie, localStorage entries, and behavioural event capture — all requiring consent. This demonstrates tracker drift: new tracking added incrementally without review. |
| Rate limiter IP processing | Step 5 | Even security mechanisms process personal data. IP addresses stored in Redis for rate limiting should be disclosed in the privacy notice. Not a consent issue (strictly necessary), but a transparency requirement. |
| Minimal tracker footprint still has findings | All | This application has zero advertising trackers, zero session replay, and zero fingerprinting — yet it has 6 recommended fixes. Privacy-conscious applications are not automatically compliant. The skill surfaces findings even in well-intentioned codebases. |
