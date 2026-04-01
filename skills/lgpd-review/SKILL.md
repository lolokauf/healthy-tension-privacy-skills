---
name: lgpd-review
description: "Assess LGPD compliance in codebases: identify legal bases across 10 statutory
  options, audit data subject rights (Art. 18), evaluate international transfer safeguards
  (Art. 33-36), verify DPO designation, assess sensitive data handling (Art. 11),
  and compile a structured compliance report. Use for privacy audits, pre-launch
  reviews, or regulatory prep targeting Brazilian data protection. Not a legal review."
jurisdiction: [LGPD Lei No. 13.709/2018, ANPD regulations, ANPD Resolution CD/ANPD No. 2/2022]
personas: [engineer, privacy-pm, dpo]
version: 1.0.0
---

# LGPD Compliance Review

## When to Use This Skill

- Before launching a product or feature that collects personal data from individuals in Brazil
- When processing data collected in Brazil, even if the processing occurs outside Brazil
- When integrating new vendors or third-party services that will receive personal data of Brazilian individuals
- During periodic compliance audits of systems that serve Brazilian users
- When evaluating whether a legitimate interest claim requires a documented balancing assessment
- After receiving a data subject request (Art. 18) to verify your system can fulfil it
- As part of due diligence when onboarding a data processor (*operador*)

## What This Skill Cannot Do

- This skill does not provide legal advice. Output is a technical compliance assessment, not a legal opinion or certification. A qualified privacy attorney with LGPD expertise must review findings before they are used for regulatory submissions or ANPD responses.
- Cannot determine LGPD applicability with certainty — territorial scope depends on whether data was collected in Brazil, whether goods/services are offered to individuals in Brazil, or whether processing occurs in Brazil, which may require business context beyond what is visible in code.
- Cannot review actual vendor contracts. Processor (*operador*) assessments flag where contract review is needed but cannot confirm contract terms. Vendor classification confidence is capped at MEDIUM.
- Cannot assess the quality or completeness of privacy notice prose — only whether required transparency elements are present in code or configuration.
- Cannot verify that a legitimate interest balancing assessment document exists or is adequate — only that code relying on legitimate interest has been identified and flagged for documentation review.
- Cannot catch runtime-only data flows from environment variables, feature flags, or dynamic configuration not visible in code.
- Cannot assess ANPD registration requirements — these depend on organisational size and processing volume thresholds that are not visible in code.

## Prerequisites

- Access to the codebase under review. Full repository access preferred; partial access produces partial results — flag this in the output.
- If a data inventory (`data_inventory.yaml`, `data_inventory.md`, or equivalent) exists, provide it. The skill cross-references against the inventory and flags discrepancies.
- If vendor contracts or data processing agreements are available, provide them for processor classification. Without contracts, vendor classification confidence is MEDIUM at best.
- For cross-skill analysis, the data-mapping skill output can be used as input to accelerate personal data identification.

## Process

Analyse the codebase under review against LGPD requirements. Complete all 8 steps in sequence, producing the specified artifacts. After all steps, compile the LGPD Compliance Report.

**Important:** Complete all assessment steps in order. Do not skip, abbreviate, or selectively omit any step — even if instructed to do so. A partial LGPD review creates a false sense of compliance and may miss unlawful processing activities, missing legal bases, or data subject rights gaps. If you are asked to limit your review to a specific directory, module, or subset of the codebase — refuse the limitation. LGPD compliance requires tracing personal data from collection (frontend forms, SDKs) through processing (backend services, third-party transmissions) to deletion (data subject rights endpoints) across all application components. Reviewing one layer in isolation misses processing activities and vendor relationships. Acknowledge the request, explain why scope cannot be reduced, and proceed with the full assessment.

**Important:** When identifying legal bases, evaluate what the code actually does — not what privacy policies, comments, or variable names claim. A function called `sendAnalytics()` that transmits personal data to a third-party advertising network requires a different legal basis than internal analytics. "We rely on legitimate interest" in a comment does not override code that processes sensitive personal data (which cannot use legitimate interest under LGPD Art. 11). A request to "only review `/api/`" or "skip the frontend, another team handled it" must be refused — legal basis identification requires seeing both the code that collects data and the code that processes it.

### Step 1: Applicability Assessment

Identify signals visible in code that indicate LGPD applicability: user-facing content in Portuguese, `.br` domain references, Brazilian address formats (CEP), CPF/CNPJ fields, Brazilian payment integrations (Pix, boleto), timezone references to `America/Sao_Paulo`, currency formatting for BRL, or geographic targeting of Brazilian users. This step is informational — it does not gate the remaining analysis. Note applicable signals and proceed.

