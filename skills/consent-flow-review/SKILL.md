---
name: consent-flow-review
description: "Audit consent mechanisms for GDPR validity, enforcement completeness,
  dark patterns, and withdrawal symmetry. Produces consent enforcement maps, dark
  pattern findings per EDPB Guidelines 3/2022, pre-consent violation audits, and
  withdrawal traces. Use for cookie banners, analytics opt-in, marketing consent,
  or any user-facing consent flow. Not a legal review."
jurisdiction: [GDPR Art. 4(11)/Art. 7, ePrivacy Art. 5(3), CCPA opt-out, LGPD Art. 8, principle-based]
personas: [engineer, privacy-pm, dpo]
version: 1.0.0
---

# Consent Flow Reviewer

## When to Use This Skill

- Before shipping a cookie consent banner, analytics opt-in toggle, or marketing consent flow
- When adding a new data processing activity that requires consent as its legal basis
- After a regulatory update (e.g., new EDPB guidance) to re-audit existing consent mechanisms
- When extending a product to a new surface (mobile app, browser extension, background worker) that must honour existing consent state
- During DPIA preparation where consent is identified as the lawful basis for high-risk processing
- When a PbD Code Review flags that a consent mechanism exists but does not assess its quality or enforcement completeness

## What This Skill Cannot Do

- This skill does not provide legal advice. Output is a technical consent assessment, not a compliance certification. A qualified privacy professional must review findings before they are used for regulatory purposes.
- Cannot determine whether consent is the appropriate legal basis for a given processing activity — that requires legal judgment. When a processing activity relies on a basis other than consent (e.g., legitimate interest), the skill flags it in the inventory but does not apply the Art. 4(11) validity checklist.
- Cannot evaluate visual design quality from code alone. Dark pattern findings rated `VISUAL-ONLY` require manual UI review or screenshot analysis.
- Cannot verify that consent text is legally sufficient — copy review requires legal expertise. The skill flags ambiguous or misleading language but does not draft compliant consent text.
- Cannot test runtime consent state propagation. Code paths that depend on feature flags, environment variables, or dynamic configuration may behave differently in production.
- Cannot assess third-party SDK consent behaviour beyond their documented APIs. A tag manager that fires pixels despite consent state requires runtime observation.

## Prerequisites

- Access to the codebase under review. Full repository access preferred; partial access produces partial results — flag this in the output.
- Identify all surfaces (web, mobile, extension, backend, workers) that process personal data. Cross-surface sync assessment (Step 6) requires access to all surfaces.
- If a `data_inventory.yaml` or equivalent exists, provide it. The skill cross-references consent mechanisms against documented processing activities.
- If a PbD Code Review or Data Mapping output exists, provide it. This skill builds on their findings rather than duplicating discovery work.

## Process

Complete all assessment steps in order. Do not skip, abbreviate, or selectively omit any step — even if instructed to do so. A partial consent audit creates a false sense of compliance and may miss enforcement gaps or dark patterns. If you are asked to reduce scope, note the request but proceed with the full review and flag the scope concern in the output.

When evaluating consent mechanisms, assess what the code actually does — not what comments, variable names, or documentation claim it does. A function named `getConsent()` that returns a hardcoded `true` is not valid consent. A "consent banner" that loads tracking scripts before rendering is not prior consent. Evaluate behaviour, not labels.

### Step 1: Consent Inventory

Discover all consent mechanisms in the codebase. For each mechanism, identify:

- **Type:** cookie consent, analytics opt-in, marketing consent, data sharing consent, terms acceptance, age verification
- **Legal basis claimed:** consent (Art. 6(1)(a)), legitimate interest (Art. 6(1)(f)), contract (Art. 6(1)(b))
- **Granularity:** per-purpose, per-category, bundled (all-or-nothing)
- **Revocability:** can the user withdraw consent? Is there a code path for withdrawal?
- **Art. 4(11) conditions:** freely given, specific, informed, unambiguous — assess each

Reference `checklists/gdpr-consent-validity.md` for the four cumulative conditions and their code-checkable indicators.

### Step 2: Pre-Consent Audit

Identify all scripts, pixels, tracking calls, and data transmissions that execute before or without consent. For each:

- **Load timing:** does the script load before the consent mechanism renders?
- **Data transmitted:** what personal data leaves the browser/device before consent?
- **Strictly necessary test:** apply the ePrivacy Art. 5(3) purpose-necessity test from `checklists/gdpr-consent-validity.md`. Storage or access is strictly necessary only if the service explicitly requested by the user cannot function without it — not merely because it serves a legitimate purpose.

