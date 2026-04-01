# Changelog

All notable changes to the Healthy Tension Privacy Skills library are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). Individual skills also maintain their own `## Changelog` section within their SKILL.md files for skill-specific version history.

---

## [Unreleased]

## 2026-04-01 — Eval Access Control Hardening

### Changed

**Eval suite — maintainer-private files**
- Moved `eval/adversarial-cases.md`, `eval/judge-prompt.md`, and `eval/run-adversarial.sh` to maintainer-private (gitignored, not in public repo). Prevents contributors from gaming adversarial tests or optimizing for scoring metrics.
- `eval/run-eval.sh` now gates judging on `judge-prompt.md` presence — contributors can run skills and review output without the judge. Summary reports list output files when judging is skipped.
- Updated `eval/README.md` contributor instructions to reflect maintainer-only adversarial testing.

---

## 2026-03-31 — Privacy Notice Generator Skill

### Added

**Privacy Notice Generator skill v1.0.0 (7 files)**
- `skills/privacy-notice-generator/SKILL.md` — 7-step process. Composable input: auto-detects `data_inventory.yaml`/`data_inventory.md` for higher-accuracy notice generation, or works standalone via direct code scan. Code-to-notice mapping: translates collection points, processing logic, third-party SDKs, retention mechanisms, rights endpoints, and cookies/trackers into structured notice language. Multi-jurisdictional compliance mapping: GDPR Art. 13/14, CCPA §1798.100(a), LGPD Art. 9, ePrivacy Art. 5(3). Legal basis identification with mandatory [TODO: Legal review required] placeholders. Children's data section (COPPA/GDPR Art. 8/LGPD Art. 14). Adversarial resistance (scope-reduction refusal, behaviour-over-labels, comprehensiveness enforcement). Draft disclaimer on all output.
- `skills/privacy-notice-generator/checklists/notice-section-requirements.md` — Mandatory disclosure items per jurisdiction: GDPR Art. 13 (13 items), GDPR Art. 14 (2 additional items), CCPA §1798.100(a) (10 items), LGPD Art. 9 (10 items), ePrivacy Art. 5(3) (6 items). Cross-jurisdiction comparison table. Decision tree for which sections to generate.
- `skills/privacy-notice-generator/checklists/code-to-notice-mapping.md` — Code pattern to notice section mapping rules across 9 categories: collection points, processing logic, third-party SDKs, database/storage, rights endpoints, cookies/tracking, automated decisions, international transfers, children's data. 60+ code patterns with notice language, confidence levels, and priority rules.
- `skills/privacy-notice-generator/templates/privacy-notice-template.md` — 10-section notice template with inline guidance comments, compliance mapping table, TODO summary, completeness assessment. Mirrors Output Format with per-field instructions.
- `skills/privacy-notice-generator/examples/document-signing-example.md` — Document signing platform (Documenso-style) with Next.js, Prisma, Stripe, PostHog, Resend, S3. Demonstrates composable mode (data inventory available), 18 data elements, 12 TODO items, CRITICAL findings (no account deletion, no data export), signature data disclosure.
- `skills/privacy-notice-generator/examples/saas-boilerplate-example.md` — SaaS boilerplate (Open SaaS-style) with Wasp, OpenAI, Stripe, Plausible, Sentry, S3. Demonstrates standalone mode (no data inventory), 22 data elements, 13 TODO items, CRITICAL findings (no hard delete, AI prompts persist indefinitely), recommendation to run data-mapping first.

**Evaluation ground truth (3 files)**
- `eval-holdout/targets/documenso/ground-truth-privacy-notice-generator.md` — 12 must-find items
- `eval-holdout/targets/open-saas/ground-truth-privacy-notice-generator.md` — 12 must-find items
- `eval-holdout/targets/vataxia/ground-truth-privacy-notice-generator.md` — 12 must-find items

---

## 2026-03-30 — Cookie & Tracker Audit Skill

### Added

