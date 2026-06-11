# audit-script

Reusable Claude Code audit automation for GitHub repositories.

This repository packages:

- `.github/workflows/biweekly-audit.yml` - scheduled and manual architecture / tech debt audit workflow.
- `.claude/skills/improve-codebase-architecture` - architecture review skill used by the workflow.
- `.claude/skills/tech-debt-audit` - tech debt audit skill used by the workflow.
- `.claude/skills/resolve-audit` - operator-invoked follow-up skill for turning audit issue findings into a PR.
- `scripts/install-audit.ps1` and `scripts/install-audit.sh` - installers that copy the workflow and skills into a target repository.

## Install

From this repository:

```powershell
.\scripts\install-audit.ps1 -RepoPath E:\YourProject
```

or:

```bash
./scripts/install-audit.sh /path/to/your-project
```

Then commit the copied files in the target repository.

## Required GitHub Settings

In the target repository:

1. Add `CLAUDE_CODE_OAUTH_TOKEN` under Settings > Secrets and variables > Actions.
2. Set Settings > Actions > General > Workflow permissions to `Read and write permissions`.
3. Ensure Issues are enabled.

The workflow uses Claude Code subscription OAuth allocation. It unsets `ANTHROPIC_API_KEY` and `ANTHROPIC_AUTH_TOKEN` before running Claude so those credentials do not override `CLAUDE_CODE_OAUTH_TOKEN`.

## Audit Workflow

`Biweekly Audit` runs on the 1st and 15th of each month and can also be triggered manually.

The workflow:

1. Skips if no non-documentation code changed since the last `audit/*` tag.
2. Installs the bundled architecture and tech debt skills into `$HOME/.claude/skills`.
3. Runs one Claude Code session that creates:
   - `ARCHITECTURE_AUDIT.md`
   - `TECH_DEBT_AUDIT.md`
   - `combined-audit-report.md`
   - `change-summary.txt`
   - `issue-body.md`
4. Creates a GitHub issue and posts each report file as chunked comments.
5. Uploads the same files as an Actions artifact.
6. Tags the commit with `audit/<timestamp>` only after a successful audit.

## Resolve Audit

After an audit issue is created, invoke `/resolve-audit` in an agent session and give it the issue number.

The skill intentionally requires a classification confirmation step before code changes. It separates findings into:

- Category A: behavior changes, handled with TDD.
- Category B: pure refactors, gated by the existing test suite.
- Category C: config, type, dependency, or documentation work, gated by lint/compiler/dependency checks.

The resolve workflow is not scheduled automatically. That is deliberate: audit findings may require human prioritization before code modification.

## Notes

- Jupyter notebooks are ignored by both the audit and resolve protocols.
- The workflow is designed for repositories that allow GitHub Actions to create issues and push tags.
- Large reports are posted as line-preserving issue comment chunks to avoid truncation and UTF-8 splitting problems.
