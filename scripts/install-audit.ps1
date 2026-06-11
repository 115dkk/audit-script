param(
    [string]$RepoPath = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SourceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$TargetRoot = Resolve-Path $RepoPath

$workflowSource = Join-Path $SourceRoot ".github\workflows\biweekly-audit.yml"
$workflowTargetDir = Join-Path $TargetRoot ".github\workflows"
$workflowTarget = Join-Path $workflowTargetDir "biweekly-audit.yml"

$skillsSource = Join-Path $SourceRoot ".claude\skills"
$skillsTarget = Join-Path $TargetRoot ".claude\skills"

New-Item -ItemType Directory -Path $workflowTargetDir -Force | Out-Null
New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null

if ((Test-Path $workflowTarget) -and -not $Force) {
    throw "Workflow already exists: $workflowTarget. Re-run with -Force to overwrite."
}

Copy-Item -LiteralPath $workflowSource -Destination $workflowTarget -Force:$Force

foreach ($skill in "improve-codebase-architecture", "tech-debt-audit", "resolve-audit") {
    $source = Join-Path $skillsSource $skill
    $target = Join-Path $skillsTarget $skill

    if ((Test-Path $target) -and -not $Force) {
        throw "Skill already exists: $target. Re-run with -Force to overwrite."
    }

    if (Test-Path $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }

    Copy-Item -LiteralPath $source -Destination $target -Recurse
}

Write-Host "Installed audit workflow and skills into $TargetRoot"
Write-Host "Next steps:"
Write-Host "  1. Commit .github/workflows/biweekly-audit.yml and .claude/skills/"
Write-Host "  2. Add GitHub Actions secret CLAUDE_CODE_OAUTH_TOKEN"
Write-Host "  3. Set Actions workflow permissions to Read and write"
