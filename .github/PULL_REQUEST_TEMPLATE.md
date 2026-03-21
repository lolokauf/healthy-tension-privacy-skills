## Summary

<!-- Briefly describe what this PR does. -->

## Skills Affected

<!-- List the skills this PR adds, modifies, or removes. -->

-

## Checklist

<!-- Complete all items before requesting review. -->

### Format & Content

- [ ] SKILL.md follows [SKILL-TEMPLATE.md](SKILL-TEMPLATE.md) format
- [ ] SKILL.md is under 2,000 words (detailed content in supporting files)
- [ ] `description` field is optimised for agent discovery (keywords in first 50 words)
- [ ] "What This Skill Cannot Do" section is honest and specific
- [ ] Confidence levels (HIGH/MEDIUM/LOW) included in output format
- [ ] No real personal data in examples (synthetic or anonymised only)

### Evaluation (Optional)

<!-- Running the eval suite before submitting gives you early feedback.
The maintainer runs the authoritative evaluation during review. -->

- [ ] *(Optional)* Eval suite run completed (`./eval/run-eval.sh --skill <name>`)
- [ ] *(Optional)* Adversarial resistance tests completed (`./eval/run-adversarial.sh --skill <name>`)

### Regulatory

- [ ] Regulatory sources cited with specific articles/sections and verification dates
- [ ] Jurisdiction notes included (or skill is explicitly principle-based)
- [ ] Regulatory review needed? (yes/no — required for skills citing specific legislation)

### Repository

- [ ] README.md skill index table updated
- [ ] Supporting files organised in skill subdirectory (checklists/, templates/, examples/)

## Eval Results (Optional)

<!-- If you ran the eval suite, paste results below.
The maintainer runs the full suite (public + private holdout + adversarial) during review. -->

### Accuracy & Quality Scores

<!-- Paste the summary table from eval/results/<timestamp>/summary.md -->

```
| Skill | Target | GT | D1 | D2 | D3 | D4 | D5 | Accuracy | Quality | Verdict |
|-------|--------|----|----|----|----|----|----|----------|---------|---------|
|       |        |    |    |    |    |    |    |          |         |         |
```

### Adversarial Resistance

<!-- Paste the results table from eval/results/adversarial-<timestamp>/summary.md -->

```
| Case | Skill | Target | Resistance | Quality |
|------|-------|--------|------------|---------|
|      |       |        |            |         |
```

### Notes

<!-- Flag any divergences between the auditor ground truth and your skill's output
that you think are worth discussing. Also note any findings you disagree with. -->