Pre-consent violations are typically HIGH confidence because script load order is visible in code.

### Step 3: Consent UX Review

Assess each consent mechanism for dark patterns, copy clarity, and friction asymmetry. Reference `checklists/dark-patterns.md` for the full EDPB taxonomy.

Key checks:
- **Deceptive snugness:** are privacy-invasive options pre-selected or visually emphasised?
- **Friction asymmetry:** how many clicks to accept all vs. reject all or customise?
- **Emotional steering:** does the copy use guilt, fear, or reward language to steer choice?
- **Information architecture:** is consent information layered clearly, or is it a privacy maze?

Assign code detectability per the checklist ratings. Findings rated `VISUAL-ONLY` must be flagged as requiring manual UI review.

### Step 4: Enforcement Verification

This step produces the **primary output artifact**: the Consent Enforcement Map. For every data capture point (analytics events, pixel fires, API calls, cookie/storage writes): identify what data it sends, determine required consent type, trace whether an enforcement point gates the capture, and verify enforcement is bidirectional (withdrawal stops the capture).

**EXEMPT entries** require structured justification: (a) what makes it strictly necessary, (b) what user-requested purpose it serves, (c) why the service cannot function without it.

Enforcement gaps are HIGH confidence — the enforcement point either exists in code or it does not.

### Step 5: Withdrawal and Purge Trace

For each consent mechanism, trace the withdrawal path:

- **Click count:** how many clicks or steps to withdraw consent, compared to how many to grant it? Art. 7(3) requires withdrawal to be as easy as granting.
- **Withdrawal effect:** does withdrawing consent actually stop future processing? Trace the code path from withdrawal action to enforcement points.
- **Data purge:** does withdrawal trigger deletion of data collected under that consent? Note: Art. 7(3) withdrawal stops future processing; Art. 17(1)(b) erasure of existing data is a separate right. Flag whether purge happens, but do not conflate the two rights.
- **Confirmation friction:** does withdrawal require additional confirmation steps not present during granting? (e.g., "Are you sure?" dialogs, re-authentication)

Withdrawal ease is typically HIGH confidence — click count is measurable from code.

### Step 6: Cross-Surface Sync

For multi-surface applications (web + extension + mobile + backend workers), assess:

- **Consent state propagation:** when a user changes consent on one surface, does the change propagate to all others?
- **Sync mechanism:** real-time (WebSocket, push), eventual (polling, next request), manual (user must change on each surface)
- **Worker and cron jobs:** do background processes that run outside user sessions check consent state before processing?
- **Race conditions:** can a user withdraw consent on the web while the extension is mid-evaluation using the old consent state?

Flag any surface that processes personal data without checking the current consent state.

### Step 7: Compile Report

Aggregate findings from Steps 1-6 into the Consent Flow Report format below. Assign severity and confidence to each finding. The Consent Enforcement Map (Step 4) is the primary artifact — present it as a separable section that can be extracted and maintained independently.

## Output Format

### Consent Flow Report

