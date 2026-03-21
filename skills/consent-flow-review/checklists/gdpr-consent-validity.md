# GDPR Consent Validity Checklist

Reference checklist for the Consent Flow Reviewer skill. Covers Art. 4(11) cumulative conditions, EDPB 05/2020 "freely given" sub-elements, and the ePrivacy Art. 5(3) strictly necessary test.

---

## Art. 4(11) — Four Cumulative Conditions

All four conditions must be satisfied simultaneously. Failure on any single condition means consent is invalid.

### 1. Freely Given

The data subject has a genuine free choice. Consent is not freely given if it is bundled with terms, if refusal causes detriment, or if there is a clear power imbalance.

**EDPB 05/2020 v1.1 — Four sub-elements:**

| Sub-Element | Definition | Code-Checkable Indicators | Confidence |
|-------------|-----------|---------------------------|------------|
| **Conditionality** | Consent must not be a condition of service access (Art. 7(4)). The "cookie wall" test: is the service inaccessible without consent? | Check whether UI blocks content or functionality if consent is refused. Look for redirects, overlays with no dismiss option, or disabled features gated on consent state. | HIGH |
| **Granularity** | Separate consent for separate processing purposes. Bundled "accept all" without per-purpose options fails this test. | Check whether consent UI offers per-purpose or per-category toggles. A single "I agree" checkbox covering analytics, marketing, and functionality fails. | HIGH |
| **Detriment** | The data subject must not suffer negative consequences for refusing or withdrawing consent. | Check whether refusal triggers degraded UX, loss of features, nagging modals, or repeated prompts. Look for code paths that behave differently based on consent refusal (beyond simply not tracking). | MEDIUM |
| **Power imbalance** | Where a clear imbalance exists (employer-employee, public authority-citizen), consent is unlikely to be freely given. | Not typically detectable from code. Flag if the application context suggests a power imbalance (e.g., HR tools, government services, educational platforms). | LOW |

**Case law — Orange Romania (CJEU C-61/19):** Consent bundled into a contract with a pre-checked box for data processing is not freely given. Code pattern: consent checkbox pre-checked in a form that also handles service registration.

### 2. Specific

Consent must be tied to a specific, explicit, and legitimate purpose. Broad or vague purposes ("improving our services", "enhancing your experience") fail this test.

| Indicator | Code-Checkable? | What to Look For | Confidence |
|-----------|-----------------|------------------|------------|
| Purpose stated in consent UI | Yes | Check consent text for specific purpose descriptions. Flag generic language. | MEDIUM |
| One consent per purpose | Yes | Check whether a single consent action covers multiple distinct purposes. | HIGH |
| Purpose limitation in enforcement | Yes | Check whether consent state is stored per-purpose or as a single boolean. | HIGH |

### 3. Informed

The data subject must receive sufficient information to make an informed decision before consenting. Minimum information per EDPB 05/2020: controller identity, purpose of processing, type of data collected, right to withdraw.

| Indicator | Code-Checkable? | What to Look For | Confidence |
|-----------|-----------------|------------------|------------|
| Controller identity visible | Partial | Check whether consent UI includes or links to controller name and contact. | MEDIUM |
| Purpose stated before action | Yes | Check whether consent text is rendered before the consent action (button, toggle). | HIGH |
| Data types disclosed | Partial | Check whether consent text mentions specific data categories or is vague. | MEDIUM |
| Withdrawal right mentioned | Partial | Check whether consent UI mentions the right to withdraw and how to exercise it. | MEDIUM |

### 4. Unambiguous Indication

Consent requires a clear affirmative act. Silence, pre-checked boxes, or inactivity do not constitute consent.

| Indicator | Code-Checkable? | What to Look For | Confidence |
|-----------|-----------------|------------------|------------|
| No pre-checked boxes | Yes | Check checkbox/toggle default state in code. `defaultChecked={true}` or `checked` attribute without user action fails. | HIGH |
| No consent-by-scroll or consent-by-browsing | Yes | Check whether consent state is set by scroll events, page navigation, or timers rather than explicit click/tap. | HIGH |
| Affirmative action required | Yes | Check whether consent is only recorded after an explicit user action (click, tap, toggle). | HIGH |

**Case law — Planet49 (CJEU C-673/17):** Pre-checked boxes for cookies do not constitute valid consent. A pre-checked checkbox that the user must uncheck to refuse is not an unambiguous indication of wishes.

---

## ePrivacy Art. 5(3) — Strictly Necessary Test

Art. 5(3) requires consent for storing or accessing information on a user's device **unless** the storage is strictly necessary to provide a service explicitly requested by the user.

### Purpose-Necessity Decision Tree

Apply this test to every cookie, localStorage entry, sessionStorage entry, IndexedDB record, and device identifier access:

1. **Has the user explicitly requested this service?** If no → consent required. "Explicitly requested" means the user took an action to invoke this specific service (e.g., clicked "add to cart", "log in", "submit form"). Merely visiting the site is not an explicit request for analytics.

2. **Is this storage/access necessary for THAT specific service to function?** If no → consent required. The test is whether the service the user requested cannot be delivered without this specific storage — not whether the storage serves some other legitimate purpose.

3. **Would the service fail or be technically impossible without this storage/access?** If no → consent required. Convenience, optimisation, or enhanced functionality do not meet the strictly necessary threshold.

### Common Determinations

| Storage / Access | Strictly Necessary? | Reasoning |
|-----------------|---------------------|-----------|
| Session cookie (authentication) | Yes | User requested "log in"; session cannot function without it |
| Shopping cart cookie | Yes | User requested "add to cart"; cart cannot persist without it |
| CSRF token cookie | Yes | Form submission (user-requested) cannot be secured without it |
| Load balancer cookie | Yes | Service delivery requires request routing; user requested the page |
| Language preference cookie | Debatable | If user explicitly chose language: yes. If auto-detected: consent required |
| Analytics cookies (GA, PostHog) | No | Analytics serves the controller's interest, not a service the user requested |
| Advertising/tracking pixels | No | Advertising is not a service the user requested |
| A/B testing cookies | No | Testing serves the controller's interest; the user requested the page, not the experiment |
| Social media widgets | No (Fashion ID) | Embedded plugins transmit data to third parties before user interaction |

**Case law — Fashion ID (CJEU C-40/17):** A website that embeds a Facebook Like button is a joint controller for the data collection triggered by loading the plugin. The plugin fires before any user interaction, making it a pre-consent data transmission. Consent must be obtained before the plugin loads.

---

## Agent Behaviour Notes

- When assessing Art. 4(11) conditions, evaluate all four. A mechanism that satisfies three but fails one is still invalid consent.
- When applying the strictly necessary test, err on the side of requiring consent. If the determination is ambiguous, flag it as MEDIUM confidence and recommend consent.
- Cross-reference findings with the Consent Enforcement Map (Step 4 of the skill process). A consent mechanism that is valid under Art. 4(11) but has enforcement gaps still fails in practice.
- Do not treat "legitimate interest" processing as requiring the same consent mechanisms. If a processing activity relies on legitimate interest (Art. 6(1)(f)), flag it in the inventory but do not apply the Art. 4(11) checklist — apply a balancing test instead (outside this skill's scope).
