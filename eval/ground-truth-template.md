# Ground Truth Template

Use this template to author ground truth documents for eval targets. Each target needs one ground truth per skill type: `ground-truth-pbd.md` for PbD Code Review and `ground-truth-inventory.md` for Data Mapping & Inventory.

## Versioning

Ground truth is only valid for its pinned commit. If the target repo's pinned commit is updated in `targets.yaml`, the ground truth must be re-audited and `date_audited` updated. Do not change the pinned commit unless you are deliberately re-auditing.

---

## Ground Truth: PbD Code Review

Copy this section into `eval/targets/<name>/ground-truth-pbd.md` and fill in.

```markdown
# PbD Code Review — Ground Truth: [Target Name]

## Metadata
- **Target:** [target name from targets.yaml]
- **Repo:** [URL]
- **Pinned commit:** [SHA]
- **Stack:** [primary technologies]
- **Date audited:** [YYYY-MM-DD]
- **Audited by:** [name]

## Expected Findings

### Must-Find Items

These are critical findings any competent review should identify. Missing a must-find item should heavily penalise the Coverage score.

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning | Acceptable Alternatives |
|---|---------|-----------|-------------------|---------------------|-----------|------------------------|
| 1 | [description] | [1-7] | [CRITICAL/HIGH/MEDIUM/LOW] | [HIGH/MEDIUM/LOW] | [why this is expected] | [alternative severity or interpretation, if any] |
| 2 | ... | ... | ... | ... | ... | ... |

### Nice-to-Find Items

Deeper findings that demonstrate thoroughness. Not required for a passing score.

| # | Finding | Principle | Expected Severity | Expected Confidence | Reasoning |
|---|---------|-----------|-------------------|---------------------|-----------|
| 1 | [description] | [1-7] | [CRITICAL/HIGH/MEDIUM/LOW] | [HIGH/MEDIUM/LOW] | [why this would be a strong finding] |

### Expected Severity Distribution

Approximate expected counts. The skill's distribution should be in the same ballpark.

- **CRITICAL:** [N]
- **HIGH:** [N]
- **MEDIUM:** [N]
- **LOW:** [N]

### Expected Artifacts

The PbD Code Review skill should produce these 8 artifacts. Note key expectations for each.

| Artifact | Expected? | Key Content Expectations |
|----------|-----------|------------------------|
| PII Touchpoint Manifest | Yes | Should list [N] PII fields with sources |
| Default Configuration Audit | Yes | Should flag [specific defaults] |
| PII Data Flow Heatmap | Yes | Should show [key flow patterns] |
| Privacy-Preserving Alternatives Table | Yes | Should suggest alternatives for [specific issues] |
| Data Lifecycle Table | Yes | Should cover [N] fields; flag missing retention |
| Transparency Audit | Yes | Should identify [N] undocumented processors |
| User Privacy Controls Checklist | Yes | Should check for [specific controls] |
| Delete-My-Account Trace | Yes | Should trace deletion across [specific stores] |

### Known Ambiguities

Findings where reasonable reviewers might disagree. The skill should not be penalised for either interpretation.

| Finding | Why It's Ambiguous | Acceptable Interpretations |
|---------|-------------------|---------------------------|
| [description] | [explanation] | [interpretation A] or [interpretation B] |

### Red Herrings

Things that look like privacy issues but are not. If the skill flags these, it's a false positive.

| Item | Why It Looks Like an Issue | Why It's Not |
|------|--------------------------|-------------|
| [description] | [surface appearance] | [actual explanation] |
```

---

## Ground Truth: Data Mapping & Inventory

Copy this section into `eval/targets/<name>/ground-truth-inventory.md` and fill in.

```markdown
# Data Mapping — Ground Truth: [Target Name]

## Metadata
- **Target:** [target name from targets.yaml]
- **Repo:** [URL]
- **Pinned commit:** [SHA]
- **Stack:** [primary technologies]
- **Date audited:** [YYYY-MM-DD]
- **Audited by:** [name]

## Expected PII Fields

### Must-Find Fields

Critical PII fields any competent inventory should discover.

| # | Data Element | Location | PII Category | Source | Storage | Expected Confidence | Acceptable Alternative Categories |
|---|-------------|----------|-------------|--------|---------|---------------------|----------------------------------|
| 1 | [field name] | [table.column or storage key] | [category] | [collection point] | [persistence location] | [HIGH/MEDIUM/LOW] | [alternative category, if any] |
| 2 | ... | ... | ... | ... | ... | ... | ... |

### Nice-to-Find Fields

Fields that demonstrate thorough exploration.

| # | Data Element | Location | PII Category | Source | Expected Confidence |
|---|-------------|----------|-------------|--------|---------------------|
| 1 | [field name] | [location] | [category] | [source] | [HIGH/MEDIUM/LOW] |

## Expected Processors

| Processor | Data Received | Purpose | Expected Confidence |
|-----------|--------------|---------|---------------------|
| [service name] | [specific data elements] | [why shared] | [HIGH/MEDIUM/LOW] |

## Expected Data Flows

Key flow paths the data flow diagram should capture.

1. [User input] → [API] → [Database] → [description of flow]
2. [User input] → [Third-party SDK] → [external service]
3. ...

## Expected Completeness

- **Approximate %:** [N%]
- **Reasoning:** [why this percentage — what's hard to discover vs. obvious]

## Known Ambiguities

Fields where PII category assignment is debatable.

| Data Element | Why It's Ambiguous | Acceptable Categories |
|-------------|-------------------|----------------------|
| [field] | [explanation] | [category A] or [category B] |

## Red Herrings

Data elements that look like PII but are not personal data.

| Item | Why It Looks Like PII | Why It's Not |
|------|----------------------|-------------|
| [field/pattern] | [surface appearance] | [actual explanation] |
```

---

## Authoring Guidance

- **Be specific.** Use exact field names, table names, and file paths from the pinned commit.
- **Include reasoning.** The judge uses your reasoning to calibrate scores — "email field exists" is less useful than "email in users.email (Prisma schema line 42) used for account auth + transactional emails."
- **Mark acceptable alternatives.** Privacy assessments are interpretive. If a finding could reasonably be HIGH or MEDIUM, note both. If a field could be "contact" or "identifier," list both.
- **Distinguish must-find from nice-to-find.** Must-find items are things any reasonable privacy review should catch (e.g., plaintext passwords, PII in logs, missing deletion). Nice-to-find items require deeper analysis (e.g., JWT expiry length, session fixation risk, indirect PII inference).
- **Document red herrings carefully.** These test false positive detection. Common red herrings: demo/seed data, hashed values that look like plaintext, privacy-preserving designs that look like violations at first glance.
- **Use the ground truth for one skill at a time.** Don't mix PbD findings with inventory fields in the same document.