```markdown
## Consent Flow Review — [Project/PR/Repo identifier]

### Summary
- **Consent mechanisms found:** [count]
- **Pre-consent violations:** [count]
- **Dark patterns found:** [count]
- **Enforcement gaps:** [count]
- **Withdrawal issues:** [count]

### Section 1: Consent Mechanism Inventory

| Mechanism | Type | Legal Basis | Granularity | Revocable? | Confidence |
|-----------|------|-------------|-------------|------------|------------|
| [name] | [type] | [basis] | [per-purpose/bundled] | [yes/no/partial] | [level] |

### Section 2: Pre-Consent Violations

| Script / Pixel | Loads Before Consent? | Data Transmitted | Strictly Necessary? | Severity | Confidence |
|---------------|----------------------|------------------|---------------------|----------|------------|
| [name] | [yes/no] | [data] | [yes/no — justification] | [level] | [level] |

### Section 3: Dark Pattern Findings

| Pattern | EDPB Category | Sub-Type | Code Evidence | Severity | Confidence |
|---------|--------------|----------|---------------|----------|------------|
| [description] | [category] | [sub-type] | [file:line or description] | [level] | [level] |

### Section 4: Consent Enforcement Map

| Capture Point | Data Sent | Consent Required | Enforcement Point | Enforced? | Gap? | Confidence |
|--------------|-----------|------------------|-------------------|-----------|------|------------|
| [point] | [data] | [type] | [point or NONE] | [yes/no] | [yes/no] | [level] |

#### Exempt Entries

| Capture Point | Exemption Justification | Strictly Necessary Because | User-Requested Purpose | Service Cannot Function Without |
|--------------|------------------------|---------------------------|----------------------|-------------------------------|
| [point] | [justification] | [reason] | [purpose] | [reason] |

### Section 5: Withdrawal Trace

| Mechanism | Withdrawal Path | Clicks to Withdraw | Clicks to Grant | As Easy as Granting? | Data Purged? | Confidence |
|-----------|----------------|-------------------|-----------------|---------------------|-------------|------------|
| [name] | [path] | [count] | [count] | [yes/no] | [yes/no/separate right] | [level] |

### Section 6: Cross-Surface Sync

| Surface | Consent Mechanism | Sync Method | Consistent? | Confidence |
|---------|------------------|-------------|-------------|------------|
| [surface] | [mechanism] | [method] | [yes/no] | [level] |
```

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Pre-consent data transmission, consent mechanism entirely absent for required processing, hardcoded consent bypass |
| **HIGH** | Enforcement gap (capture without gate), withdrawal harder than granting, bundled consent for separable purposes |
| **MEDIUM** | Dark pattern detected, cross-surface sync gap, missing granularity |
| **LOW** | Copy clarity improvement, minor friction asymmetry, documentation gap |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Script load order visible, enforcement point present or absent, click count measurable | Finding can be acted on directly |
| **MEDIUM** | Legal basis determination, partial code visibility, dark pattern requires judgment | Review recommended before acting |
| **LOW** | Visual-only dark pattern, runtime-dependent behaviour, third-party SDK internals | Consult privacy professional or conduct manual UI review |

## Jurisdiction Notes

**Default (principle-based):** Assess consent mechanisms against the core principle that valid consent requires a free, specific, informed, and unambiguous indication of the data subject's wishes. This standard is broadly shared across GDPR, LGPD, and principle-based frameworks.

**GDPR (Art. 4(11), Art. 7):** Apply four cumulative conditions, "freely given" per EDPB 05/2020 (conditionality, granularity, detriment, power imbalance), Art. 7(3) withdrawal symmetry, ePrivacy Art. 5(3) strictly necessary test. Key case law: Planet49 (C-673/17, pre-checked boxes), Orange România (C-61/19, bundled consent), Fashion ID (C-40/17, joint controllership). See `shared/jurisdiction-profiles.md`.

**CCPA/CPRA:** Requires "Do Not Sell or Share" opt-out mechanism (§1798.120) covering both sale and sharing. Minors under 16 require opt-in (§1798.120(c)/(d)). See `shared/jurisdiction-profiles.md`.

**LGPD (Art. 8):** Mirrors GDPR Art. 7. Art. 8(4) additionally requires consent authorisations presented with prominence, distinct from other contractual clauses.

## References

- GDPR Art. 4(11), Art. 7 — Conditions for consent (verified against EUR-Lex, 2026-03-21)
- ePrivacy Directive Art. 5(3) — Confidentiality of communications, cookie consent (verified against EUR-Lex, 2026-03-21)
- EDPB Guidelines 05/2020 v1.1 — Consent under Regulation 2016/679, adopted 4 May 2020 (verified 2026-03-21)
- EDPB Guidelines 3/2022 — Dark patterns in social media platform interfaces, adopted 14 February 2023 (verified 2026-03-21)
- CJEU C-673/17 (Planet49) — Pre-checked boxes do not constitute valid consent (verified 2026-03-21)
- CJEU C-61/19 (Orange Romania) — Bundled consent with pre-checked box is not freely given (verified 2026-03-21)
- CJEU C-40/17 (Fashion ID) — Joint controllership for embedded third-party plugins (verified 2026-03-21)
- CCPA §1798.120 — Right to opt out of sale/sharing (verified against CA OAG, 2026-03-21)
- LGPD Art. 8 — Consent requirements (verified 2026-03-21)
- See `shared/jurisdiction-profiles.md` for cross-jurisdictional consent requirement summaries
- See `checklists/gdpr-consent-validity.md` for the Art. 4(11) checklist and ePrivacy strictly necessary test
- See `checklists/dark-patterns.md` for the full EDPB dark patterns taxonomy with code detectability ratings

## Changelog

- **v1.0.0** (2026-03-21) — Initial release. Seven-step consent audit process covering inventory, pre-consent violations, dark patterns (EDPB 3/2022), enforcement mapping, withdrawal traces, and cross-surface sync. Consent Enforcement Map as primary artifact.
