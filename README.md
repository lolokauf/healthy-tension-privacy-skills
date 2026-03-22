# Healthy Tension Privacy Skills

> Composable privacy skills for coding agents. Make any AI-assisted development workflow privacy-aware by default.

**This library is not legal advice.** It provides structured privacy analysis frameworks for AI coding agents. Output requires human review, especially for regulatory compliance decisions.

---

## What This Is

A collection of reusable, tested privacy skills that guide AI coding agents through privacy engineering tasks — code reviews, data mapping, impact assessments, and more. Each skill follows a consistent format and produces structured, auditable output.

**Built for:**
- Software engineers adding privacy checks to their development workflow
- Privacy PMs and DPOs using coding agents to build privacy-compliant products

**Works with:**
- [Claude Code](https://claude.ai/code) — install as a plugin or add SKILL.md to your project (see [Claude Code Setup](#claude-code-setup))
- Any LLM-assisted workflow — skills are portable markdown, not platform-locked

## Skills

| Skill | Description | Personas | Jurisdiction | Version | Status |
|-------|-------------|----------|--------------|---------|--------|
| [PbD Code Review](skills/pbd-code-review/) | Review code against Cavoukian's 7 Privacy by Design principles. Produces PII manifests, config audits, data flow heatmaps, and a compiled Privacy Review Report. | engineer, privacy-pm, dpo | principle-based, GDPR Art. 25, CCPA §1798.100 | 2.2.0 | Stable |
| [Data Mapping](skills/data-mapping/) | Map and inventory all personal data in a codebase. Identifies collection points, storage, flows, sharing, and retention. Produces a structured data inventory consumable by other skills. | engineer, privacy-pm, dpo | GDPR Art. 30, CCPA §1798.100(b) | 1.2.0 | Stable |
| [Consent Flow Reviewer](skills/consent-flow-review/) | Audit consent mechanisms for validity, enforcement, dark patterns, and withdrawal. Produces enforcement maps, dark pattern findings, and withdrawal traces. | engineer, privacy-pm, dpo | GDPR Art. 7, ePrivacy Art. 5(3), CCPA opt-out, LGPD Art. 8 | 1.0.0 | Stable |
| [DPIA Generator](skills/dpia-generator/) | Generate draft Data Protection Impact Assessments from code. Evaluates triggers per WP29 9-criteria, maps processing activities, assesses risks, recommends mitigations. | privacy-pm, dpo, engineer | GDPR Art. 35–36, LGPD Art. 38 | 1.0.0 | Stable |
| [CCPA/CPRA Review](skills/ccpa-review/) | Assess CCPA/CPRA compliance: PI classification by 11 statutory categories, sale/sharing analysis, consumer rights audit, vendor classification, and opt-out mechanisms. | engineer, privacy-pm, dpo | CCPA/CPRA, CPPA regulations | 1.0.0 | Stable |

## Quick Start

### 1. Download a skill

Clone this repo or download the SKILL.md file for the skill you need:

```bash
git clone https://github.com/lolokauf/healthy-tension-privacy-skills.git
```

### 2. Load the skill into your agent

**Claude Code:** See [Claude Code Setup](#claude-code-setup) for plugin install, local loading, and manual options.

**Other AI tools:** Paste the SKILL.md content as a system prompt or initial context. For detailed analysis, also include the supporting files from the skill's directory (checklists, templates).

### 3. Run on your code

Point your agent at a codebase, PR, or set of files. The skill guides the agent through a structured process and produces the specified output automatically.

```
Review this codebase using the PbD Code Review skill.
```

```
Map all personal data in this project using the Data Mapping skill.
```

## Claude Code Setup

Three ways to use these skills with [Claude Code](https://claude.ai/code):

### Plugin (recommended)

Install the plugin to get all skills with namespaced commands:

```bash
/plugin marketplace add lolokauf/healthy-tension-privacy-skills
/plugin install healthy-tension-privacy@healthy-tension-privacy-skills
```

Skills are invoked as `/healthy-tension-privacy:pbd-code-review`, `/healthy-tension-privacy:data-mapping`, etc.

### Local plugin

Load the repo directly during development:

```bash
claude --plugin-dir /path/to/healthy-tension-privacy-skills
```

### Manual

Copy any skill's `SKILL.md` into your project's `.claude/skills/` directory:

```bash
mkdir -p .claude/skills/pbd-code-review
cp healthy-tension-privacy-skills/skills/pbd-code-review/SKILL.md .claude/skills/pbd-code-review/
```

Skills are invoked without namespacing (e.g., `/pbd-code-review`). For skills with supporting files (checklists, templates), copy the entire skill directory.

## Evaluation

Every skill is evaluated against real open-source codebases using an automated evaluation suite with LLM-as-judge scoring. The suite tests both **accuracy** (does the skill find what matters?) and **quality** (is the output well-structured and actionable?), plus **adversarial resistance** (does the skill resist prompt manipulation?).

Contributors run the public eval suite before submitting PRs. The maintainer runs an additional private holdout suite during review. See [eval/README.md](eval/README.md) for details.

## Design Principles

1. **Privacy-first, not compliance-first.** Skills help build genuinely privacy-respecting systems, not just check regulatory boxes.
2. **Jurisdiction-aware, not jurisdiction-locked.** Skills declare which frameworks they reference but default to principle-based reasoning.
3. **Transparent about limitations.** Every skill includes a "What This Skill Cannot Do" section. AI-generated analysis is never presented as legal advice.
4. **Composable, not monolithic.** Skills do one thing well and reference other skills where appropriate.
5. **Auditable outputs.** Every assessment includes confidence levels and shows its reasoning.
6. **Tested before deployed.** Skills ship with worked examples and are tested against real-world scenarios.

## Shared Resources

The [`shared/`](shared/) directory contains cross-skill reference materials:

- [Jurisdiction Profiles](shared/jurisdiction-profiles.md) — GDPR, CCPA/CPRA, LGPD, ePrivacy summaries
- [Privacy Principles](shared/privacy-principles.md) — Cavoukian, Nissenbaum, Solove, FIPPs frameworks
- [Glossary](shared/glossary.md) — Consistent terminology with cross-jurisdictional equivalents
- [Threat Model Primer](shared/threat-model-primer.md) — Privacy threat categories and LINDDUN methodology

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose, write, test, and submit new skills.

## License

[MIT](LICENSE)

## Links

- [Healthy Tension](https://healthy-tension.com) — Privacy tools and resources
- [Privacy Skills](https://healthy-tension.com/tools/privacy-skills) — Web interface for browsing skills
- [Substack](https://healthytension.substack.com) — Privacy engineering newsletter
