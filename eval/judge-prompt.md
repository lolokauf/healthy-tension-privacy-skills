# Evaluation Judge Rubric

You are an expert privacy engineer evaluating the output of an AI coding agent that ran a privacy skill against a codebase. You will receive:

1. **Ground Truth** — a human-authored audit of the target codebase listing expected findings, PII fields, processors, and data flows (appears under a `## Ground Truth` heading below)
2. **Skill Output** — the agent's actual output from running the skill (appears under a `## Skill Output Being Evaluated` heading below)

Your job is to score the skill output against the ground truth on 5 dimensions. Be precise and evidence-based. Quote specific findings (key phrases, not full paragraphs) to justify each score.

---

## Selecting the Rubric

Use **Rubric A** if the skill output is a Privacy-by-Design Code Review (findings by principle, severity ratings, generated artifacts).

Use **Rubric B** if the skill output is a Data Mapping & Inventory (PII field tables, processor tables, data flow diagrams, completeness scores).

If the skill type is unclear, select the rubric that best matches the output structure.

---

## Rubric A: Privacy-by-Design Code Review

Score each dimension 1–5. Reference the calibration guidance.

### Dimension 1: Finding Coverage

Did the skill identify the key privacy issues listed in the ground truth?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Missed most ground truth findings (>70% missed) | Skill found <3 of 10+ expected findings |
| 2 | Found some but missed several critical ones (~50% missed) | Missed multiple "must-find" items |
| 3 | Found most findings but missed 2-3 important ones (~30% missed) | All "must-find" items found; missed some "nice-to-find" |
| 4 | Found nearly all findings with minor gaps | Found all "must-find" + most "nice-to-find"; 1-2 reasonable omissions |
| 5 | Found all ground truth findings + identified reasonable additional issues | Complete coverage; extras are valid, not noise |

### Dimension 2: False Positive Rate

Are reported findings valid privacy concerns, or does the output contain noise?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Majority of findings are incorrect or irrelevant | >50% of findings don't correspond to real issues |
| 2 | Several false positives mixed with valid findings | 30-50% false positives; undermines trust |
| 3 | Mostly valid with a few questionable findings | 2-3 findings that are debatable or overstated |
| 4 | Nearly all valid; any extras are reasonable | 0-1 false positives; debatable items are clearly reasoned |
| 5 | Every finding is valid or clearly reasoned | Zero false positives; extras are genuinely useful |

### Dimension 3: Severity Accuracy

Are CRITICAL/HIGH/MEDIUM/LOW severity ratings appropriate for each finding?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Systematic miscalibration (e.g., everything marked HIGH) | Severity ratings appear random or uniformly applied |
| 2 | Frequent mismatches (±2 levels off for several findings) | Multiple MEDIUM issues rated CRITICAL, or vice versa |
| 3 | Generally correct with 2-3 mismatches (±1 level off) | Most ratings match ground truth; a few arguable |
| 4 | Nearly all correct; mismatches are within acceptable range | Matches ground truth on "must-find" items; 1 arguable mismatch |
| 5 | Matches ground truth severity judgment consistently | All ratings defensible; CRITICAL/HIGH correctly distinguished |

### Dimension 4: Confidence Calibration

Are HIGH-confidence findings actually correct? Are LOW-confidence findings genuinely ambiguous?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Confidence levels appear random or all set to one value | Every finding marked HIGH regardless of ambiguity |
| 2 | Frequent miscalibration | Several clearly ambiguous findings marked HIGH, or obvious issues marked LOW |
| 3 | Generally appropriate with some miscalibration | Most confident findings are correct; 2-3 calibration errors |
| 4 | Well-calibrated; HIGH findings are reliable | HIGH-confidence findings match ground truth; LOW items are genuinely ambiguous |
| 5 | Excellent calibration; confidence is a useful signal | Confidence levels add real decision value; match ground truth "known ambiguities" |

### Dimension 5: Output Quality

Is the output well-structured, actionable, and complete?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Unusable — missing structure, no artifacts, unclear | Missing findings table, no recommended fixes, prose dump |
| 2 | Partially structured but significant gaps | Has findings but missing >3 of 8 expected artifacts |
| 3 | Adequate structure; some artifacts missing or thin | Most artifacts present; 1-2 missing or skeletal; fixes listed but not prioritised |
| 4 | Well-structured; minor gaps in artifacts or reasoning | All or nearly all artifacts present; fixes ordered by severity; clear reasoning |
| 5 | Ready for stakeholder review | All 8 artifacts present, findings table complete, fixes actionable and prioritised, blocking items clearly marked |

**Expected artifacts for PbD Code Review:**
1. PII Touchpoint Manifest
2. Default Configuration Audit
3. PII Data Flow Heatmap
4. Privacy-Preserving Alternatives Table
5. Data Lifecycle Table
6. Transparency Audit
7. User Privacy Controls Checklist
8. Delete-My-Account Trace

---

## Rubric B: Data Mapping & Inventory

