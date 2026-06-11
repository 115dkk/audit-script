# Licensing Notes

This repository intentionally has no repository-level open-source license yet.

The bundled files were assembled from local Claude/Codex skill directories for private use. Before making this repository public or redistributing it outside repositories you control, confirm the origin and license of each unconfirmed bundled skill.

## Current Findings

| Path | License evidence found locally | Current redistribution posture |
| --- | --- | --- |
| `.claude/skills/tech-debt-audit` | `SKILL.md` and `README.md` include `MIT. Use it, fork it, ship it. Attribution appreciated but not required.` | Appears MIT-compatible based on bundled text. |
| `.claude/skills/improve-codebase-architecture` | No license or copyright notice found in the bundled files. | Treat as unlicensed until origin/license is confirmed. |
| `.claude/skills/resolve-audit` | Repository owner confirmed authorship and approved MIT distribution for this package. | MIT-compatible for this package. |
| `.claude/skills/tdd` | No license or copyright notice found in the bundled files. | Treat as unlicensed until origin/license is confirmed. |
| `.github/workflows/biweekly-audit.yml` | Project-local workflow assembled for this package. | Controlled by repository owner. |
| `scripts/install-audit.*` and `README.md` | Written for this package. | Controlled by repository owner. |

Unconfirmed bundled skills:

- `.claude/skills/improve-codebase-architecture`
- `.claude/skills/tdd`

## Public Release Rule

Do not make this repository public until one of the following is true for every bundled skill:

1. The skill author/license is confirmed and the license allows redistribution.
2. The skill is replaced with an original implementation.
3. The skill is removed from the public package.

If any confirmed bundled skill is GPL-only, license the public package under the compatible GPL version and include the full corresponding GPL license text.
