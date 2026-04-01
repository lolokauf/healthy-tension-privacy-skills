# Cookie & Tracker Audit Report Template

Blank template for the cookie-tracker-audit skill's output. Complete all sections — use "None identified", "N/A", or "Unknown" rather than leaving sections empty.

---

## Cookie & Tracker Audit — [Project/Repo identifier]

<!-- Replace [Project/Repo identifier] with the project name, PR number, or repository path. -->

### Summary

<!-- High-level tracker snapshot. Fill all fields. -->

- **Total cookies found:** [count] ([first-party count] first-party, [third-party count] third-party)
- **Third-party scripts:** [count]
- **Tracking pixels/beacons:** [count]
- **Fingerprinting techniques:** [count]
- **Server-side tracking:** [count]
- **Consent enforcement gaps:** [count]
- **Pre-consent violations:** [count]

---

### Section 1: Cookie Inventory

<!-- One row per cookie. For dynamic cookie names (e.g., _ga_<container-id>), use the pattern.
     Domain: "1P" for first-party (same domain), "3P — [domain]" for third-party.
     Attributes: list HttpOnly, Secure, SameSite values. Flag missing attributes on identifier cookies.
     Consent category: strictly necessary, functional, analytics, or advertising.
     See checklists/consent-categories.md for classification guidance. -->

| Cookie Name | Domain | Set By | Expiry | Attributes | Purpose | Consent Category | Confidence |
|------------|--------|--------|--------|------------|---------|-----------------|------------|
| <!-- e.g., connect.sid --> | <!-- e.g., 1P --> | <!-- e.g., server (express-session) --> | <!-- e.g., session --> | <!-- e.g., HttpOnly, Secure, SameSite=Lax --> | <!-- e.g., Session authentication --> | <!-- e.g., Strictly necessary --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | | |

<!-- After the table, note:
     - Total first-party vs third-party count
     - Any cookies with expiry > 13 months (CNIL maximum)
     - Any cookies missing HttpOnly/Secure on identifier values -->

---

### Section 2: Third-Party Script Inventory

<!-- One row per third-party script or SDK.
     Load method: <script> (sync/async/defer), dynamic injection, npm import, tag manager.
     Data transmitted: what personal data the script collects (page URLs, user IDs, device info, events).
     Consent gate: "yes — [mechanism]" or "no". -->

| Script/SDK | Vendor | Load Method | Data Transmitted | Consent Category | Consent Gate? | Confidence |
|-----------|--------|-------------|------------------|-----------------|---------------|------------|
| <!-- e.g., gtag.js --> | <!-- e.g., Google --> | <!-- e.g., <script async> --> | <!-- e.g., page URL, user agent, events --> | <!-- e.g., Analytics --> | <!-- e.g., no --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | |

<!-- For scripts loaded via tag manager, note the tag manager and flag as RUNTIME-DEPENDENT if
     container config is not available for review. -->

---

### Section 3: Pixel & Beacon Inventory

<!-- One row per tracking pixel, beacon, or telemetry endpoint.
     Type: image pixel, sendBeacon, fetch/XHR, ping attribute.
     Trigger: page load, click, purchase, form submit, custom event.
     Data payload: what data is included in the request. -->

| Pixel/Beacon | Vendor | Type | Trigger | Data Payload | Consent Category | Consent Gate? | Confidence |
|-------------|--------|------|---------|-------------|-----------------|---------------|------------|
| <!-- e.g., fbq('track', 'Purchase') --> | <!-- e.g., Meta --> | <!-- e.g., script API call --> | <!-- e.g., Purchase completion --> | <!-- e.g., value, currency, content_ids --> | <!-- e.g., Advertising --> | <!-- e.g., no --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | | |

---

### Section 4: Fingerprinting & Advanced Tracking

<!-- One row per fingerprinting technique or advanced tracking method.
     Code evidence: specific file:line or API call pattern.
     Purpose: fraud detection, bot protection, analytics enrichment, advertising identity, unknown. -->

