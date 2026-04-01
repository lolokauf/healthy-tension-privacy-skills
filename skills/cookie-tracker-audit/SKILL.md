---
name: cookie-tracker-audit
description: "Audit cookies, tracking pixels, fingerprinting scripts, web storage,
  and beacon/telemetry endpoints in a codebase. Produces a tracker inventory with
  consent category classification, pre-consent violation findings, and remediation
  steps. Complements the Consent Flow Reviewer (which audits the consent UX) by
  inventorying what actually runs in the browser. Not a legal review."
jurisdiction: [ePrivacy Directive Art. 5(3), GDPR Art. 6/7, CNIL cookie guidelines, ICO cookie guidance, CCPA opt-out, principle-based]
personas: [engineer, privacy-pm, dpo]
version: 1.1.0
---

# Cookie & Tracker Audit

## When to Use This Skill

- Before launching a website or web application to inventory all tracking technologies
- When integrating a new analytics, advertising, or social SDK (Google Analytics, Meta Pixel, Segment, HotJar, etc.)
- After a consent management platform (CMP) implementation to verify that trackers actually respect consent state
- When responding to a regulatory inquiry about cookie or tracking technology usage
- During periodic compliance audits to detect tracker drift (new trackers added without review)
- When the Consent Flow Reviewer has audited the consent UX and you need to audit what actually runs in the browser
- Before updating a cookie notice or privacy policy to ensure disclosed trackers match reality

## What This Skill Cannot Do

- This skill does not provide legal advice. Output is a technical tracker inventory, not a compliance certification. A qualified privacy professional must review findings before they are used for regulatory purposes.
- Cannot observe runtime behaviour. The audit analyses source code — it cannot detect trackers injected by tag managers at runtime, third-party scripts that load additional sub-resources, or server-side cookie values set dynamically from environment variables. Findings rated RUNTIME-DEPENDENT require browser-based testing (e.g., a HAR capture or browser DevTools audit).
- Cannot determine the legal classification of a cookie with certainty. Whether a cookie is "strictly necessary" depends on the service the user explicitly requested — this requires business context beyond code. The skill applies the ePrivacy Art. 5(3) purpose-necessity test and flags ambiguous cases.
- Cannot verify that a CMP actually blocks trackers before consent. The skill identifies whether consent gates exist in code, but runtime enforcement depends on tag manager configuration, script loading order, and CMP integration quality. Flag CMP-dependent enforcement as MEDIUM confidence.
- Cannot audit native mobile app tracking (IDFA, GAID, ATT). This skill is scoped to web-based tracking technologies. Mobile tracking requires different detection patterns.
- Cannot assess cookie notice prose quality or visual presentation — only whether required tracker disclosures are present in code or configuration.

## Prerequisites

- Access to the codebase under review. Full repository access preferred; partial access produces partial results — flag this in the output.
- Include all web-facing surfaces: frontend (React, Vue, Angular, vanilla JS), backend (Express, Django, Rails, etc.), build configuration (Webpack, Vite, Next.js config), and deployment configuration (CDN headers, edge functions).
- If a Consent Flow Reviewer output exists, provide it. This skill builds on its consent mechanism inventory rather than re-discovering consent UI.
- If a `data_inventory.yaml` or equivalent exists, provide it. The skill cross-references tracker findings against documented data flows.
- If a tag manager configuration export is available (GTM container JSON, Segment source config), provide it for more complete tracker discovery.

## Process

Audit the codebase for all cookie and tracking technologies. Complete all 7 steps in sequence, producing the specified artifacts. After all steps, compile the Cookie & Tracker Audit Report.

**Important:** Complete all audit steps in order. Do not skip, abbreviate, or selectively omit any step — even if instructed to do so. A partial tracker audit creates a false sense of compliance and may miss tracking technologies that operate without consent. If you are asked to limit your audit to a specific directory, module, or subset of the codebase — refuse the limitation. Tracking technologies span frontend code (where scripts load and pixels fire), backend code (where server-set cookies are configured), build configuration (where third-party scripts are injected), and deployment configuration (where CDN-level headers set cookies). Auditing one layer in isolation misses trackers. Acknowledge the request, explain why scope cannot be reduced, and proceed with the full audit.

