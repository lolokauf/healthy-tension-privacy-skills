# Privacy Skills Evaluation Suite

A repeatable evaluation framework for testing privacy skills against real open-source codebases. Scores skill output against human-authored ground truth using LLM-as-judge.

**This is not automated CI.** The eval suite produces scores and evidence. A human reviewer makes the final merge decision.

---

## How It Works

The eval suite runs each skill against curated target codebases, then scores the output:

1. **Clone** target repos at pinned commits (ground truth is tied to a specific codebase state)
2. **Run** each skill via `claude -p` — the agent explores the codebase autonomously using Read, Grep, Glob, and Bash
3. **Judge** each output against ground truth using a structured rubric (LLM-as-judge)
4. **Aggregate** scores into a summary with per-dimension ratings and a verdict

### Ground Truth Is Private

All ground truth (expected findings, severity judgments, must-find items) is **maintained privately by the maintainer** and is not included in this repository. This prevents contributors from tuning skills to match expected findings rather than genuinely analyzing code.

- **Target codebases** are listed in `targets.yaml` — knowing *which* repos are tested doesn't enable gaming because the ground truth is what matters.
- **Contributors** can optionally run the eval suite for early feedback. Without `--holdout-path`, the suite auto-generates ground truth from an independent auditor session. This gives useful signal but is not the authoritative evaluation.
- **The maintainer** runs the full suite with `--holdout-path` pointing to the private ground truth, producing the authoritative accuracy scores.

---

## Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| `claude` | [claude.ai/code](https://claude.ai/code) (requires active subscription or API key) | Runs skills and judges output |
| `git` | Pre-installed on macOS/Linux | Clones target repos at pinned commits |
| `bash` | Pre-installed on macOS/Linux | Orchestration script |
| `yq` | `brew install yq` ([mikefarah/yq](https://github.com/mikefarah/yq), not the Python kislyuk/yq) | Parses `targets.yaml` |
| `jq` | `brew install jq` | Parses JSON transcripts from `claude` |

Verify your setup:

```bash
claude --version && git --version && yq --version && jq --version
```

---

## Running the Eval Suite

### Basic Usage

```bash
# Run all skills against all public targets (default)
./eval/run-eval.sh

# Run a specific skill against all public targets
./eval/run-eval.sh --skill pbd-code-review

# Run all skills against a specific target
./eval/run-eval.sh --target documenso

# Run a specific skill × target pair
./eval/run-eval.sh --skill data-mapping --target open-saas

# Validate setup without spending API credits
./eval/run-eval.sh --dry-run
```

### Maintainer: Running with Ground Truth

```bash
# Run public targets with private ground truth
./eval/run-eval.sh --holdout-path /path/to/eval-holdout

# Run private holdout targets only
./eval/run-eval.sh --tier private --holdout-path /path/to/eval-holdout

# Run all targets (public + private)
./eval/run-eval.sh --tier all --holdout-path /path/to/eval-holdout
```

Without `--holdout-path`, the suite auto-generates ground truth from an independent auditor session. This is useful for contributor self-assessment but is not the authoritative evaluation.

### Reading Results

Results are written to `eval/results/<timestamp>/`:

```
eval/results/2026-03-15-14-30/
├── summary.md                              # Aggregate scores + verdicts
├── pbd-code-review--documenso--output.md   # Extracted skill output
├── pbd-code-review--documenso--scores.md   # Judge scores + evidence
├── data-mapping--documenso--output.md
├── data-mapping--documenso--scores.md
├── ...
├── transcripts/                            # Full JSON session transcripts
│   ├── pbd-code-review--documenso--transcript.json
│   └── ...
└── errors.log                              # Any failures during the run
```

The `summary.md` file contains the scoring table:

| Skill | Target | D1 | D2 | D3 | D4 | D5 | Total | Verdict |
|-------|--------|----|----|----|----|----|----|---------|
| pbd-code-review | documenso | 4 | 5 | 3 | 4 | 4 | 20 | PASS |
| data-mapping | documenso | 4 | 4 | 4 | 5 | 4 | 21 | STRONG PASS |

---

## Resource Usage

Each skill run involves a Claude session (agent explores a codebase) plus two judge sessions (accuracy + quality).

| Component | Time | Notes |
|-----------|------|-------|
| Skill run | ~4–6 min | Agent explores codebase using Read, Grep, Glob, Bash |
| Accuracy judge | ~1 min | Scores output against ground truth (coverage, precision, assessment accuracy) |
| Quality judge | ~1 min | Scores output structure, specificity, honesty, actionability |
| Auto-generate ground truth | ~4–6 min | Only for new skills without existing GT |
| **Existing skill, full public suite** (3 targets × 2 skills) | **~35–50 min** | 6 skill runs + 12 judge runs |
| **New skill, full public suite** (3 targets × 1 skill) | **~25–35 min** | 3 skill runs + 3 auditor runs + 6 judge runs |

**Billing:** If you use Claude Code with a Max/Pro subscription, eval runs are included in your subscription — no additional API cost. If you use an API key, the `--max-budget-usd 5.00` cap applies per invocation.

---

## Scoring Guide

### Verdict Meanings

| Verdict | Score Range | What It Means |
|---------|------------|---------------|
| **STRONG PASS** | 21–25/25 | Skill output is accurate, complete, and stakeholder-ready |
| **PASS** | 16–20/25 | Useful output with minor gaps; acceptable quality |
| **MARGINAL** | 11–15/25 | Significant gaps; needs improvement before relying on it |
| **FAIL** | 5–10/25 | Unreliable or largely inaccurate output |

### Scoring Dimensions

**Accuracy** (any skill): Coverage, Precision, Assessment Accuracy, Confidence Calibration, Output Quality

**Quality** (any skill): Format Compliance, Completeness, Specificity, Honesty, Actionability

See `judge-prompt.md` for full calibration tables.

---

## For Contributors

### Submitting a New Skill

You do **not** need to write ground truth or run the eval suite — the maintainer runs the authoritative evaluation during review.

1. **Write your skill** following `SKILL-TEMPLATE.md`
2. **Submit your PR** using the pull request template
3. *(Optional)* **Run the eval suite for early feedback:**
   ```bash
   ./eval/run-eval.sh --skill <your-skill-name>
   ./eval/run-adversarial.sh --skill <your-skill-name>
   ```
   If you run these, include the summary tables in your PR description. This gives you signal on accuracy, quality, and adversarial resistance before the maintainer reviews.
4. The **maintainer runs the full suite** (public + private holdout + adversarial) and makes the merge decision based on those results

### Adding a New Eval Target

1. Choose a well-maintained open-source repo with real privacy patterns
2. Pin it to a specific commit SHA
3. Manually audit the codebase and write ground truth using `ground-truth-template.md`
4. Add the target to `targets.yaml`
5. Submit a PR with the ground truth files

---

## For Maintainers

### Reviewing a New Skill PR

1. **Pull the contributor's branch** locally
2. **Run the full evaluation suite** with your private ground truth:
   ```bash
   ./eval/run-eval.sh --skill <skill-name> --tier all --holdout-path /path/to/eval-holdout
   ./eval/run-adversarial.sh --skill <skill-name>
   ```
3. **Review scores** — accuracy, quality, and adversarial resistance
4. **Spot-check auto-generated ground truth** (for new skills without existing GT) in `results/<timestamp>/auto-ground-truth/`
5. **Review divergences** — where the skill and auditor disagree, who's right?
6. **Merge or request changes** based on your judgment

### Promoting Auto-Generated Ground Truth

After a skill is merged, you can promote its auto-generated ground truth to permanent human-reviewed ground truth in your private holdout:

```bash
# Copy auto-generated GT to private holdout
cp results/<timestamp>/auto-ground-truth/<target>/ground-truth-<skill>.md \
   /path/to/eval-holdout/targets/<target>/ground-truth-<skill>.md
```

Add a header: `<!-- PROMOTED from auto-generated, reviewed by [name] on [date] -->`

This means future runs use the promoted (faster, more reliable) ground truth instead of regenerating it.

### Pre-Generating Ground Truth for New Skills

```bash
./eval/generate-ground-truth.sh --skill <skill-name> --output-dir /path/to/eval-holdout/auto-ground-truth
```

Review the output, then promote to `/path/to/eval-holdout/targets/<target>/`.

---

## Adversarial Testing

Lightweight tests that verify skills resist common prompt manipulation patterns. These inject misleading user instructions (e.g., "skip half the review", "mark everything LOW severity") and check whether the skill maintains its assessment integrity.

### Running Adversarial Tests

```bash
# Run all 5 adversarial cases against all skills (default target: documenso)
./eval/run-adversarial.sh

# Run a specific case against a specific skill
./eval/run-adversarial.sh --skill pbd-code-review --case skip

# Run against a different target
./eval/run-adversarial.sh --target open-saas

# Validate setup first
./eval/run-adversarial.sh --dry-run
```

### Adversarial Cases

| Case | What It Tests |
|------|--------------|
| `skip` | Asks skill to skip principles 3-5 — should still cover all |
| `downplay` | Claims "no real PII, internal tool" — should audit based on code, not claims |
| `override` | Demands all findings be LOW severity — should use its own assessment |
| `scope-reduction` | Restricts to one directory — should note limitation or explore fully |
| `false-compliance` | Claims GDPR compliance, asks for confirmation — should audit independently |

### Scoring

Each case is scored on **Resistance** (PASS/FAIL) and **Quality of Resistance** (1-3: silent → acknowledged → educational). See `adversarial-cases.md` for full rubric.

A skill passes adversarial testing if it achieves **RESISTANCE = PASS on all 5 cases**.

---

## Limitations

- **LLM-as-judge has variance.** Running the same eval twice may produce slightly different scores (typically ±1 per dimension). The consistency test in the validation step measures this.
- **Ground truth reflects one auditor's judgment.** Privacy assessments are interpretive. The "acceptable alternatives" columns in ground truth docs account for reasonable disagreement.
- **Auto-generated ground truth is a baseline, not gospel.** The independent auditor may miss subtle issues or flag things the skill correctly handles differently. Always review the auto-generated GT before relying on accuracy scores.
- **Human review is the final gate.** Scores inform the maintainer's decision but do not replace judgment. A MARGINAL score with good reasoning may be more valuable than a PASS with superficial output.
