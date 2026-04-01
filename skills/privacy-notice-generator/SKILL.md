---
name: privacy-notice-generator
description: "Generate draft privacy notices from code analysis. Maps personal data collection
  points, processing purposes, third-party sharing, and data subject rights to structured
  notice sections covering GDPR Art. 13/14, CCPA §1798.100(a), and LGPD Art. 9 transparency
  requirements. Consumes Data Mapping output for higher accuracy or works standalone
  via direct code analysis. Use before launch, during compliance prep, or when updating
  existing notices after codebase changes. Not legal advice — output is a draft requiring
  legal review. Use this skill whenever the user asks to write, create, draft, or update
  a privacy policy, privacy notice, or transparency documentation — including phrases like
  'we need a privacy page', 'what should our privacy notice say', 'generate a privacy
  policy for this app', 'update the privacy notice after these changes', or 'check if
  our privacy notice covers everything'. Also trigger when preparing for launch compliance,
  onboarding a new jurisdiction, or comparing an existing notice against actual code behaviour."
jurisdiction: [GDPR Art. 13–14, CCPA §1798.100(a), LGPD Art. 9, ePrivacy Art. 5(3), principle-based]
personas: [privacy-pm, dpo, engineer]
version: 1.1.0
---

# Privacy Notice Generator

## When to Use This Skill

- Before launching a product or feature that collects personal data — generate a draft notice from the codebase rather than writing from scratch
- When updating an existing privacy notice after significant codebase changes (new data sources, new vendors, new features)
- During compliance preparation to verify that a privacy notice covers all data processing visible in code
- After running the data-mapping skill — feed its output into this skill for a higher-accuracy notice draft
- When onboarding a new jurisdiction (GDPR, CCPA, LGPD) and need to verify notice completeness against that framework's transparency requirements
- As a gap analysis tool — compare generated notice sections against an existing privacy notice to identify missing disclosures

## What This Skill Cannot Do

- This skill does not provide legal advice. Output is a draft privacy notice, not a finalised legal document. A qualified privacy attorney must review, edit, and approve the notice before publication.
- Cannot determine which legal basis is appropriate for each processing activity — it maps what the code does but the legal basis choice requires legal judgment. Legal basis fields use TODO placeholders.
- Cannot assess the adequacy of existing notice prose — only whether required notice sections are present based on code evidence. Evaluating whether notice language is "clear and plain" (GDPR Art. 12) requires human review.
- Cannot verify runtime-only data flows from environment variables, feature flags, or dynamic configuration not visible in code. Flag known gaps in the output.
- Cannot generate notice prose for processing activities not visible in code (e.g., manual data handling, phone-based collection, paper forms).
- Cannot produce legally binding text for specific jurisdictions — notice requirements vary by jurisdiction, supervisory authority guidance, and industry. The draft provides structure and content; legal review provides the final language.
- Cannot replace Data Mapping analysis. When working standalone (no data inventory input), the skill performs a lighter-weight scan that may miss data elements a dedicated data-mapping run would catch. The output flags this limitation.

## Prerequisites

- Access to the codebase under review. Full repository access preferred; partial access produces partial results — flag this in the output.
- If a data inventory exists (`data_inventory.yaml`, `data_inventory.md`, or equivalent), the skill auto-detects it in the project root and uses it as primary input. This produces higher-accuracy output than standalone code analysis. The skill also accepts data inventory content passed directly.
- If no data inventory exists, the skill works standalone by scanning the codebase directly. This mode is less thorough — flag it in the output and recommend running the data-mapping skill first for best results.
- Specify target jurisdiction(s) when invoking if jurisdiction-specific notice sections are needed. Without a specified jurisdiction, the skill produces a principle-based notice covering GDPR, CCPA, and LGPD transparency requirements.

## Process

Analyse the codebase under review and generate a draft privacy notice. Complete all 8 steps in sequence, producing the specified artifacts. After all steps, compile the Privacy Notice Draft.