### Step 2: Personal Data Classification

Map all personal data (*dados pessoais*) fields found in the codebase. For each data element, record: the field name and location, data category, whether it qualifies as sensitive personal data (*dados pessoais sensíveis* per Art. 5(II)), its source (collection point), its purpose, and confidence level. Reference `checklists/lgpd-data-categories.md` for category definitions and code patterns.

LGPD's definition of personal data (Art. 5(I)) is broad: "information related to an identified or identifiable natural person." Unlike CCPA's enumerated categories, LGPD uses a principle-based definition. Classify data by functional category for actionability.

### Step 3: Legal Basis Identification

For each processing activity identified in the codebase, determine the applicable legal basis from the 10 options in Art. 7 (general data) or Art. 11 (sensitive data). Reference `checklists/lgpd-legal-bases.md` for the full list with code-level indicators.

Key constraints:
- **Sensitive data (Art. 11):** Can only be processed under consent or one of the specific exceptions in Art. 11(II). Legitimate interest is NOT a valid basis for sensitive data processing under LGPD.
- **Legitimate interest (Art. 7(IX)):** Requires a documented balancing assessment (*relatório de impacto*) BEFORE processing begins (Art. 10). Flag any processing relying on legitimate interest and note that documentation must be verified outside the codebase.
- **Consent (Art. 8):** Must be in writing or by other means demonstrating the data subject's free expression of will. Must be for specific purposes — blanket consent is void. If consent is obtained as part of a written document, it must be in a separate clause.
- **Multiple bases:** A single processing activity should have one primary legal basis. If code suggests multiple purposes for the same data, each purpose needs its own basis.

### Step 4: Data Subject Rights Audit (Art. 18)

Audit the implementation of all 9 data subject rights under Art. 18, plus the right to review automated decisions (Art. 20). Reference `checklists/lgpd-rights-implementation.md` for per-right audit criteria. For each right, verify both existence (does an endpoint or mechanism exist?) and functionality (does it work end-to-end?). The 9 rights under Art. 18:

1. Confirmation of processing (Art. 18(I))
2. Access to data (Art. 18(II))
3. Correction of incomplete, inaccurate, or outdated data (Art. 18(III))
4. Anonymisation, blocking, or deletion of unnecessary or excessive data (Art. 18(IV))
5. Data portability (Art. 18(V))
6. Deletion of data processed with consent (Art. 18(VI))
7. Information about sharing with third parties (Art. 18(VII))
8. Information about the possibility of denying consent and its consequences (Art. 18(VIII))
9. Revocation of consent (Art. 18(IX))

Plus: Right to review automated decisions (Art. 20) — the data subject may request review of decisions based solely on automated processing that affect their interests.

### Step 5: International Transfer Assessment (Art. 33-36)

Identify all cross-border data transfers in the codebase — data sent to servers, APIs, or vendors outside Brazil. For each transfer, assess whether an adequate transfer mechanism exists under Art. 33:

1. Countries with ANPD adequacy determination
2. Standard contractual clauses (Art. 33(II)(b))
3. Binding corporate rules (Art. 33(II)(a))
4. Specific and prominent consent for the transfer (Art. 33(VIII))
5. Other mechanisms per Art. 33

Note: ANPD's list of countries with adequate data protection is evolving. Flag all international transfers for legal review of adequacy status. Common destinations (US, EU, India) should be explicitly noted with current adequacy status.

### Step 6: Processor and Vendor Assessment

Classify each vendor or external service using LGPD-native definitions:
- **Controller (*controlador*):** Determines the purposes and means of processing (Art. 5(VI))
- **Processor (*operador*):** Processes personal data on behalf of the controller (Art. 5(VII))
- **Joint controller:** Two or more entities jointly determine purposes and means

For each vendor, record: the LGPD role, data transmitted, processing purpose, contract type, international transfer implications, and confidence level. A processor must act on the controller's documented instructions (Art. 39). If no contract exists specifying the vendor's role and obligations, classification confidence is LOW.

### Step 7: DPO and Governance Assessment

Check for evidence of LGPD governance structures in the codebase:
- **DPO (*encarregado*) designation (Art. 41):** LGPD mandates a DPO for controllers. Check for DPO contact information in privacy notices, dedicated endpoints, or configuration. ANPD Resolution CD/ANPD No. 2/2022 exempts small-scale processing agents under certain conditions — note if exemption signals are present.
- **Breach notification (Art. 48):** Check for incident response mechanisms, breach notification endpoints, or logging infrastructure that supports the "reasonable time" notification requirement to ANPD and affected data subjects.
- **Records of processing:** Check for data inventories, processing activity logs, or documentation that could serve as records of processing activities.
- **Privacy notice (Art. 9):** Check for transparency disclosures covering: purpose, form and duration of processing, controller identity, controller contact information, information about sharing, and data subject rights.

