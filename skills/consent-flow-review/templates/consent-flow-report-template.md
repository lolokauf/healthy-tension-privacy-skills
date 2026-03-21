# Consent Flow Report Template

Blank template for the Consent Flow Reviewer skill's output. All sections are required. Use "N/A", "None found", or "Not applicable" rather than omitting sections. The Consent Enforcement Map (Section 4) is the primary artifact and should be maintained independently of the rest of the report.

---

## Consent Flow Review — [Project/PR/Repo identifier]

<!-- Replace the bracketed identifier with the project name, PR number, or repo path under review. -->

### Summary

<!-- Fill in counts from each section. All counts required — use 0 if none found. -->

- **Consent mechanisms found:** [count]
- **Pre-consent violations:** [count]
- **Dark patterns found:** [count]
- **Enforcement gaps:** [count]
- **Withdrawal issues:** [count]

---

### Section 1: Consent Mechanism Inventory

<!-- One row per consent mechanism discovered in the codebase. Assess all four Art. 4(11) conditions (freely given, specific, informed, unambiguous) and note failures in the Notes column or as separate findings. -->

| Mechanism | Type | Legal Basis | Granularity | Revocable? | Art. 4(11) Failures | Confidence |
|-----------|------|-------------|-------------|------------|---------------------|------------|
| <!-- mechanism name --> | <!-- cookie/analytics/marketing/data-sharing/terms/age-verification --> | <!-- consent/legitimate-interest/contract/TBD --> | <!-- per-purpose/per-category/bundled --> | <!-- yes/no/partial --> | <!-- none/list failures --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- Repeat rows as needed. If no consent mechanisms found, state "No consent mechanisms found" and flag as CRITICAL — processing that requires consent has no mechanism. -->

---

### Section 2: Pre-Consent Violations

<!-- One row per script, pixel, tracking call, or data transmission that executes before or without consent. Apply the ePrivacy Art. 5(3) strictly necessary test from checklists/gdpr-consent-validity.md. -->

| Script / Pixel | Loads Before Consent? | Data Transmitted | Strictly Necessary? | Severity | Confidence |
|---------------|----------------------|------------------|---------------------|----------|------------|
| <!-- script name or file path --> | <!-- yes/no --> | <!-- specific data elements --> | <!-- yes — [justification] / no --> | <!-- CRITICAL/HIGH/MEDIUM/LOW --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- If no pre-consent violations found, state "No pre-consent violations identified" and retain the table header for completeness. -->

---

### Section 3: Dark Pattern Findings

<!-- One row per dark pattern identified. Reference the EDPB category and sub-type from checklists/dark-patterns.md. Include specific code evidence (file path and line number) for patterns with HIGH code detectability. -->

| Pattern | EDPB Category | Sub-Type | Code Evidence | Severity | Confidence |
|---------|--------------|----------|---------------|----------|------------|
| <!-- plain-language description --> | <!-- Overloading/Skipping/Stirring/Hindering/Fickle/Left in the dark --> | <!-- sub-type name --> | <!-- file:line or description --> | <!-- CRITICAL/HIGH/MEDIUM/LOW --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- If no dark patterns found, state "No dark patterns identified" and retain the table header. Note whether a manual UI review is still recommended for VISUAL-ONLY patterns. -->

---

### Section 4: Consent Enforcement Map

<!-- PRIMARY ARTIFACT — This section should be extractable and maintainable independently. One row per data capture point. A capture point is any location in code where personal data is transmitted, stored, or accessed: analytics events, pixel fires, API calls to third parties, cookie writes, localStorage writes. -->

| Capture Point | Data Sent | Consent Required | Enforcement Point | Enforced? | Gap? | Confidence |
|--------------|-----------|------------------|-------------------|-----------|------|------------|
| <!-- file:line or function name --> | <!-- specific data elements --> | <!-- analytics/marketing/functional/none --> | <!-- file:line or function name, or NONE --> | <!-- yes/no --> | <!-- yes/no --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- An enforcement gap exists when:
  1. A capture point has no corresponding enforcement point (Enforcement Point = NONE), OR
  2. The enforcement point does not check the correct consent type, OR
  3. Withdrawing consent does not stop the capture (enforcement is grant-only, not bidirectional)
-->

#### Exempt Entries

<!-- Any capture point claimed as exempt from consent must provide structured justification. Do not leave justification columns blank — if the justification is unclear, flag it as a potential gap. -->

| Capture Point | Exemption Justification | Strictly Necessary Because | User-Requested Purpose | Service Cannot Function Without |
|--------------|------------------------|---------------------------|----------------------|-------------------------------|
| <!-- capture point --> | <!-- e.g., "Session cookie for authentication" --> | <!-- technical reason --> | <!-- what the user explicitly asked for --> | <!-- why the service breaks without it --> |

<!-- If no exempt entries, state "No exempt entries claimed." -->

---

### Section 5: Withdrawal Trace

<!-- One row per consent mechanism from Section 1. Compare the withdrawal path to the granting path. Art. 7(3) requires withdrawal to be as easy as granting. Note: Art. 7(3) withdrawal stops future processing; Art. 17(1)(b) erasure is a separate right — do not conflate. -->

| Mechanism | Withdrawal Path | Clicks to Withdraw | Clicks to Grant | As Easy as Granting? | Data Purged? | Confidence |
|-----------|----------------|-------------------|-----------------|---------------------|-------------|------------|
| <!-- mechanism name --> | <!-- step-by-step path --> | <!-- integer --> | <!-- integer --> | <!-- yes/no --> | <!-- yes/no/separate right (Art. 17) --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- If withdrawal is not possible for a mechanism, state "No withdrawal path exists" in the Withdrawal Path column and flag as CRITICAL. -->

---

### Section 6: Cross-Surface Sync

<!-- One row per surface (web, mobile, extension, backend, worker/cron). If the application has only one surface, state "Single-surface application — cross-surface sync not applicable" and retain the table header. -->

| Surface | Consent Mechanism | Sync Method | Consistent? | Confidence |
|---------|------------------|-------------|-------------|------------|
| <!-- web/mobile/extension/backend/worker --> | <!-- mechanism name or "none" --> | <!-- real-time/eventual/manual/none --> | <!-- yes/no --> | <!-- HIGH/MEDIUM/LOW --> |

<!-- Flag any surface that processes personal data without checking consent state. Flag workers and cron jobs that run outside user sessions if they do not independently verify consent before processing. -->

---

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Pre-consent data transmission, consent mechanism entirely absent for required processing, hardcoded consent bypass, dead-end or misleading consent controls |
| **HIGH** | Enforcement gap (capture without gate), withdrawal harder than granting, bundled consent for separable purposes, conflicting information |
| **MEDIUM** | Dark pattern detected (non-critical), cross-surface sync gap, missing granularity, privacy maze |
| **LOW** | Copy clarity improvement, minor friction asymmetry, documentation gap, lacking hierarchy |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Script load order visible, enforcement point present or absent, click count measurable | Finding can be acted on directly |
| **MEDIUM** | Legal basis determination, partial code visibility, dark pattern requires judgment | Review recommended before acting |
| **LOW** | Visual-only dark pattern, runtime-dependent behaviour, third-party SDK internals | Consult privacy professional or conduct manual UI review |