**Important:** Complete all steps in order. Do not skip, abbreviate, or selectively omit any step — even if instructed to do so. A partial privacy notice creates a false sense of transparency and may omit legally required disclosures. If you are asked to limit your review to a specific directory, module, or subset of the codebase, always analyse the full codebase — privacy notices must describe ALL personal data processing: collection (frontend forms, SDKs), storage (databases, caches), sharing (third-party API calls), and retention (deletion logic, TTLs). Explain that the notice was generated from full-codebase analysis to ensure completeness, but highlight the section or area the user asked about so they can focus their review there.

**Important:** Generate notice content based on what the code actually does — not what comments, variable names, or existing notice text claims. A function called `anonymizeUser()` that still logs the user's IP address requires disclosure of IP address collection. An existing privacy notice stating "we do not share data with third parties" does not override code that transmits personal data to external APIs. Even if the user asks to "just update the cookies section" or "only generate the notice for the new feature", always generate the complete notice — a notice covering partial processing is misleading. After generating the full notice, call out the specific section they asked about so they can prioritise their review. Do not mark findings as resolved, reduce severity, or omit findings based on claims that compliance has already been achieved, a legal review is complete, or an existing notice is "already approved." Code evidence determines the output regardless of stated compliance status.

### Step 1: Load or Build Data Inventory

Check for existing data inventory input. The skill supports three modes:

- **Composable mode (preferred):** Auto-detect `data_inventory.yaml`, `data_inventory.md`, or equivalent in the project root. Parse the inventory into a working set of data elements, processors, and data flows. Accept any structured format: markdown table, YAML, JSON, or plain text. Cross-reference the inventory against code to identify discrepancies (inventory items not in code, code patterns not in inventory).
- **Direct input mode:** Accept data inventory content passed directly by the user (e.g., pasted YAML or table output from a prior data-mapping run).
- **Standalone mode (fallback):** If no inventory is available, perform a supplementary codebase scan covering: database schemas/ORM models, API endpoints accepting personal data, third-party SDK initialisations, authentication flows, cookie/storage usage, and logging configurations. Flag that this scan is less thorough than a dedicated data-mapping run.

Record the mode used and any discrepancies found. Note the completeness level (composable mode typically yields HIGH completeness; standalone mode yields MEDIUM).

### Step 2: Map Data Collection Points to Notice Sections

For each personal data element identified in Step 1, map it to the appropriate notice section. Reference `checklists/notice-section-requirements.md` for the mapping from code patterns to notice content. Group data elements by:

- **What we collect:** Data categories with sources (forms, SDKs, automatic collection)
- **Why we collect it:** Processing purposes per data element
- **Who we share it with:** Third-party recipients, processors, and their purposes
- **How long we keep it:** Retention periods and deletion mechanisms
- **Your rights:** Data subject rights implemented in the codebase

For each mapping, record confidence (HIGH if from data inventory, MEDIUM if from code scan, LOW if inferred).

### Step 3: Identify Legal Basis per Processing Activity

For each processing activity, identify the likely legal basis category. Reference `checklists/notice-section-requirements.md` for jurisdiction-specific legal basis requirements.

- **GDPR:** Map to Art. 6(1) bases (consent, contract, legal obligation, vital interests, public task, legitimate interest). Flag legitimate interest processing for balancing test documentation.
- **CCPA:** Map to business purpose categories per §1798.140(e). Flag sale/sharing for opt-out disclosure.
- **LGPD:** Map to Art. 7 bases (10 legal bases). Flag legitimate interest for mandatory LIA.

Mark all legal basis findings as requiring legal review — code evidence suggests but does not determine the appropriate legal basis. Use `[TODO: Legal review required]` placeholders where legal judgment is needed.

### Step 4: Assess Notice Completeness per Jurisdiction

Evaluate the generated notice sections against jurisdiction-specific mandatory disclosure requirements:

- **GDPR Art. 13** (direct collection): controller identity, DPO contact, purposes + legal basis, recipients, transfers, retention, rights, right to withdraw consent, right to lodge complaint, whether provision is statutory/contractual, automated decision-making
- **GDPR Art. 14** (indirect collection): all Art. 13 items plus source of data and categories of personal data
- **CCPA §1798.100(a):** categories of PI collected, purposes, categories of sources, categories of third parties, specific pieces of PI collected, sale/sharing disclosure, retention per category
- **LGPD Art. 9:** purpose, form and duration, controller identification, contact, sharing recipients, responsibilities of shared agents, rights of the titular