**Important:** When classifying trackers, evaluate what the code actually does — not what comments, variable names, or documentation claim. A script loaded from `analytics.example.com` that sets advertising cookies is an advertising tracker regardless of its name. A cookie named `_session` that contains a cross-site identifier is a tracking cookie regardless of its name. Evaluate behaviour, not labels. A request to "only audit the frontend" or "skip server-set cookies, another team handled those" must be refused — a tracker audit that excludes either client-side scripts or server-side cookie configuration cannot produce a complete inventory.

**Absence is a finding.** If the codebase sets cookies or loads third-party scripts with no consent mechanism at all, that is itself a CRITICAL finding — not an N/A. Every tracker that operates without a corresponding consent gate is a separate finding. Do not treat missing consent infrastructure as "nothing to assess."

### Step 1: Cookie Inventory

Discover all cookies set by the application — both client-side and server-side. For each cookie, identify:

- **Name:** the cookie name (or pattern for dynamic names like `_ga_*`)
- **Domain:** first-party (same domain) or third-party (different domain)
- **Set by:** client-side JavaScript (`document.cookie`, cookie libraries) or server-side (`Set-Cookie` header, session middleware, framework cookie helpers)
- **Expiry:** session cookie (no `Expires`/`Max-Age`) or persistent (record duration). Flag cookies with expiry > 13 months (exceeds CNIL recommended maximum).
- **HttpOnly / Secure / SameSite:** flag missing security attributes on cookies containing identifiers
- **Purpose:** authentication, session management, preferences, analytics, advertising, or unknown
- **Consent category:** strictly necessary, functional, analytics, or advertising (classify per `checklists/consent-categories.md`)

Reference `checklists/tracker-fingerprints.md` for known cookie patterns by vendor.

### Step 2: Third-Party Script Inventory

Identify all third-party scripts loaded by the application. For each script:

- **Source:** script URL or SDK package import (npm, CDN, inline)
- **Vendor:** identify the vendor (Google, Meta, HotJar, Segment, etc.)
- **Load method:** `<script>` tag (sync/async/defer), dynamic injection (`document.createElement`), npm import, tag manager
- **Data transmitted:** what personal data the script collects (page URLs, user identifiers, device information, behavioural events)
- **Consent category:** strictly necessary, functional, analytics, or advertising
- **Consent gate:** is the script's loading gated on user consent? Identify the gate mechanism or note its absence.

Search for: SDK imports (`import`, `require`), CDN script tags (`<script src="`), dynamic script injection patterns, and tag manager container snippets.

### Step 3: Pixel & Beacon Detection

Identify tracking pixels, beacons, and telemetry endpoints. For each:

- **Type:** image pixel (`<img>` 1x1), `navigator.sendBeacon()`, `fetch`/`XMLHttpRequest` to analytics endpoints, `ping` attribute on links
- **Vendor:** identify the vendor or internal system
- **Trigger:** what user action or page event fires the pixel/beacon (page load, click, purchase, form submit)
- **Data payload:** what data is included (user ID, page URL, event name, custom properties)
- **Consent gate:** is the pixel/beacon firing gated on user consent?

Common patterns: `fbq('track', ...)`, `gtag('event', ...)`, `analytics.track(...)`, `mixpanel.track(...)`, `plausible(...)`, `navigator.sendBeacon('/api/telemetry', ...)`.

### Step 4: Fingerprinting & Advanced Tracking Detection

Identify browser fingerprinting techniques and advanced tracking methods. For each:

- **Technique:** canvas fingerprinting, WebGL fingerprinting, AudioContext fingerprinting, font enumeration, navigator property harvesting, screen resolution collection, timezone/language profiling
- **Code evidence:** specific API calls (`canvas.toDataURL()`, `gl.getParameter()`, `new AudioContext()`, `navigator.plugins`, `navigator.hardwareConcurrency`)
- **Purpose:** fraud detection, bot protection, analytics enrichment, advertising identity, or unknown
- **Consent category:** fingerprinting for advertising is advertising; fingerprinting for fraud detection may be strictly necessary (requires justification)

Also check for:
- **localStorage/sessionStorage:** identify all keys written, their purpose, and whether they persist tracking identifiers across sessions
- **IndexedDB:** identify any databases used for tracking or analytics caching
- **ETag/Last-Modified tracking:** check for cache-based tracking patterns
- **CNAME cloaking:** check DNS or proxy configuration for third-party trackers served from first-party subdomains
- **Service Worker Cache API:** service workers can persist tracking payloads in `CacheStorage` that survive cookie deletion — check for `caches.open()` storing analytics/tracking responses
- **Background Sync API:** `registration.sync.register()` can defer beacon replay until connectivity returns, enabling tracking that outlives the browsing session
- **Cache Storage identifiers:** check `CacheStorage` entries for responses containing user identifiers or tracking tokens (persists beyond `Clear-Cookie`)

