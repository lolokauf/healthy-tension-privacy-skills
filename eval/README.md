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

### Two-Tier Evaluation

The suite uses a **public/private split**, a standard practice in projects with quality gates (mirrors the ML validation/test set pattern):

- **Public tier** (in this repo, `eval/targets/`) — 3 target codebases with visible ground truth. Contributors run these locally to self-assess before submitting PRs.
- **Private holdout tier** (maintained separately by the repo maintainer) — additional target codebases with ground truth that contributors cannot see. The maintainer runs these during PR review.

**Why?** If all ground truth were public, contributors could overfit skills to pass specific test cases without genuinely improving quality. The public tier gives enough signal for self-assessment; the private tier ensures honest evaluation. The target repo URLs are visible in `targets.yaml` — knowing *which* repos are tested doesn't enable gaming because the ground truth (expected findings, severity judgments, must-find items) is what matters.

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

### Maintainer: Running the Private Holdout

```bash
# Run private tier only
./eval/run-eval.sh --tier private --holdout-path /path/to/eval-holdout

# Run both public and private tiers
./eval/run-eval.sh --tier all --holdout-path /path/to/eval-holdout
```

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

You do **not** need to write ground truth. The eval suite auto-generates it.

1. **Write your skill** following `SKILL-TEMPLATE.md`
2. **Run the eval suite:**
   ```bash
   ./eval/run-eval.sh --skill <your-skill-name>
   ```
   This automatically: generates ground truth via an independent auditor, runs your skill against 3 target codebases, and scores both accuracy and quality.
3. **Include eval results** in your PR description (copy the summary table from `results/<timestamp>/summary.md`)
4. The **maintainer will review** your scores, spot-check the auto-generated ground truth, and run the private holdout suite

### Adding a New Eval Target

1. Choose a well-maintained open-source repo with real privacy patterns
2. Pin it to a specific commit SHA
3. Manually audit the codebase and write ground truth using `ground-truth-template.md`
4. Add the target to `targets.yaml`
5. Submit a PR with the ground truth files

---

## For Maintainers

### Reviewing a New Skill PR

1. **Check the summary table** — look at both Accuracy and Quality scores
2. **Spot-check auto-generated ground truth** in `results/<timestamp>/auto-ground-truth/` — did the auditor find the right things?
3. **Review divergences** — where the skill and auditor disagree, who's right?
4. **Run the holdout suite:**
   ```bash
   ./eval/run-eval.sh --skill <skill-name> --tier all --holdout-path /path/to/eval-holdout
   ```
5. **Merge or request changes** based on your judgment

### Promoting Auto-Generated Ground Truth

After a skill is merged, you can promote its auto-generated ground truth to permanent human-reviewed ground truth:

```bash
# Copy auto-generated GT to permanent location
cp results/<timestamp>/auto-ground-truth/<target>/ground-truth-<skill>.md \
   eval/targets/<target>/ground-truth-<skill>.md
```

Add a header: `<!-- PROMOTED from auto-generated, reviewed by [name] on [date] -->`

This means future runs of the skill will use the promoted (faster, more reliable) ground truth instead of regenerating it.

### Pre-Generating Holdout Ground Truth

```bash
./eval/generate-ground-truth.sh --skill <skill-name> --tier private --holdout-path /path/to/eval-holdout
```

Review the output, then promote to `eval-holdout/targets/<target>/`.

---

## Limitations

- **LLM-as-judge has variance.** Running the same eval twice may produce slightly different scores (typically ±1 per dimension). The consistency test in the validation step measures this.
- **Ground truth reflects one auditor's judgment.** Privacy assessments are interpretive. The "acceptable alternatives" columns in ground truth docs account for reasonable disagreement.
- **Auto-generated ground truth is a baseline, not gospel.** The independent auditor may miss subtle issues or flag things the skill correctly handles differently. Always review the auto-generated GT before relying on accuracy scores.
- **Human review is the final gate.** Scores inform the maintainer's decision but do not replace judgment. A MARGINAL score with good reasoning may be more valuable than a PASS with superficial output.