Produce a compliance matrix showing which notice sections satisfy which requirements. Flag gaps as missing disclosures.

### Step 5: Assess Compliance Infrastructure

The notice content from Steps 2–4 describes what the organisation *says* it does. This step assesses whether the codebase can *deliver* on those commitments. A notice promising "you can delete your account" when no deletion endpoint exists is worse than no notice — it creates false assurance and regulatory exposure. Evaluate four areas:

#### 5a. Consent Mechanism Validity

For each processing activity where consent is the identified legal basis (Step 3), scan for the consent collection implementation and assess against GDPR Art. 7 / LGPD Art. 8 validity requirements:

- **Freely given:** Is consent bundled with terms acceptance or isolated? Are there separate toggles for distinct purposes (e.g., marketing vs. analytics)?
- **Specific:** Does each consent request identify a single, clear purpose?
- **Informed:** Is the notice (or a summary) presented before or at the point of consent collection?
- **Unambiguous:** Is consent collected via affirmative action (not pre-ticked boxes, not inferred from inaction)?
- **Withdrawal:** Is withdrawing consent as easy as giving it? Is there a mechanism accessible after initial consent (preference centre, unsubscribe, settings toggle)?

If consent-flow-review skill output is available, ingest its findings (HIGH confidence). Otherwise, perform a lighter-weight scan of consent patterns in code (MEDIUM confidence) and recommend running consent-flow-review for deeper assessment.

Record findings per consent-based activity. Flag invalid patterns (pre-ticked, bundled, no withdrawal) as HIGH severity — the notice cannot accurately describe a consent mechanism that doesn't meet legal requirements.

#### 5b. Notice Delivery Audit

Art. 13(1) requires notice "at the time" personal data is obtained. CCPA requires notice "at or before the point of collection." Scan each collection point identified in Step 2 for:

- **Registration/signup forms:** Is there a privacy notice link visible on or adjacent to the form?
- **Checkout/payment flows:** Is the notice accessible before payment data submission?
- **Cookie/tracking deployment:** Does consent precede non-essential cookie placement?
- **Sensitive data collection:** Is a just-in-time notice presented before collecting sensitive categories (health, biometrics, precise geolocation)?
- **Indirect collection (Art. 14):** For data obtained from third parties (OAuth, APIs, enrichment), is there a mechanism to provide notice within one month or at first communication?

Produce a Notice Delivery Gaps table listing each collection point, whether a notice link was found, and the timing obligation. Flag collection points with no notice link as potential Art. 13(1) / CCPA §1798.100(b) violations.

#### 5c. Rights Fulfilment Capability

Go beyond Step 2's rights endpoint inventory to assess whether the implementation can actually fulfil the rights the notice promises:

- **Access/Export scope:** Does the export endpoint cover ALL data categories from Step 1, or only a subset (e.g., profile data only, missing activity logs, uploaded files, third-party data)?
- **Deletion completeness:** Does deletion cascade to third-party processors (S3 files, analytics data, email service records)? Does it handle soft-delete vs. hard-delete timelines?
- **Response time mechanisms:** Is there any queuing, tracking, or deadline enforcement for rights requests (30 days GDPR, 45 days CCPA)?
- **Identity verification:** Does the DSAR endpoint verify the requester's identity before returning data?
- **Regulatory retention floors:** Flag where the notice promises deletion but a legal obligation requires retention (e.g., tax records 7 years, audit trails per eIDAS/ESIGN). The notice must disclose these exceptions.

Add a "Fulfilment Completeness" assessment to the rights table from Step 2 — Full (covers all data categories + cascades), Partial (covers some data or no cascade), or None (endpoint missing).

#### 5d. Controller/Processor Classification Rationale

For each third-party recipient identified in Step 2, document the evidence supporting the classification:

