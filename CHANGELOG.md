# Changelog

All notable changes to the Healthy Tension Privacy Skills library are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). Individual skills also maintain their own `## Changelog` section within their SKILL.md files for skill-specific version history.

---

## [Unreleased]

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