### Step 5: Server-Side Tracking Assessment

Audit server-side cookie and tracking configuration:

- **Session cookies:** framework session middleware configuration (express-session, Django sessions, Rails sessions). Record cookie name, expiry, HttpOnly/Secure/SameSite settings.
- **Server-set tracking cookies:** `Set-Cookie` headers that set analytics or advertising identifiers
- **Server-side analytics:** server-to-server event forwarding (Google Measurement Protocol, Meta Conversions API, server-side Segment) — these bypass client-side consent mechanisms
- **Response headers:** check for tracking-related response headers (`Timing-Allow-Origin`, `Access-Control-Allow-Credentials` on analytics endpoints)
- **Proxy/CDN configuration:** check for cookie-setting at the edge (Cloudflare Workers, Vercel Edge Middleware, AWS CloudFront functions)

Server-side tracking that bypasses client-side consent mechanisms is a HIGH severity finding.

### Step 6: Pre-Consent & Consent Enforcement Audit

For each tracker identified in Steps 1-5, verify consent enforcement:

- **Pre-consent loading:** does the tracker load, fire, or set cookies before the user has made a consent choice? Script load order is typically HIGH confidence.
- **Consent gate verification:** trace from the consent mechanism to each tracker. Is there a code path that prevents the tracker from operating when consent is not granted?
- **Withdrawal enforcement:** when consent is withdrawn, does the tracker stop AND are its cookies/storage cleaned up?
- **Strictly necessary justification:** for trackers classified as "strictly necessary" (exempt from consent), verify the justification per ePrivacy Art. 5(3): the storage or access is strictly necessary for the provision of an information society service explicitly requested by the user.
- **GPC signal handling (compliance requirement):** does the application check for Global Privacy Control (`Sec-GPC: 1` header)? GPC is legally enforceable under CCPA/CPRA (§7025), CPA (Colorado), CTDPA (Connecticut), and 10+ US state privacy laws. GPC must be honoured as a valid opt-out for sale and sharing of personal information. Absence of GPC handling when advertising trackers are active is a HIGH finding.
- **DNT signal handling (informational only):** does the application check for Do Not Track (`DNT: 1` header)? The W3C Tracking Preference Expression working group closed in 2019 with no final standard. DNT has no legal enforceability in any jurisdiction. Detection is informational — flag if present in code but do not treat absence as a compliance gap.

- **TCF string validation (when TCF-compliant CMP detected):** if the site uses a TCF-compliant CMP (OneTrust, Cookiebot, Didomi, etc.), check that the TC string version matches v2.3 (mandatory since Feb 28, 2026). TC strings using v2.2 created before Feb 2026 remain valid, but new consent strings must be v2.3. Flag version mismatches between CMP configuration and loaded vendor scripts' declared TCF purpose IDs.

Cross-reference with Consent Flow Reviewer output if available. The Consent Flow Reviewer audits whether consent is validly obtained; this step audits whether consent is actually enforced per tracker.

### Step 7: Compile Report

Aggregate findings from all steps into the Cookie & Tracker Audit Report format below. Populate the Cookie Inventory, Third-Party Script Inventory, Pixel & Beacon Inventory, Fingerprinting Findings, Server-Side Tracking Assessment, and Consent Enforcement Matrix. Order recommended fixes by severity (blocking first). Use the template from `templates/cookie-tracker-report.md`.

## Output Format

### Cookie & Tracker Audit Report