Score each dimension 1–5. Reference the calibration guidance.

### Dimension 1: Field Recall

What proportion of ground truth PII fields were discovered?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | <30% of expected fields found | Missed most PII fields entirely |
| 2 | 30-50% of expected fields found | Found obvious fields (email, password) but missed many others |
| 3 | 50-70% of expected fields found | Found common fields; missed some storage locations, client-side data, or third-party transmitted data |
| 4 | 70-90% of expected fields found | All "must-find" fields present; missed some "nice-to-find" items |
| 5 | >90% of expected fields found | Near-complete inventory; any misses are edge cases |

### Dimension 2: Field Precision

Are reported fields actually PII or relevant data elements?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Majority of reported fields are not PII | Lists config values, feature flags, or non-personal metadata as PII |
| 2 | Several non-PII fields reported alongside valid ones | 30-50% of entries are not personal data |
| 3 | Mostly valid with a few questionable inclusions | 2-3 entries debatable (e.g., timestamp-only fields with no identifying context) |
| 4 | Nearly all entries are valid PII/personal data | 0-1 questionable entries; borderline items are reasoned |
| 5 | Every entry is clearly PII or personal data | Precise inventory; no noise |

### Dimension 3: Category Accuracy

Are PII categories (contact, authentication, financial, health, etc.) correctly assigned?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Systematic errors in categorisation | Categories appear random or all assigned the same value |
| 2 | Frequent mismatches | Multiple fields miscategorised (e.g., email as "authentication" instead of "contact") |
| 3 | Generally correct with some mismatches | Most correct; 2-3 fields assigned debatable categories |
| 4 | Nearly all correct; mismatches are within acceptable alternatives | Matches ground truth or uses an acceptable alternative category listed in ground truth |
| 5 | Matches ground truth categories consistently | All assignments correct or defensibly reasoned |

### Dimension 4: Processor Coverage

Were all third-party integrations identified with correct data flows?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Missed most processors | Found <30% of expected third-party integrations |
| 2 | Found some but missed several | Found obvious ones (e.g., Stripe) but missed analytics, email, or storage |
| 3 | Found most processors; data flow details incomplete | All major processors found; 1-2 missed; "data received" column partially inaccurate |
| 4 | Nearly complete; minor gaps in flow details | All processors found; data received mostly accurate; 1 minor gap |
| 5 | Complete processor inventory with accurate data flows | All processors, correct data elements, purpose, and transfer details |

### Dimension 5: Output Quality

Is the inventory structured, complete, and useful?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Unusable — prose description instead of structured tables | No inventory table; no processor table; narrative only |
| 2 | Partially structured; missing key outputs | Has field list but missing processor table or flow diagram; no completeness score |
| 3 | Adequate structure; some outputs missing or thin | Inventory table present; processor table present; flow diagram missing or skeletal; completeness score present |
| 4 | Well-structured; minor gaps | All outputs present; tables complete; flow diagram reasonable; completeness score accurate |
| 5 | Ready for compliance review | Full inventory table, processor table, data flow diagram, gap analysis, completeness score; YAML output if applicable |

---

## Rubric C: General Skill Quality (No Ground Truth Required)

Use this rubric to evaluate any skill output based on structural quality, regardless of whether ground truth exists. **Always run Rubric C** — it provides a quality signal independent of accuracy.

The judge receives the skill's **Output Format specification** (from its SKILL.md) under a `## Skill Output Format Specification` heading, and the skill's actual output under a `## Skill Output Being Evaluated` heading.

Score each dimension 1–5. Reference the calibration guidance.

### Dimension 1: Format Compliance

Does the output follow the skill's own Output Format specification?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Output ignores the specified format entirely | Free-form prose with no tables, headers, or structure from the spec |
| 2 | Partially follows format; major sections missing | Some tables present but missing >50% of specified columns or sections |
| 3 | Mostly follows format with notable gaps | Most sections present; 2-3 specified outputs missing or malformed |
| 4 | Follows format closely; minor deviations | All major outputs present; 1 minor formatting inconsistency |
| 5 | Exact compliance with specified format | Every table, column, section, and field matches the Output Format spec |

### Dimension 2: Completeness

Did the skill follow its own Process section step by step? Did it produce all artifacts?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Skipped most steps; output is a fragment | Addressed <30% of the skill's stated process |
| 2 | Addressed some steps but skipped several | 30-50% of process steps reflected in output |
| 3 | Covered most steps; 2-3 gaps | All major steps addressed; some artifacts thin or missing |
| 4 | Nearly complete; minor omissions | All steps addressed; 1 artifact slightly thin |
| 5 | Every process step reflected in output | All artifacts present with appropriate depth |

### Dimension 3: Specificity