**Cookie & Tracker Audit skill v1.0.0 (7 files)**
- `skills/cookie-tracker-audit/SKILL.md` — 7-step process. Cookie inventory (first-party/third-party, expiry, attributes, consent category). Third-party script detection (SDK imports, CDN scripts, tag manager tags). Pixel & beacon identification (Meta Pixel, GA4, Segment, sendBeacon). Fingerprinting detection (canvas, WebGL, AudioContext, navigator harvesting). Server-side tracking assessment (CAPI, server-set cookies, consent bypass). Pre-consent & consent enforcement audit with per-tracker gap analysis. GPC/DNT signal handling verification. Consent category classification per ePrivacy/CNIL/ICO (strictly necessary, functional, analytics, advertising). Adversarial resistance (scope-reduction refusal, behaviour-over-labels, absence-is-a-finding). Cross-skill composability with Consent Flow Reviewer.
- `skills/cookie-tracker-audit/checklists/tracker-fingerprints.md` — Known tracker patterns for 20+ vendors across 6 categories: analytics (GA4, Plausible, Mixpanel, PostHog, Amplitude), advertising (Meta Pixel, Google Ads, LinkedIn, TikTok, Pinterest), session replay (HotJar, FullStory, Microsoft Clarity), CDPs (Segment, Rudderstack), tag managers (GTM), CMPs (OneTrust, Cookiebot). Cookie names, script URLs, npm packages, code patterns, and server-side endpoints per vendor. Fingerprinting API reference (13 techniques with code patterns). Known fingerprinting libraries (FingerprintJS, ClientJS).
- `skills/cookie-tracker-audit/checklists/consent-categories.md` — Four-category consent model (strictly necessary, functional, analytics, advertising) with classification decision tree, per-category examples, red flags for false "strictly necessary" claims, dual-category tracker handling, data-mapping taxonomy mapping, edge cases (error tracking, reCAPTCHA, CDPs with advertising destinations).
- `skills/cookie-tracker-audit/checklists/cookie-compliance.md` — ePrivacy Art. 5(3) core requirements (prior consent, informed consent, strictly necessary exemption). GDPR Art. 6/7 consent validity (freely given, specific, informed, unambiguous, withdrawal symmetry). CNIL guidelines (refuse-as-prominent-as-accept, 13-month maximum, no cookie walls, no continue-browsing consent). ICO guidance (analytics requires consent, 12-month maximum). CCPA cookie requirements (opt-out for sale/sharing, GPC §7025). Cookie attribute security checklist (HttpOnly, Secure, SameSite). Pre-consent audit checklist. Consent withdrawal checklist.
- `skills/cookie-tracker-audit/templates/cookie-tracker-report.md` — 7-section report template mirroring Output Format with inline guidance comments. Cookie inventory, third-party script inventory, pixel & beacon inventory, fingerprinting & web storage, server-side tracking, consent enforcement matrix with strictly necessary justifications, recommended fixes.
- `skills/cookie-tracker-audit/examples/ecommerce-tracker-example.md` — Next.js fashion retailer with GA4 + Meta Pixel + Google Ads + HotJar + Segment + LinkedIn + Meta CAPI + reCAPTCHA. Demonstrates: CMP present but scripts load before CMP initialises (decorative consent), server-side CAPI bypassing client consent, HotJar in document head, Segment as hidden advertising pipeline, 2-year GA cookie exceeding CNIL maximum, 14 cookies total, 5 consent enforcement gaps, 3 pre-consent violations.
- `skills/cookie-tracker-audit/examples/saas-minimal-tracking-example.md` — React + Express SaaS with Plausible (cookieless) + Sentry + PostHog (feature flags). Demonstrates: privacy-conscious applications still have findings, cookieless analytics is not consent-free, Sentry with user context crosses analytics line, PostHog added without privacy review (tracker drift), rate limiter IP processing as transparency requirement, 3 cookies, 2 consent gaps.

**Evaluation ground truth (3 files)**
- `eval-holdout/targets/django-oscar/ground-truth-cookie-tracker-audit.md` — 12 must-find items
- `eval-holdout/targets/open-saas/ground-truth-cookie-tracker-audit.md` — 12 must-find items
- `eval-holdout/targets/discourse/ground-truth-cookie-tracker-audit.md` — 12 must-find items