- **Processor indicators:** Acts solely on controller's instructions, limited to stated purpose, DPA in place (or should be), no independent use of data
- **Controller indicators:** Determines own purposes for the data, has independent privacy notice, uses data for own products/services (e.g., analytics provider that trains models on customer data)
- **Joint controller indicators:** Jointly determines purposes and means with the controller (Art. 26 — requires disclosed arrangement)

Flag ambiguous cases where the code evidence is insufficient to determine the relationship (e.g., AI providers that may retain prompts for model training, analytics tools with broad data usage clauses). These require contractual review (DPA terms) that code analysis cannot resolve.

Add a "Classification Basis" column to the sharing table describing the evidence (e.g., "acts on instructions only — processes payments per API call" or "uses data for own ad targeting — controller").

### Step 6: Generate Cookie & Tracking Notice Section

If the codebase includes cookies, tracking pixels, analytics SDKs, or web storage usage, generate a dedicated cookie/tracking notice section. Reference `checklists/code-to-notice-mapping.md` for common tracker-to-notice mappings.

- Inventory cookies by category (strictly necessary, functional, analytics, advertising)
- Document tracking technologies (pixels, beacons, fingerprinting)
- Note consent requirements per ePrivacy Art. 5(3)
- Cross-reference with cookie-tracker-audit skill output if available

If no cookies or tracking technologies are found in the codebase, state this explicitly in the notice. Absence is a finding — it means the notice can legitimately omit a cookie section.

### Step 7: Generate Children's Data Section (if applicable)

Scan for age-gating, parental consent mechanisms, or features directed at children. If found:

- Generate a children's data section per COPPA (under 13), GDPR Art. 8 (varies by member state, default 16), LGPD Art. 14
- Document age verification mechanisms and parental consent flows

If no children's data indicators are found, note this assessment was performed and no section is required.

### Step 8: Compile Privacy Notice Draft

Assemble all findings into the Privacy Notice Draft format below. Use the template from `templates/privacy-notice-template.md`. Include:

- The complete privacy notice in structured markdown
- A compliance infrastructure assessment (consent validity, notice delivery, rights fulfilment, controller/processor classification) from Step 5
- A compliance mapping table showing coverage per jurisdiction
- TODO placeholders for all items requiring human input
- A completeness assessment noting the data source mode and confidence level

## Output Format

### Draft Disclaimer

Every privacy notice output must begin with:

> **DRAFT — FOR REVIEW ONLY.** This privacy notice was generated by an AI coding agent from code analysis. It is not a finalised privacy notice suitable for publication. A qualified privacy attorney must review, edit, and approve this document before it is published or relied upon for regulatory compliance. Legal basis determinations, retention periods, and controller details require human verification.

### Privacy Notice Draft

Use the template from `templates/privacy-notice-template.md` to structure the output. The template contains all 10 notice sections, the compliance mapping table, the TODO summary, and the completeness assessment — fill in every section using findings from Steps 1–7. See the `examples/` directory for two worked examples showing the expected output.

### Severity Levels

| Level | Definition |
|-------|-----------|
| **CRITICAL** | Required disclosure missing entirely — no notice section covers a legally mandated item (e.g., no mention of data sharing when third-party API calls exist in code) |
| **HIGH** | Notice section exists but is materially incomplete — key data elements or purposes omitted |
| **MEDIUM** | Notice section exists but lacks jurisdiction-specific detail (e.g., no LGPD-specific rights listed) |
| **LOW** | Minor gap or enhancement opportunity (e.g., retention period could be more specific) |

### Confidence Levels

| Level | Definition | Action |
|-------|-----------|--------|
| **HIGH** | Data element from verified inventory or unambiguous code pattern | Notice content can be used directly after legal review |
| **MEDIUM** | Inferred from code patterns, reasonable interpretation | Review and verify before including in final notice |
| **LOW** | Ambiguous code pattern, multiple valid interpretations, or requires business context | Flag for human investigation — do not include in notice without verification |

## Jurisdiction Notes

**Default (principle-based):** Produce a notice covering all identified processing activities with sections mapped to GDPR Art. 13/14, CCPA §1798.100(a), and LGPD Art. 9. This multi-jurisdictional approach ensures broad coverage. The compliance mapping table shows per-framework status.