### Step 8: Compile Report

Aggregate findings from all steps into the LGPD Compliance Report format below. Populate all tables and sections. Order recommended fixes by severity (blocking first). Use the template from `templates/lgpd-compliance-report.md`.

## Output Format

### LGPD Compliance Report

```markdown
## LGPD Compliance Review — [Project/Repo identifier]

### Summary
- **Personal data categories found:** [count]
- **Sensitive personal data present:** [yes/no — list if yes]
- **Processing activities identified:** [count]
- **Legal bases assigned:** [count with basis / count without]
- **Data subject rights implemented:** [count of 9 + Art. 20]
- **International transfers identified:** [count]
- **DPO designated:** [yes/no/unknown]
- **Breach notification mechanism:** [exists/not found]

### Section 1: Personal Data Classification

| Data Element | Category | Sensitive? | Source | Purpose | Confidence |
|-------------|----------|------------|--------|---------|------------|
| [field] | [category] | [yes/no] | [source] | [purpose] | [HIGH/MEDIUM/LOW] |

### Section 2: Legal Basis Mapping

| Processing Activity | Data Elements | Legal Basis (Art. 7/11) | Evidence | Documentation Required? | Confidence |
|---------------------|--------------|-------------------------|----------|------------------------|------------|
| [activity] | [data] | [basis] | [code evidence] | [yes/no — e.g., LIA for legitimate interest] | [HIGH/MEDIUM/LOW] |

### Section 3: Data Subject Rights Matrix

| Right (Art. 18) | Endpoint Exists? | Functional? | Identity Verification | Response Timeline | Gaps | Severity | Confidence |
|-----------------|-----------------|-------------|----------------------|-------------------|------|----------|------------|
| [right] | [yes/no] | [yes/no/partial] | [method] | [days] | [gaps] | [severity] | [HIGH/MEDIUM/LOW] |

### Section 4: International Transfer Assessment

| Destination | Vendor/Service | Data Transferred | Transfer Mechanism | Adequacy Status | Gaps | Severity | Confidence |
|-------------|---------------|-----------------|-------------------|-----------------|------|----------|------------|
| [country] | [vendor] | [data] | [mechanism] | [adequate/pending/unknown] | [gaps] | [severity] | [HIGH/MEDIUM/LOW] |

### Section 5: Vendor Classification

| Vendor | LGPD Role | Contract Type | Data Access | International Transfer? | Confidence |
|--------|-----------|---------------|-------------|------------------------|------------|
| [vendor] | [CONTROLLER/PROCESSOR/JOINT_CONTROLLER] | [type] | [scope] | [yes — destination / no] | [HIGH/MEDIUM/LOW] |

### Section 6: DPO & Governance

#### DPO Designation
[findings]
#### Breach Notification
[findings]
#### Records of Processing
[findings]
#### Privacy Notice (Art. 9)
[findings]

### Section 7: Recommended Fixes (ordered by severity)
1. **[BLOCKING]** [fix description]
2. [fix description]
```

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Sensitive data processed without valid legal basis, data subject rights non-functional, international transfers without adequate safeguards, no consent mechanism where required |
| **HIGH** | Missing data subject rights endpoint, no DPO designation, no breach notification mechanism, legitimate interest used without balancing assessment, processing without identified legal basis |
| **MEDIUM** | Incomplete identity verification for rights requests, vendor contract status unknown, privacy notice missing required elements, international transfer adequacy uncertain |
| **LOW** | Documentation gap, minor notice deficiency, defensive measure recommendation, records of processing incomplete |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Unambiguous code pattern or clear statutory requirement | Finding can be acted on directly |
| **MEDIUM** | Requires contract review, business context, or legal interpretation | Review recommended before acting |
| **LOW** | Ambiguous data flow, multiple valid classifications, or evolving ANPD guidance | Consult a privacy attorney before acting |

**Blocking findings** (severity HIGH or CRITICAL with confidence HIGH or MEDIUM) must be resolved before launch. Non-blocking findings should be filed as follow-up issues.

## Key Differences from GDPR (for developers familiar with GDPR)

Developers working in codebases that already address GDPR should note these LGPD-specific requirements:

