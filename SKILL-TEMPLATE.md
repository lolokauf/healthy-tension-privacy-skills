---
# SKILL METADATA
# name: kebab-case identifier matching the directory name (e.g., "data-mapping")
name: [skill-name]

# description: 1-2 sentences optimised for agent skill discovery.
# Put the most distinctive keywords in the first 50 words.
# Include trigger phrases (what users ask for) and when NOT to use.
description: "[What it does. What it produces. When to use it. When not to use it.]"

# jurisdiction: list of regulatory frameworks referenced, or "principle-based"
# Examples: [GDPR Art. 25, CCPA §1798.100], [principle-based], [GDPR Art. 30, CCPA §1798.100(b)]
jurisdiction: [principle-based]

# personas: which user types this skill serves
# Options: engineer, privacy-pm, dpo, founder
personas: [engineer, privacy-pm]

# version: semver — bump major for breaking output format changes,
# minor for new features, patch for fixes
version: 1.0.0
---

# [Skill Name]

## When to Use This Skill

<!-- List explicit trigger conditions: what user requests, code patterns, or project
states should activate this skill. Be specific — vague triggers cause false activations. -->

- [Trigger condition 1]
- [Trigger condition 2]
- [Trigger condition 3]

## What This Skill Cannot Do

<!-- Honest limitations. This section carries real consequences — if users over-rely on
the skill, what could go wrong? Include:
- That this is NOT legal advice
- Known blind spots (runtime-only flows, infrastructure, third-party behaviour)
- Scenarios where a human privacy professional must be consulted
- What adjacent skills cover that this one doesn't -->

- This skill does not provide legal advice. Output is a technical assessment requiring human review.
- [Limitation 1]
- [Limitation 2]
- [Limitation 3]

## Prerequisites

<!-- Other skills, context, or files needed before running this skill.
If this skill depends on another skill's output, say so explicitly.
If no prerequisites, state "None — this skill can run independently." -->

- [Prerequisite 1, e.g., "Run data-mapping first if you haven't documented your data flows."]

## Process

<!-- Step-by-step methodology. Use imperative tone ("Identify..." not "You should consider...").
Be specific about what to examine and what to produce at each step.
Reference supporting files in checklists/ or templates/ where relevant. -->

### Step 1: [Name]

[Instructions — what to examine, what to look for, what to produce.]

### Step 2: [Name]

[Instructions]

### Step 3: [Name]

[Instructions]

<!-- Add as many steps as needed. Keep each step focused on one activity. -->

## Output Format

<!-- Exact structure of what the skill produces. Include table headers, field definitions,
and example values. This is the contract — downstream skills and users depend on
this format being consistent.

Every assessment must include confidence levels:
- **HIGH**: Clear regulatory guidance or unambiguous code pattern
- **MEDIUM**: Reasonable interpretation, some judgment applied
- **LOW**: Ambiguous situation, consult a privacy professional

Mark each finding with a confidence level so users know where to focus human review. -->

### [Primary Output Name]

```
| Column 1 | Column 2 | Column 3 | Confidence |
|----------|----------|----------|------------|
| [example] | [example] | [example] | HIGH |
```

### [Secondary Output Name] (if applicable)

[Structure definition]

## Jurisdiction Notes

<!-- How to adapt guidance for different regulatory regimes.
Default: principle-based behaviour (no jurisdiction specified).
Then: jurisdiction-specific overrides or additions.
Reference shared/jurisdiction-profiles.md for full regulatory context. -->

**Default (principle-based):** [How the skill behaves when no jurisdiction is specified.]

**GDPR:** [Additional requirements or modified steps.]

**CCPA/CPRA:** [Additional requirements or modified steps.]

See `shared/jurisdiction-profiles.md` for detailed regulatory context.

## References

<!-- Authoritative sources. Include specific article/section numbers and verification dates.
Format: Source (date verified) — brief description of relevance. -->

- [Source 1] (verified YYYY-MM-DD) — [relevance]
- [Source 2] (verified YYYY-MM-DD) — [relevance]

## Changelog

<!-- Version history. Include date, version, and what changed.
Format: **vX.Y.Z** (YYYY-MM-DD) — Description of changes. -->

- **v1.0.0** (YYYY-MM-DD) — Initial release.