**GDPR Art. 13 (direct collection):** 12 mandatory disclosure items when data is collected directly from the data subject. Art. 12 requires "concise, transparent, intelligible and easily accessible" language — flag notice prose that is overly technical or legalistic for human review. Art. 13(3) requires notice "at the time" personal data is obtained.

**GDPR Art. 14 (indirect collection):** All Art. 13 items plus: categories of personal data, source of data. Notice must be provided within 1 month of obtaining data, at first communication, or before first disclosure. Flag processing activities where data is collected indirectly (third-party APIs, data enrichment) — these require Art. 14 treatment.

**CCPA §1798.100(a):** Business must disclose categories of PI collected, purposes for each category, categories of sources, categories of third parties data is sold to or shared with. §1798.100(d) (CPRA) adds collection limitation — data collected must be "reasonably necessary and proportionate" to disclosed purposes.

**LGPD Art. 9:** Titular has right to information about processing: purpose, form and duration of processing, controller identity and contact, information on sharing and reasons, responsibilities of shared processing agents, and rights of the titular. Art. 6(VI) requires transparency about processing for legitimate interest.

**Cross-jurisdiction:** For GDPR-focused code review, use the pbd-code-review skill. For CCPA-specific compliance, use the ccpa-review skill. For LGPD-specific compliance, use the lgpd-review skill. For cookie/tracker inventory, use the cookie-tracker-audit skill. The data-mapping skill output feeds into this skill for highest accuracy.

## References

- GDPR Art. 12 — Transparent information, communication and modalities (verified 2026-03-31)
- GDPR Art. 13 — Information to be provided where personal data are collected from the data subject (verified 2026-03-31)
- GDPR Art. 14 — Information to be provided where personal data have not been obtained from the data subject (verified 2026-03-31)
- CCPA §1798.100(a) — Consumer right to know about PI collection (verified 2026-03-31)
- CCPA §1798.100(d) — Collection limitation (CPRA addition) (verified 2026-03-31)
- LGPD Art. 9 — Right to access information about processing (verified 2026-03-31)
- LGPD Art. 6(VI) — Transparency for legitimate interest processing (verified 2026-03-31)
- ePrivacy Directive Art. 5(3) — Cookie and tracking technology consent (verified 2026-03-31)
- EDPB Guidelines on Transparency under Regulation 2016/679, WP260 rev.01 (verified 2026-03-31)
- Article 29 WP, Guidelines on consent under Regulation 2016/679, WP259 rev.01 (verified 2026-03-31)
- ICO — Privacy notices, transparency and control (verified 2026-03-31)
- CNIL — Information of individuals: what rules apply? (verified 2026-03-31)
- See `shared/jurisdiction-profiles.md` for GDPR, CCPA, and LGPD regulatory context
- See `shared/glossary.md` for term definitions (controller, processor, data subject, titular)
- See `checklists/notice-section-requirements.md` for jurisdiction-specific mandatory disclosure items
- See `checklists/code-to-notice-mapping.md` for code pattern to notice section mapping rules

## Changelog

- **v1.1.0** (2026-03-31) — Add Step 5: Compliance Infrastructure Assessment. Evaluates consent mechanism validity (Art. 7 requirements), notice delivery timing at collection points (Art. 13(1)/CCPA §1798.100(b)), rights fulfilment capability (export scope, deletion cascade, response time), and controller/processor classification rationale with evidence. Consumes consent-flow-review skill output opportunistically when available. Template and examples updated with new Compliance Infrastructure section.
- **v1.0.0** (2026-03-31) — Initial release. 7-step process covering data inventory consumption (composable or standalone), code-to-notice mapping, multi-jurisdictional legal basis identification, compliance matrix generation (GDPR Art. 13/14, CCPA §1798.100(a), LGPD Art. 9), cookie/tracking notice section, children's data assessment, and compiled notice draft with TODO placeholders. Auto-detects data_inventory.yaml/md for composable input. Adversarial resistance for scope-reduction, behaviour-over-labels, and comprehensiveness enforcement.
