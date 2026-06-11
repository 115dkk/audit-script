#!/usr/bin/env bash
set -euo pipefail

repo_path="${1:-$(pwd)}"
force="${FORCE:-0}"

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$(cd "$repo_path" && pwd)"

workflow_source="$source_root/.github/workflows/biweekly-audit.yml"
workflow_target_dir="$target_root/.github/workflows"
workflow_target="$workflow_target_dir/biweekly-audit.yml"

skills_source="$source_root/.claude/skills"
skills_target="$target_root/.claude/skills"

mkdir -p "$workflow_target_dir" "$skills_target"

if [[ -e "$workflow_target" && "$force" != "1" ]]; then
  echo "Workflow already exists: $workflow_target. Re-run with FORCE=1 to overwrite." >&2
  exit 1
fi

cp -f "$workflow_source" "$workflow_target"

for skill in improve-codebase-architecture tech-debt-audit resolve-audit; do
  source="$skills_source/$skill"
  target="$skills_target/$skill"

  if [[ -e "$target" && "$force" != "1" ]]; then
    echo "Skill already exists: $target. Re-run with FORCE=1 to overwrite." >&2
    exit 1
  fi

  rm -rf "$target"
  cp -R "$source" "$target"
done

cat <<EOF
Installed audit workflow and skills into $target_root
Next steps:
  1. Commit .github/workflows/biweekly-audit.yml and .claude/skills/
  2. Add GitHub Actions secret CLAUDE_CODE_OAUTH_TOKEN
  3. Set Actions workflow permissions to Read and write
EOF
