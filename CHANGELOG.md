# Changelog

All notable changes to the Healthy Tension Privacy Skills library are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). Individual skills also maintain their own `## Changelog` section within their SKILL.md files for skill-specific version history.

---

## [Unreleased]

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
- `eval/run-adversarial.sh` — adversarial resistance testing (5 cases: skip, downplay, override, scope-reduction, false-compliance)
- `eval/judge-prompt.md` — LLM judge with forced D1 counting, verdict hard gates, sum/max quality format
- `eval/auditor-prompt.md` — adversarial resistance auditor prompt
- `eval/generate-ground-truth.sh` — auto-generates ground truth from skill output
- `eval/extract-output.sh` — extraction pipeline with exit codes
- `eval/clone-targets.sh` — OSS target repo cloning with commit pinning
- `eval/adversarial-cases.md` — 5 adversarial case definitions with expected behaviours

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
