# Ground Truth Template

Use this template to author ground truth for any skill against any eval target. Each target needs one ground truth file per skill: `ground-truth-<skill-name>.md`.

**For most new skills, ground truth is auto-generated** by the eval suite's independent auditor (`generate-ground-truth.sh`). This template is for manual authoring or for reviewing/refining auto-generated output.

## Versioning

Ground truth is only valid for its pinned commit. If the target repo's pinned commit is updated in `targets.yaml`, the ground truth must be re-audited and `date_audited` updated. Do not change the pinned commit unless you are deliberately re-auditing.

---

## Template

Copy this into `eval/targets/<target>/ground-truth-<skill-name>.md` and fill in. Adapt the table columns to match the skill's focus area — the structure (must-find, nice-to-find, ambiguities, red herrings) is universal, but the finding categories depend on what the skill does.

```markdown
# [Skill Name] — Ground Truth: [Target Name]

## Metadata
- **Target:** [target name from targets.yaml]
- **Repo:** [URL]
- **Pinned commit:** [SHA]
- **Stack:** [primary technologies]
- **Skill:** [skill name and version]
- **Date audited:** [YYYY-MM-DD]
- **Audited by:** [name, or "Auto-generated auditor" if auto-generated]

## Must-Find Items

Critical findings any competent assessment should identify within this skill's focus area. Missing a must-find item heavily penalises the Coverage/Recall score.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|----------|-------------------|---------------------|-----------|------------------------|
| 1 | [specific finding with file path and field/line reference] | [relevant category for this skill] | [CRITICAL/HIGH/MEDIUM/LOW] | [HIGH/MEDIUM/LOW] | [why this matters within the skill's focus] | [alternative severity or interpretation, if any] |
| 2 | ... | ... | ... | ... | ... | ... |

Aim for **8-15 must-find items**. Too few = shallow audit. Too many = noise.

## Nice-to-Find Items

Deeper findings that demonstrate thoroughness. Not required for a passing score.

| # | Finding | Category | Expected Severity | Expected Confidence | Reasoning |
|---|---------|----------|-------------------|---------------------|-----------|
| 1 | [finding] | [category] | [severity] | [confidence] | [why this would be a strong finding] |

Aim for **5-10 nice-to-find items**.

## Expected Severity Distribution

Approximate expected counts. The skill's output should be in the same ballpark.

- **CRITICAL:** [N]
- **HIGH:** [N]
- **MEDIUM:** [N]
- **LOW:** [N]

## Expected Outputs

List the key outputs the skill's Output Format section specifies. Note what content you'd expect each to contain for this target.

| Output | Expected? | Key Content Expectations |
|--------|-----------|------------------------|
| [output name from skill's Output Format] | Yes/No | [what this output should contain for this target] |
| ... | ... | ... |

## Known Ambiguities

Findings where reasonable reviewers might disagree. The skill should not be penalised for either interpretation.

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| [finding] | [explanation] | [interpretation A] or [interpretation B] |

## Red Herrings

Things that look like issues within this skill's focus area but are not. If the skill flags these, it's a false positive.

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| [item] | [surface appearance] | [actual explanation] |
```

---

## Authoring Guidance

- **Be specific.** Every finding should reference exact file paths, field names, or code patterns from the pinned commit.
- **Include reasoning.** The judge uses your reasoning to calibrate scores — "email field exists" is less useful than "email in users.email (Prisma schema line 42) used for account auth + transactional emails."
- **Mark acceptable alternatives.** Privacy assessments are interpretive. If a finding could reasonably be HIGH or MEDIUM, note both in the Acceptable Alternatives column.
- **Distinguish must-find from nice-to-find.** Must-find = any competent assessment should catch this (e.g., plaintext credentials, missing deletion, PII in logs). Nice-to-find = requires deeper analysis (e.g., token expiry length, indirect inference risk).
- **Document red herrings carefully.** These test false positive detection. Common red herrings: demo/seed data, hashed values that look like plaintext, privacy-preserving designs that look like violations at first glance.
- **Adapt columns to the skill.** The "Category" column should use categories relevant to the skill's focus (e.g., a data mapping skill uses PII categories like "contact", "authentication"; a consent flow skill might use "consent mechanism", "opt-out pathway"). The structure is universal; the content is skill-specific.
- **One ground truth per skill per target.** Don't combine findings for different skills in one file.