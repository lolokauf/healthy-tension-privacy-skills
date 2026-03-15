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

### Testing

- [ ] Test scenarios included in `examples/`
- [ ] Baseline test completed (agent without skill)
- [ ] Skill test completed (agent with skill)
- [ ] Adversarial test completed (attempted to trick skill into bad output)

### Regulatory

- [ ] Regulatory sources cited with specific articles/sections and verification dates
- [ ] Jurisdiction notes included (or skill is explicitly principle-based)
- [ ] Regulatory review needed? (yes/no — required for skills citing specific legislation)

### Repository

- [ ] README.md skill index table updated
- [ ] Supporting files organised in skill subdirectory (checklists/, templates/, examples/)

## Test Results

### Baseline (without skill)

<!-- Brief summary of what the agent produced without the skill loaded. -->

### Skill Test (with skill)

<!-- Brief summary of what the agent produced with the skill loaded.
How does it compare to baseline? -->

### Adversarial Test

<!-- What did you try? Did the skill resist shortcutting or manipulation? -->