| Technique | Code Evidence | Purpose | Consent Category | Consent Gate? | Severity | Confidence |
|-----------|--------------|---------|-----------------|---------------|----------|------------|
| <!-- e.g., Canvas fingerprinting --> | <!-- e.g., utils/fingerprint.ts:42 — canvas.toDataURL() --> | <!-- e.g., Analytics enrichment --> | <!-- e.g., Analytics --> | <!-- e.g., no --> | <!-- severity --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | |

#### Web Storage Usage

<!-- One row per localStorage, sessionStorage, or IndexedDB entry used for tracking or containing identifiers. -->

| Storage Type | Key | Purpose | Contains Identifier? | Consent Category | Confidence |
|-------------|-----|---------|---------------------|-----------------|------------|
| <!-- e.g., localStorage --> | <!-- e.g., ajs_anonymous_id --> | <!-- e.g., Segment anonymous user ID --> | <!-- e.g., yes (UUID) --> | <!-- e.g., Analytics --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

---

### Section 5: Server-Side Tracking

<!-- One row per server-side tracking mechanism.
     Bypasses client consent: does this mechanism operate independently of client-side consent state?
     Server-side tracking that bypasses client consent is HIGH severity. -->

| Mechanism | Cookie/Endpoint | Data Transmitted | Bypasses Client Consent? | Consent Gate? | Severity | Confidence |
|-----------|----------------|------------------|-------------------------|---------------|----------|------------|
| <!-- e.g., Meta Conversions API --> | <!-- e.g., POST graph.facebook.com --> | <!-- e.g., email hash, event name, value --> | <!-- e.g., yes --> | <!-- e.g., no --> | <!-- e.g., HIGH --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | |

---

### Section 6: Consent Enforcement Matrix

<!-- One row per tracker (aggregate from Sections 1-5).
     This is the primary compliance artifact — shows whether each tracker respects consent.
     Pre-consent: does the tracker operate before the user has made a consent choice?
     Consent gate: the mechanism that prevents the tracker from operating without consent (or NONE).
     Withdrawal cleans up: does withdrawing consent delete the tracker's cookies/storage? -->

| Tracker | Consent Category | Pre-Consent? | Consent Gate | Withdrawal Cleans Up? | Gap? | Severity | Confidence |
|---------|-----------------|-------------|-------------|----------------------|------|----------|------------|
| <!-- e.g., Google Analytics --> | <!-- e.g., Analytics --> | <!-- e.g., yes --> | <!-- e.g., NONE --> | <!-- e.g., N/A (no consent gate) --> | <!-- e.g., yes --> | <!-- e.g., CRITICAL --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | | | |

#### Strictly Necessary Justifications

<!-- One row per tracker claimed as "strictly necessary".
     Apply the ePrivacy Art. 5(3) purpose-necessity test.
     "Valid?" should be yes, no, or "requires review" (for edge cases). -->

| Tracker | Claimed Justification | User-Requested Service | Service Cannot Function Without? | Valid? | Confidence |
|---------|----------------------|----------------------|--------------------------------|--------|------------|
| <!-- e.g., connect.sid --> | <!-- e.g., Session authentication --> | <!-- e.g., Authenticated web app --> | <!-- e.g., yes — stateful auth requires server session --> | <!-- e.g., yes --> | <!-- HIGH/MEDIUM/LOW --> |
| | | | | | |

---

### Section 7: Recommended Fixes (ordered by severity)

<!-- Order by severity: CRITICAL first, then HIGH, MEDIUM, LOW.
     Mark blocking findings (CRITICAL/HIGH with HIGH/MEDIUM confidence) with [BLOCKING].
     Include specific remediation steps, not just "fix this". -->

1. **[BLOCKING]** <!-- e.g., Gate Google Analytics script loading on analytics consent — currently loads on page load before consent mechanism renders (CRITICAL, HIGH confidence) -->
2. <!-- e.g., Add GPC signal handling: check Sec-GPC header and suppress advertising trackers when set (HIGH, HIGH confidence) -->