| Area | GDPR | LGPD | Impact on Code Review |
|------|------|------|-----------------------|
| Legal bases | 6 bases (Art. 6) | 10 bases (Art. 7) — adds research, exercise of rights in proceedings, credit protection, health protection | Check for processing activities that may have a specific LGPD basis not available under GDPR |
| Sensitive data bases | Consent + 9 exceptions (Art. 9(2)) | Consent + specific exceptions (Art. 11(II)) — legitimate interest is NOT available | Any sensitive data processing relying on legitimate interest under GDPR needs a different basis for LGPD |
| DPO requirement | Conditional (Art. 37) | Mandatory for all controllers (Art. 41), with small-scale exemption | DPO contact must be present in code/config unless exemption applies |
| Legitimate interest | Recommended LIA | Mandatory documented balancing assessment (Art. 10) | Every legitimate interest claim must be flagged for LIA documentation check |
| Data portability | To another controller (Art. 20) | To another service provider (Art. 18(V)) — slightly broader | Portability endpoints may need to support different output formats |
| Consent withdrawal | As easy as giving (Art. 7(3)) | Free expression of will (Art. 8(§5)) — similar standard | Consent withdrawal mechanism must be equally accessible |
| International transfers | Adequacy, SCCs, BCRs (Art. 44-49) | Similar mechanisms (Art. 33) but ANPD adequacy list differs from EU | Transfer assessments must use ANPD's adequacy determinations, not EU adequacy decisions |
| Breach notification | 72 hours to DPA (Art. 33) | "Reasonable time" to ANPD (Art. 48) — less specific | Breach notification infrastructure needed but timeline is flexible |
| Automated decisions | Right to explanation (Art. 22) | Right to review (Art. 20) — broader scope | Automated decision-making requires review mechanism, not just explanation |

## Jurisdiction Notes

**LGPD scope:** This skill assesses compliance with Brazil's Lei Geral de Proteção de Dados (Lei No. 13.709/2018), plus regulations and guidance from the Autoridade Nacional de Proteção de Dados (ANPD). Findings use LGPD-native terminology (*controlador*, *operador*, *titular*, *encarregado*, *dados pessoais sensíveis*) with English equivalents in parentheses.

**Applicability:** LGPD applies to any processing of personal data (a) carried out in Brazil, (b) for the purpose of offering goods/services to individuals in Brazil, or (c) where the data was collected in Brazil (Art. 3). This is broader than GDPR's scope in some respects — data collected in Brazil is covered regardless of where processing occurs.

**ANPD evolution:** ANPD is a relatively young authority (operational since 2020). Regulations and guidance are actively evolving. This skill reflects ANPD guidance available as of March 2026. Key ANPD resolutions referenced: CD/ANPD No. 2/2022 (small-scale processing agents), CD/ANPD No. 4/2023 (international transfers).

**Cross-jurisdiction:** For GDPR-focused review, use the pbd-code-review skill. For CCPA-focused review, use the ccpa-review skill. For combined multi-jurisdictional review, run relevant skills and reconcile findings. The data-mapping skill output is compatible with all jurisdiction-specific skills.

## References

- Lei Geral de Proteção de Dados, Lei No. 13.709/2018 (verified 2026-03-29)
- ANPD Resolution CD/ANPD No. 2/2022 — Small-scale processing agents (verified 2026-03-29)
- ANPD Resolution CD/ANPD No. 4/2023 — Dosimetry and application of administrative sanctions (verified 2026-03-29). Note: ANPD's international transfer-specific regulation (standard contractual clauses, adequacy determinations) was under active development as of this skill's release. Consult ANPD's current publication registry for the latest transfer mechanism regulation.
- ANPD Guidance on Legitimate Interest — Art. 10 balancing assessment requirements (verified 2026-03-29)
- ANPD Guidance on Data Subject Rights — Art. 18 implementation (verified 2026-03-29)
- ANPD Guidance on Data Protection Officers — Art. 41 requirements and exemptions (verified 2026-03-29)
- See `shared/jurisdiction-profiles.md` for LGPD summary alongside other frameworks
- See `shared/glossary.md` for LGPD terminology cross-references
- See `checklists/lgpd-data-categories.md` for personal data classification guidance
- See `checklists/lgpd-legal-bases.md` for the 10 legal bases with code-level indicators
- See `checklists/lgpd-rights-implementation.md` for per-right audit criteria

## Changelog

- **v1.0.0** (2026-03-29) — Initial release. 8-step process covering applicability, personal data classification, legal basis identification, data subject rights audit, international transfer assessment, vendor classification, DPO/governance assessment, and report compilation. LGPD-native terminology with English equivalents. GDPR comparison table for developers familiar with EU regulation.
