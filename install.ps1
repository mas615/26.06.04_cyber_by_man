param(
  [string]$SkillsDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillName = "cyber-classifier-workflow"
$SourceRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$SkillFile = Join-Path $SourceRoot "SKILL.md"

if (-not (Test-Path -LiteralPath $SkillFile -PathType Leaf)) {
  throw "SKILL.md was not found. Run this script from the cloned skill repository."
}

if ([string]::IsNullOrWhiteSpace($SkillsDir)) {
  if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
    $CodexHome = $env:CODEX_HOME
  } elseif (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    $CodexHome = Join-Path $env:USERPROFILE ".codex"
  } else {
    $CodexHome = Join-Path $HOME ".codex"
  }

  $SkillsDir = Join-Path $CodexHome "skills"
}

$SkillsDir = [System.IO.Path]::GetFullPath($SkillsDir)
$Destination = [System.IO.Path]::GetFullPath((Join-Path $SkillsDir $SkillName))
$SourceRootFull = [System.IO.Path]::GetFullPath($SourceRoot).TrimEnd(
  [System.IO.Path]::DirectorySeparatorChar,
  [System.IO.Path]::AltDirectorySeparatorChar
)
$DestinationFull = $Destination.TrimEnd(
  [System.IO.Path]::DirectorySeparatorChar,
  [System.IO.Path]::AltDirectorySeparatorChar
)

if ([string]::Equals($SourceRootFull, $DestinationFull, [System.StringComparison]::OrdinalIgnoreCase)) {
  Write-Host "Skill is already installed at $DestinationFull"
  Write-Host "Restart Codex or reload skills to use it."
  exit 0
}

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

$SkillsDirFull = [System.IO.Path]::GetFullPath($SkillsDir).TrimEnd(
  [System.IO.Path]::DirectorySeparatorChar,
  [System.IO.Path]::AltDirectorySeparatorChar
)
$ExpectedPrefix = $SkillsDirFull + [System.IO.Path]::DirectorySeparatorChar

if (-not $DestinationFull.StartsWith($ExpectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Refusing to install outside the skills directory: $DestinationFull"
}

if ((Split-Path -Leaf $DestinationFull) -ne $SkillName) {
  throw "Unexpected destination folder name: $DestinationFull"
}

$TempDestination = Join-Path $SkillsDir (".$SkillName.installing-" + [guid]::NewGuid().ToString("N"))
$ItemsToCopy = @("SKILL.md", "references", "scripts", "agents", "assets")

try {
  New-Item -ItemType Directory -Force -Path $TempDestination | Out-Null

  foreach ($Item in $ItemsToCopy) {
    $Source = Join-Path $SourceRoot $Item
    if (Test-Path -LiteralPath $Source) {
      Copy-Item -LiteralPath $Source -Destination $TempDestination -Recurse -Force
    }
  }

  if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }

  Move-Item -LiteralPath $TempDestination -Destination $Destination
} catch {
  if (Test-Path -LiteralPath $TempDestination) {
    Remove-Item -LiteralPath $TempDestination -Recurse -Force
  }
  throw
}

Write-Host "Installed $SkillName to $Destination"
Write-Host "Restart Codex or reload skills to use it."