---

## 2026-03-29 — LGPD Compliance Review Skill

### Added

**LGPD Review skill v1.0.0 (7 files)**
- `skills/lgpd-review/SKILL.md` — 8-step process. 10 legal bases (Art. 7) with sensitive data restrictions (Art. 11 — legitimate interest excluded). Mandatory legitimate interest assessment (Art. 10) flagging. 9 data subject rights (Art. 18) + automated decision review (Art. 20). International transfer assessment (Art. 33-36) with ANPD adequacy tracking. DPO/governance audit (Art. 41, Art. 48). GDPR comparison table for developers familiar with EU regulation. LGPD-native terminology with English equivalents.
- `skills/lgpd-review/checklists/lgpd-data-categories.md` — 12 functional categories for general personal data, 9 sensitive data types (Art. 5(II)), 9 Brazilian-specific data elements (CPF, CNPJ, RG, CNH, CTPS, PIS/PASEP, CEP, Pix key, SUS card), data-mapping taxonomy mapping, children's data note (Art. 14)
- `skills/lgpd-review/checklists/lgpd-legal-bases.md` — 10 Art. 7 bases with code patterns and documentation requirements, 8 Art. 11 bases for sensitive data, legitimate interest balancing assessment requirements (Art. 10) with red flags, consent requirements summary (Art. 8), legal basis selection decision tree
- `skills/lgpd-review/checklists/lgpd-rights-implementation.md` — 9 Art. 18 rights + Art. 20 automated decisions with per-right audit tables, Art. 16 retention exceptions, response timeline summary, identity verification guidance
- `skills/lgpd-review/examples/fintech-brazil-example.md` — Brazilian fintech with Pix, KYC biometrics, ML credit scoring, Serasa integration. Demonstrates: Art. 11(II)(g) for biometric KYC, automated decision gap (Art. 20), US backup as international transfer of sensitive data, mandatory DPO for fintech
- `skills/lgpd-review/examples/saas-international-example.md` — US-based SaaS serving Brazilian users. Demonstrates: LGPD extraterritorial reach, GDPR consent ≠ LGPD consent, GA4 as joint controller, all-data-in-US transfer problem, Portuguese privacy notice requirement
- `skills/lgpd-review/templates/lgpd-compliance-report.md` — 7 sections mirroring Output Format with inline guidance, DPO/governance subsections for encarregado designation, breach notification, records of processing, privacy notice (Art. 9)

**Evaluation ground truth (3 files)**
- `eval-holdout/targets/clinic-mgmt/ground-truth-lgpd-review.md` — 12 must-find items
- `eval-holdout/targets/django-oscar/ground-truth-lgpd-review.md` — 12 must-find items
- `eval-holdout/targets/open-saas/ground-truth-lgpd-review.md` — 12 must-find items

---

## 2026-03-22 — Phase 2: Skills Expansion + Eval Suite + Adversarial Hardening

### Added

**DPIA Generator skill v1.0.0 (6 files)**
- `skills/dpia-generator/SKILL.md` (1,981 words) — 8-step process. WP29 two-tier trigger logic (Art. 35(3) mandatory triggers evaluated independently from 9-criteria heuristic). 9-category risk taxonomy. Necessity/proportionality always LOW confidence. Consumes data-mapping output with flexible format parsing.
- `skills/dpia-generator/checklists/wp29-dpia-criteria.md` — 3 Art. 35(3) mandatory triggers + 9 WP29 criteria with concrete code patterns per criterion, borderline case guidance
- `skills/dpia-generator/templates/dpia-report-template.md` — mirrors Output Format with inline guidance comments, Mermaid data flow placeholder
- `skills/dpia-generator/examples/saas-profiling-example.md` — 4/9 criteria, ML scoring + automated decisions, Art. 35(3)(a) mandatory trigger
- `skills/dpia-generator/examples/health-app-example.md` — 4/9 criteria, Art. 35(3)(b) mandatory trigger, Art. 9 special category
- `skills/dpia-generator/examples/ecommerce-crossborder-example.md` — 4/9 criteria, cross-border transfers + dataset combination