```markdown
## Cookie & Tracker Audit — [Project/Repo identifier]

### Summary
- **Total cookies found:** [count] ([first-party count] first-party, [third-party count] third-party)
- **Third-party scripts:** [count]
- **Tracking pixels/beacons:** [count]
- **Fingerprinting techniques:** [count]
- **Server-side tracking:** [count]
- **Consent enforcement gaps:** [count]
- **Pre-consent violations:** [count]

### Section 1: Cookie Inventory

| Cookie Name | Domain | Set By | Expiry | Attributes | Purpose | Consent Category | Confidence |
|------------|--------|--------|--------|------------|---------|-----------------|------------|
| [name] | [1P/3P — domain] | [client/server] | [duration or session] | [HttpOnly/Secure/SameSite] | [purpose] | [category] | [HIGH/MEDIUM/LOW] |

### Section 2: Third-Party Script Inventory

| Script/SDK | Vendor | Load Method | Data Transmitted | Consent Category | Consent Gate? | Confidence |
|-----------|--------|-------------|------------------|-----------------|---------------|------------|
| [script] | [vendor] | [method] | [data] | [category] | [yes — mechanism / no] | [HIGH/MEDIUM/LOW] |

### Section 3: Pixel & Beacon Inventory

| Pixel/Beacon | Vendor | Type | Trigger | Data Payload | Consent Category | Consent Gate? | Confidence |
|-------------|--------|------|---------|-------------|-----------------|---------------|------------|
| [name] | [vendor] | [type] | [trigger] | [data] | [category] | [yes/no] | [HIGH/MEDIUM/LOW] |

### Section 4: Fingerprinting & Advanced Tracking

| Technique | Code Evidence | Purpose | Consent Category | Consent Gate? | Severity | Confidence |
|-----------|--------------|---------|-----------------|---------------|----------|------------|
| [technique] | [file:line or API call] | [purpose] | [category] | [yes/no] | [severity] | [HIGH/MEDIUM/LOW] |

#### Web Storage Usage

| Storage Type | Key | Purpose | Contains Identifier? | Consent Category | Confidence |
|-------------|-----|---------|---------------------|-----------------|------------|
| [localStorage/sessionStorage/IndexedDB] | [key] | [purpose] | [yes/no] | [category] | [HIGH/MEDIUM/LOW] |

### Section 5: Server-Side Tracking

| Mechanism | Cookie/Endpoint | Data Transmitted | Bypasses Client Consent? | Consent Gate? | Severity | Confidence |
|-----------|----------------|------------------|-------------------------|---------------|----------|------------|
| [mechanism] | [cookie or endpoint] | [data] | [yes/no] | [yes/no] | [severity] | [HIGH/MEDIUM/LOW] |

### Section 6: Consent Enforcement Matrix

| Tracker | Consent Category | Pre-Consent? | Consent Gate | Withdrawal Cleans Up? | Gap? | Severity | Confidence |
|---------|-----------------|-------------|-------------|----------------------|------|----------|------------|
| [tracker] | [category] | [yes/no] | [mechanism or NONE] | [yes/no/N/A] | [yes/no] | [severity] | [HIGH/MEDIUM/LOW] |

#### Strictly Necessary Justifications

| Tracker | Claimed Justification | User-Requested Service | Service Cannot Function Without? | Valid? | Confidence |
|---------|----------------------|----------------------|--------------------------------|--------|------------|
| [tracker] | [justification] | [service] | [yes/no — reasoning] | [yes/no/requires review] | [HIGH/MEDIUM/LOW] |

### Section 7: Recommended Fixes (ordered by severity)
1. **[BLOCKING]** [fix description]
2. [fix description]
```

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Tracker operating without any consent mechanism, pre-consent data transmission to advertising networks, fingerprinting for cross-site tracking without consent, advertising trackers active without CCPA/CPRA opt-out mechanism |
| **HIGH** | Consent enforcement gap (tracker not gated on consent), server-side tracking bypassing client consent, third-party cookies with no disclosure, cookie expiry > 13 months |
| **MEDIUM** | Missing cookie attributes (HttpOnly, Secure, SameSite), unknown tracker purpose, CMP-dependent enforcement not verified, localStorage containing identifiers |
| **LOW** | Documentation gap (tracker not listed in cookie notice), defensive recommendation (reduce cookie expiry), minor attribute improvement |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Script load visible in source, cookie set in code, pixel fire traceable | Finding can be acted on directly |
| **MEDIUM** | Tag manager dependency, CMP integration, dynamically configured cookies | Verify with runtime testing before acting |
| **LOW** | Inferred from library inclusion (may not be initialised), RUNTIME-DEPENDENT behaviour | Conduct browser DevTools audit or HAR capture to confirm |

**Blocking findings** (severity HIGH or CRITICAL with confidence HIGH or MEDIUM) must be resolved before launch. Non-blocking findings should be filed as follow-up issues.

## Jurisdiction Notes

**Default (principle-based):** Audit all tracking technologies against the core principle that non-essential cookies and trackers require informed consent before activation. This standard is broadly shared across ePrivacy, GDPR, LGPD, and principle-based frameworks.

