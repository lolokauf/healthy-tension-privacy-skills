# Contributing to Healthy Tension Privacy Skills

Thank you for your interest in contributing privacy skills. This guide covers how to propose, write, test, and submit skills to the library.

## Before You Start

Please read:
- [README.md](README.md) — what this library is and its design principles
- [SKILL-TEMPLATE.md](SKILL-TEMPLATE.md) — the format every skill must follow
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — community standards

## Contribution Workflow

### 1. Propose (Issue)

Open a GitHub issue using the **New Skill Proposal** template. Your proposal should include:

- **Skill name** and target user persona(s)
- **Regulatory scope** — which frameworks the skill references
- **2–3 example scenarios** with expected outputs
- **Threat model** — what goes wrong if this skill gives bad advice?
- **Prior art** — existing tools, templates, or resources in this space

Maintainers will evaluate proposals against the [design principles](README.md#design-principles) and comment on scope, feasibility, and fit.

### 2. Discuss

Community discussion happens on the issue. This is where we align on:
- Whether the skill fits the library's scope
- Which personas benefit most
- How the skill interacts with existing skills (dependencies, composability)
- Regulatory accuracy concerns

### 3. Draft (Pull Request)

Once the proposal is accepted:

1. Fork the repository
2. Create a branch: `feature/[skill-name]`
3. Create the skill directory: `skills/[skill-name]/`
4. Write `SKILL.md` following [SKILL-TEMPLATE.md](SKILL-TEMPLATE.md)
5. Add supporting files (checklists, templates, examples)
6. Update the skill index table in `README.md`
7. Open a PR using the pull request template

### 4. Review

All PRs require maintainer approval before merging. The `main` branch is protected — no direct pushes.

Maintainers review for:
- **Privacy accuracy** — are regulatory citations correct and current?
- **Prompt effectiveness** — does the skill produce useful, structured output when used with an AI agent?
- **Format compliance** — does the skill follow the template?

For skills citing specific legislation, a privacy professional review is required before merge.

### 5. Merge & Release

Once approved, the maintainer merges the PR and updates [CHANGELOG.md](CHANGELOG.md).

---

## Commit Conventions

Use [Conventional Commits](https://www.conventionalcommits.org/) with the skill name as scope:

```
feat(data-mapping): initial release v1.0.0
fix(pbd-code-review): correct GDPR Art. 25 citation
docs(shared): add PIPL to jurisdiction profiles
chore: update PR template checklist
```

**Types:**
- `feat` — new skill, new section, new supporting file
- `fix` — correct inaccurate guidance, fix broken references
- `docs` — update shared resources, README, CONTRIBUTING
- `chore` — repo maintenance, templates, CI

**Scope:** skill name (`pbd-code-review`, `data-mapping`) or `shared` for cross-skill resources. Omit scope for repo-level changes.

### Change Tracking

Changes are tracked at two levels:
- **Repo-level:** [CHANGELOG.md](CHANGELOG.md) — updated by the maintainer on merge. Documents new skills, shared resource updates, and cross-cutting changes.
- **Skill-level:** `## Changelog` section in each SKILL.md — updated by the contributor in the PR. Documents version bumps with date and description.

---

## Skill Authoring Guidelines

### Format Requirements

Every skill must follow [SKILL-TEMPLATE.md](SKILL-TEMPLATE.md). Key rules:

- **YAML frontmatter** with all required fields (name, description, jurisdiction, personas, version)
- **All sections present**: When to Use, What This Skill Cannot Do, Prerequisites, Process, Output Format, Jurisdiction Notes, References, Changelog
- **SKILL.md word budget: under 2,000 words.** Move detailed checklists, tables, and reference material to supporting files in the skill's subdirectory.

### Writing Style

- **Imperative tone.** "Identify all personal data fields" — not "You should consider identifying personal data fields." Agents respond better to direct instructions.
- **No narrative.** Skills are reference guides, not blog posts.
- **Searchable terms early.** Put the most distinctive keywords in the first 50 words of the `description` field — this is what agent skill-discovery indexes on.
- **Worked examples in `/examples/`, not inline.** Keep SKILL.md concise. Reference examples the agent can load if needed.

### Confidence Levels

Every skill that produces assessments must require the output to include confidence levels:

| Level | Meaning | Action |
|-------|---------|--------|
| **HIGH** | Clear regulatory guidance exists or code pattern is unambiguous | Finding can be acted on directly |
| **MEDIUM** | Reasonable interpretation, some judgment applied | Review recommended before acting |
| **LOW** | Ambiguous situation, multiple valid interpretations | Consult a privacy professional |

### Path Convention

Reference shared materials using repo-root-relative paths:

```
See `shared/glossary.md` for term definitions.
See `shared/jurisdiction-profiles.md` for GDPR Art. 30 details.
```

### Regulatory Citations

Every regulatory reference must include:
- Regulation name (GDPR, CCPA, etc.)
- Specific article or section number
- Date last verified against the source text

Format: `GDPR Art. 30 (verified against EUR-Lex, 2026-03-15)`

### Supporting Files

Organise supporting files in the skill's subdirectory:

```
skills/[skill-name]/
├── SKILL.md              # Primary skill file (under 2,000 words)
├── checklists/           # Reference checklists the skill uses
├── templates/            # Output templates
└── examples/             # Worked examples (input + expected output)
```

---

## Pull Request Checklist

Every PR must satisfy this checklist (also in the PR template):

- [ ] SKILL.md follows [SKILL-TEMPLATE.md](SKILL-TEMPLATE.md) format
- [ ] `description` field is optimised for agent discovery (keywords in first 50 words)
- [ ] "What This Skill Cannot Do" section is honest and specific
- [ ] Test scenarios included in `examples/`
- [ ] Baseline test completed (agent without skill — documented in PR)
- [ ] Skill test completed (agent with skill — documented in PR)
- [ ] Adversarial test completed (attempted to trick skill into bad output — documented in PR)
- [ ] Regulatory sources cited with specific articles/sections and verification dates
- [ ] Jurisdiction notes included (or skill is explicitly principle-based)
- [ ] SKILL.md is under 2,000 words (detailed content in supporting files)
- [ ] README.md skill index table updated
- [ ] No real personal data in examples (use synthetic or anonymised data only)

---

## Governance

### Maintainer

Lauren Kaufman ([@lolokauf](https://github.com/lolokauf)) is the sole maintainer. Co-maintainers will be added once the library reaches 5+ skills and demonstrates sustained community interest.

### Regulatory Accuracy Policy

Skills that reference specific legislation must cite the source with article/section numbers and a verification date. Claims of compliance with a regulation must be verifiable against the regulation text. The library does not provide legal advice, and every skill must state this clearly.

### Versioning

Skills are individually versioned using [semver](https://semver.org/):
- **Major** — breaking changes to output format (downstream skills may need updates)
- **Minor** — new features, additional jurisdiction support
- **Patch** — fixes, clarifications, citation updates

The library has no global version. A regulatory change affecting one skill does not force a release of the entire library.

### Deprecation

If a skill becomes outdated due to regulatory changes and no one updates it, it receives a prominent deprecation notice at the top of its SKILL.md rather than being silently removed. Users should know when they are using stale guidance.

---

## Questions?

Open an issue or reach out at support@healthy-tension.com.