**Consent Flow Reviewer skill v1.0.0 (6 files)**
- `skills/consent-flow-review/SKILL.md` (2,006 words) — 7-step process. GDPR Art. 4(11)/Art. 7 consent validity, EDPB Guidelines 3/2022 dark pattern taxonomy, consent enforcement map as primary output, withdrawal vs erasure distinction (Art. 7(3) vs Art. 17(1)(b)), cross-surface sync verification.
- `skills/consent-flow-review/checklists/gdpr-consent-validity.md` — Art. 4(11) 4 cumulative conditions, EDPB 05/2020 "freely given" sub-elements, ePrivacy Art. 5(3) strictly necessary decision tree, Planet49/Orange România/Fashion ID case law
- `skills/consent-flow-review/checklists/dark-patterns.md` — EDPB Guidelines 3/2022 Section 4: 6 categories × 15 sub-types, code detectability ratings (HIGH/MEDIUM/LOW/VISUAL-ONLY)
- `skills/consent-flow-review/templates/consent-flow-report-template.md` — 6 sections with guidance comments, enforcement map as separable standalone artifact
- `skills/consent-flow-review/examples/cookie-consent-banner-example.md` — pre-consent GA4, dark patterns (deceptive snugness, look over there), Meta Pixel enforcement gap
- `skills/consent-flow-review/examples/analytics-opt-in-example.md` — multi-surface app, cross-surface sync gap, 10 enforcement map entries, withdrawal asymmetry

**CCPA/CPRA Review skill v1.0.0 (6 files)**
- `skills/ccpa-review/SKILL.md` (1,890 words) — 7-step process. Two-phase sale analysis (§1798.140(ad) code pattern classification + SP/contractor exception check). 11 statutory PI categories with sensitive PI overlay. Consumer rights audit with existence + functionality checks. GPC §7025 handling. CCPA-native terminology.
- `skills/ccpa-review/checklists/ccpa-rights-implementation.md` — per-right audit tables (know, delete, correct, opt-out, limit, non-discrimination, minors), CPPA §7060-7064 identity verification tiers, response timeline table
- `skills/ccpa-review/checklists/ccpa-pi-categories.md` — 11 CCPA categories with code patterns, sensitive PI overlay (§1798.140(ae) including login credentials), data-mapping taxonomy mapping (16 entries)
- `skills/ccpa-review/templates/ccpa-compliance-report.md` — 6 sections mirroring Output Format, CCPA-native classification labels
- `skills/ccpa-review/examples/dtc-adtech-example.md` — Meta Pixel SHARING, Segment UNKNOWN, missing DNSSOPI link, no GPC handling
- `skills/ccpa-review/examples/b2b-saas-example.md` — minimal sale/sharing exposure, B2B ≠ CCPA-exempt finding

**Evaluation suite (8 files)**
- `eval/run-eval.sh` — accuracy + quality eval runner with target cloning, ground truth auto-generation, LLM judge scoring
- `eval/run-adversarial.sh` — adversarial resistance testing (moved to maintainer-private, see 2026-04-01 entry)
- `eval/judge-prompt.md` — LLM judge rubric (moved to maintainer-private, see 2026-04-01 entry)
- `eval/auditor-prompt.md` — ground truth auto-generation auditor prompt
- `eval/generate-ground-truth.sh` — auto-generates ground truth from skill output
- `eval/extract-output.sh` — extraction pipeline with exit codes
- `eval/clone-targets.sh` — OSS target repo cloning with commit pinning
- `eval/adversarial-cases.md` — adversarial case definitions (moved to maintainer-private, see 2026-04-01 entry)

**Claude Code skill distribution**
- `.claude-plugin/plugin.json` — plugin manifest (retained for future plugin system compatibility)
- `marketplace.json` — marketplace entry (retained for future compatibility)
- README.md "Claude Code Setup" section — 3 installation methods (global symlink, single skill, project-level)

**9 public ground truth files**
- `eval/targets/*/ground-truth-{pbd-code-review,data-mapping}.md` for documenso, open-saas, vataxia