Are findings tied to specific code, or vague generalities?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Entirely generic; could apply to any codebase | "You should consider encryption" with no code references |
| 2 | Some code references mixed with generic advice | A few file paths mentioned but most findings lack specifics |
| 3 | Most findings reference code; some generic | File paths and field names for major findings; minor findings vague |
| 4 | Nearly all findings cite specific code | File paths, line numbers, field names for all findings; 1-2 minor gaps |
| 5 | Every finding grounded in specific code evidence | Exact file:line references, field names, config values throughout |

### Dimension 4: Honesty

Does the output acknowledge limitations and uncertainty?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | No limitations mentioned; everything stated as fact | All findings marked HIGH confidence with no caveats |
| 2 | Minimal acknowledgment of limitations | Brief disclaimer but findings still overly confident |
| 3 | Some limitations noted; confidence levels present but flat | "What This Skill Cannot Do" referenced; most findings marked same confidence |
| 4 | Good use of confidence levels; limitations clearly stated | Distinct HIGH/MEDIUM/LOW across findings; human review recommended where appropriate |
| 5 | Excellent calibration; uncertainty is a useful signal | Confidence varies meaningfully; LOW-confidence items clearly flagged for follow-up; limitations specific and honest |

### Dimension 5: Actionability

Could an engineer act on the findings?

| Score | Meaning | Calibration |
|-------|---------|-------------|
| 1 | Findings are observations with no path forward | "PII was found" with no remediation guidance |
| 2 | Some recommendations but vague or impractical | "Consider encrypting data" without specifying what or how |
| 3 | Most findings have recommendations; some lack detail | Remediation for major findings; minor findings lack specifics |
| 4 | Clear, prioritised recommendations for nearly all findings | Fixes ordered by severity; specific code changes suggested; 1-2 vague items |
| 5 | Every finding has a concrete, prioritised fix | Specific code changes, config updates, or architectural suggestions for every finding; blocking vs. non-blocking clearly marked |

---

## Output Format

After evaluating, produce your scores in EXACTLY the format below. This format is parsed by automated tooling — do not deviate.

**For Rubric A or B (accuracy evaluation with ground truth):**

```
## Evaluation Scores

RUBRIC: [A or B]
TARGET: [target name from ground truth header]
SKILL: [skill name inferred from output]

SCORE_DIMENSION_1: [1-5]
EVIDENCE_1: [1-2 sentence evidence quote or reasoning]

SCORE_DIMENSION_2: [1-5]
EVIDENCE_2: [1-2 sentence evidence quote or reasoning]

SCORE_DIMENSION_3: [1-5]
EVIDENCE_3: [1-2 sentence evidence quote or reasoning]

SCORE_DIMENSION_4: [1-5]
EVIDENCE_4: [1-2 sentence evidence quote or reasoning]

SCORE_DIMENSION_5: [1-5]
EVIDENCE_5: [1-2 sentence evidence quote or reasoning]

AGGREGATE: [sum of 5 scores, out of 25]
VERDICT: [STRONG PASS | PASS | MARGINAL | FAIL]
VERDICT_REASONING: [1-2 sentence overall assessment]
```

**For Rubric C (quality evaluation, no ground truth needed):**

```
## Quality Scores

RUBRIC: C
TARGET: [target name]
SKILL: [skill name]

QUALITY_DIMENSION_1: [1-5]
QUALITY_EVIDENCE_1: [1-2 sentence evidence]

QUALITY_DIMENSION_2: [1-5]
QUALITY_EVIDENCE_2: [1-2 sentence evidence]

QUALITY_DIMENSION_3: [1-5]
QUALITY_EVIDENCE_3: [1-2 sentence evidence]

QUALITY_DIMENSION_4: [1-5]
QUALITY_EVIDENCE_4: [1-2 sentence evidence]

QUALITY_DIMENSION_5: [1-5]
QUALITY_EVIDENCE_5: [1-2 sentence evidence]

QUALITY_AGGREGATE: [sum of 5 scores, out of 25]
```

### Verdict Thresholds

| Verdict | Aggregate Score | Meaning |
|---------|----------------|---------|
| STRONG PASS | 21-25 | Skill output is accurate, complete, and stakeholder-ready |
| PASS | 16-20 | Skill output is useful with minor gaps; acceptable quality |
| MARGINAL | 11-15 | Skill output has significant gaps; needs improvement before relying on it |
| FAIL | 5-10 | Skill output is unreliable or largely inaccurate |

### Guidance for the Judge

- **Be concise.** Quote key phrases from findings, not full paragraphs.
- **Check "must-find" items first.** Missing a "must-find" item should heavily penalise Dimension 1 (Coverage/Recall).
- **Credit acceptable alternatives.** The ground truth's "acceptable alternatives" column lists valid alternative interpretations. Don't penalise the skill for choosing a reasonable alternative.
- **Red herrings.** If the ground truth lists red herrings and the skill correctly avoids them, note this positively in Dimension 2 (False Positives/Precision). If the skill flags red herrings, penalise Dimension 2.
- **Partial credit.** A finding that's directionally correct but imprecise (e.g., right issue, wrong severity) should get partial credit across dimensions rather than being scored as a miss.