**ePrivacy Directive (Art. 5(3)):** Storage of information or access to information on a user's terminal equipment is only allowed if: (a) the user has given consent (informed, prior, freely given), OR (b) the storage/access is strictly necessary for the provision of an information society service explicitly requested by the user. "Strictly necessary" is narrow — analytics, advertising, and social media cookies are never strictly necessary. Authentication cookies, load-balancer cookies, and user-preference cookies (language, shopping cart) typically qualify.

**CNIL (France):** Four consent categories: strictly necessary (no consent needed), functional/preference, analytics/performance, advertising/targeting. Cookie walls prohibited. "Continue browsing" does not constitute valid consent. Maximum recommended cookie duration: 13 months. Consent must be renewed at least every 13 months. Refuse must be as prominent as accept. See `shared/jurisdiction-profiles.md`.

**ICO (UK):** Strictly necessary test aligned with ePrivacy. Analytics cookies require consent (including Google Analytics). First-party analytics with IP anonymisation may qualify for a legitimate interest argument under UK GDPR, but this is debated — flag as requiring legal review. Maximum recommended cookie duration: 12 months.

**CCPA/CPRA:** Cookies that facilitate sale or sharing of personal information require opt-out mechanisms. GPC signal (§7025) must be honoured as a valid opt-out for both sale AND sharing. See the ccpa-review skill for full CCPA analysis.

**Cross-skill usage:** This skill complements the Consent Flow Reviewer — run both for full cookie compliance coverage. The Consent Flow Reviewer audits whether consent is validly obtained (Art. 4(11) conditions, dark patterns, withdrawal symmetry). This skill audits what actually runs in the browser and whether it respects consent state. Together they cover the full surface: consent UX quality + tracker enforcement.

## References

- ePrivacy Directive 2002/58/EC, Art. 5(3) — Confidentiality of communications (verified 2026-03-30)
- GDPR Art. 6, Art. 7 — Lawful basis and conditions for consent (verified 2026-03-30)
- CJEU C-673/17 (Planet49) — Cookies require active consent, not pre-checked boxes (verified 2026-03-30)
- EDPB Guidelines 05/2020 v1.1 — Consent under Regulation 2016/679 (verified 2026-03-30)
- CNIL Guidelines on cookies and similar trackers, adopted 1 October 2020 (verified 2026-03-30)
- ICO Guidance on the use of cookies and similar technologies (verified 2026-03-30)
- CCPA §1798.120, CPPA §7025 — Opt-out and GPC requirements (verified 2026-03-30)
- IAB Europe Transparency & Consent Framework v2.2/v2.3 — TCF signal structure. v2.3 became mandatory Feb 28, 2026; v2.2 TC strings created before that date remain valid. (verified 2026-03-30)
- Global Privacy Control (globalprivacycontrol.org) — `Sec-GPC` header specification. Legally enforceable under CCPA/CPRA (§7025), CPA, CTDPA, and 10+ US state privacy laws. (verified 2026-03-30)
- W3C Tracking Preference Expression (DNT) — `DNT` header specification. W3C working group closed January 2019 with no final standard. No legal enforceability. (verified 2026-03-30)
- See `shared/jurisdiction-profiles.md` for cross-jurisdictional cookie consent summaries
- See `checklists/tracker-fingerprints.md` for known tracker patterns by vendor
- See `checklists/consent-categories.md` for consent category classification guide
- See `checklists/cookie-compliance.md` for ePrivacy + GDPR + CCPA cookie compliance checklist

## Changelog

- **v1.1.0** (2026-03-30) — Accuracy fixes: corrected Privacy Sandbox/third-party cookie deprecation status (Google dropped deprecation April 2025, retired Sandbox APIs Oct 2025); replaced deprecated `__cfduid` with `__cf_bm`/`__cflb`; replaced deprecated `csurf` with generic CSRF middleware in SaaS example; added Service Worker Cache API, Background Sync API, and Cache Storage as tracking vectors; added CCPA/CPRA opt-out to CRITICAL severity definition; elevated session replay guidance with CNIL draft recommendation (Feb 2026) reference; split DNT/GPC into separate references (GPC legally enforceable, DNT informational only); added TCF v2.3 validation check (mandatory Feb 28, 2026); strengthened ePrivacy Regulation stalled status note.
- **v1.0.0** (2026-03-30) — Initial release. 7-step process covering cookie inventory, third-party script detection, pixel/beacon identification, fingerprinting detection, server-side tracking assessment, and consent enforcement verification. Consent category classification (strictly necessary, functional, analytics, advertising). Cross-skill composability with Consent Flow Reviewer.