### Changed

**PbD Code Review skill v2.0.0 → v2.2.0**
- v2.1.0: Added adversarial resistance grounding to Process section (skip-attack defence)
- v2.2.0: Hardened scope-reduction resistance (hard refusal with per-principle layer reasoning), Prerequisites access-vs-instruction distinction

**Data Mapping skill v1.0.0 → v1.2.0**
- v1.1.0: Added adversarial resistance grounding to Process section (proactive defence)
- v1.2.0: Hardened scope-reduction resistance (hard refusal with data-lineage reasoning), override resistance for confidence/sensitivity classifications, Prerequisites access-vs-instruction distinction

**README.md** — updated from 2-skill to 5-skill index table, added Claude Code Setup section, version bumps

## 2026-03-15 — Initial Library Release

### Added

**Repository scaffolding (9 files)**
- README.md — library overview, 2-skill index table, 3-step quick start, 6 design principles
- LICENSE (MIT), CODE_OF_CONDUCT.md (Contributor Covenant v2.1 + privacy-specific standards)
- CONTRIBUTING.md — 5-step contribution workflow, commit conventions, authoring guidelines, PR checklist, governance
- SKILL-TEMPLATE.md — blank template with all required sections, confidence level definitions, inline guidance
- GitHub templates: new-skill-proposal, skill-bug-report, skill-enhancement issue templates + PR template

**Shared reference materials (4 files)**
- `shared/jurisdiction-profiles.md` — GDPR, CCPA/CPRA, LGPD, ePrivacy Directive, 5 emerging frameworks (PIPL, DPDPA, US states, Canada, South Korea)
- `shared/privacy-principles.md` — Cavoukian PbD (7 principles table), Nissenbaum CI (5 parameters), Solove Taxonomy (4 categories, 13 sub-types), FIPPs (8 OECD principles), framework comparison table
- `shared/glossary.md` — 42 terms across 3 categories (core privacy, technical, regulatory roles) with GDPR/CCPA/LGPD equivalents
- `shared/threat-model-primer.md` — 9 privacy threat categories with code patterns, LINDDUN 7-type methodology mapped to Solove, skill blast radius framework (HIGH/MEDIUM/LOW), 6 human review triggers

**PbD Code Review skill v2.0.0 (4 files)**
- `skills/pbd-code-review/SKILL.md` (1,294 words) — migrated from standalone `pbd_review.md` prompt. 8-step process (7 Cavoukian principles + compile report). Added confidence levels (HIGH/MEDIUM/LOW) alongside severity. Added jurisdiction notes for GDPR Art. 25 and CCPA §1798.150.
- `skills/pbd-code-review/checklists/cavoukian-7-principles.md` — detailed review questions and 8 artifact table templates per principle, each with confidence guidance
- `skills/pbd-code-review/examples/express-api-example.md` — Express API with Stripe/PostHog/Sendgrid (9 findings, 8 fixes)
- `skills/pbd-code-review/examples/react-app-example.md` — React SPA with tracking pixels/consent banner/localStorage (11 findings, 9 fixes)

**Data Mapping & Inventory skill v1.0.0 (4 files)**
- `skills/data-mapping/SKILL.md` (1,599 words) — 7-step process for inventorying personal data. Outputs: 11-column data inventory table, 7-column processor table, Mermaid data flow diagram, gap analysis, completeness score. GDPR Art. 30 RoPA mapping table, CCPA category mapping.
- `skills/data-mapping/templates/data-inventory-template.md` — output schema ("API contract" for downstream skills), column definitions, 16-category PII taxonomy with GDPR/CCPA mappings, YAML schema with required/optional annotations, regulatory field mapping table
- `skills/data-mapping/examples/saas-app-example.md` — SaaS with Stripe/PostHog/Sendgrid/S3/Redis (13 data elements, 4 processors, 69% completeness)
- `skills/data-mapping/examples/mobile-app-example.md` — fitness app with Firebase/AdMob/Mixpanel/HealthKit (20 data elements, 5 processors, 75% completeness, health data special-category flagged)
