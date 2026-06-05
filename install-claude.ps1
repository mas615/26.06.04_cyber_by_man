param(
  [string]$SkillsDir,
  [switch]$Zip,
  [switch]$ZipOnly,
  [string]$ZipPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillName = "cyber-classifier-workflow"
$SourceRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$SkillFile = Join-Path $SourceRoot "SKILL.md"

if (-not (Test-Path -LiteralPath $SkillFile -PathType Leaf)) {
  throw "SKILL.md was not found. Run this script from the cloned skill repository."
}

function Copy-SkillItems {
  param([string]$DestinationRoot)

  $ItemsToCopy = @("SKILL.md", "references", "scripts", "agents", "assets", ".claude-plugin")

  foreach ($Item in $ItemsToCopy) {
    $Source = Join-Path $SourceRoot $Item
    if (Test-Path -LiteralPath $Source) {
      Copy-Item -LiteralPath $Source -Destination $DestinationRoot -Recurse -Force
    }
  }
}

function Install-ClaudeCodeSkill {
  if ([string]::IsNullOrWhiteSpace($SkillsDir)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CLAUDE_HOME)) {
      $ClaudeHome = $env:CLAUDE_HOME
    } elseif (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
      $ClaudeHome = Join-Path $env:USERPROFILE ".claude"
    } else {
      $ClaudeHome = Join-Path $HOME ".claude"
    }

    $ResolvedSkillsDir = Join-Path $ClaudeHome "skills"
  } else {
    $ResolvedSkillsDir = $SkillsDir
  }

  $ResolvedSkillsDir = [System.IO.Path]::GetFullPath($ResolvedSkillsDir)
  $Destination = [System.IO.Path]::GetFullPath((Join-Path $ResolvedSkillsDir $SkillName))
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
    Write-Host "Restart Claude Code if the skill does not appear."
    return
  }

  New-Item -ItemType Directory -Force -Path $ResolvedSkillsDir | Out-Null

  $SkillsDirFull = [System.IO.Path]::GetFullPath($ResolvedSkillsDir).TrimEnd(
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

  $TempDestination = Join-Path $ResolvedSkillsDir (".$SkillName.installing-" + [guid]::NewGuid().ToString("N"))

  try {
    New-Item -ItemType Directory -Force -Path $TempDestination | Out-Null
    Copy-SkillItems -DestinationRoot $TempDestination

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

  Write-Host "Installed $SkillName for Claude Code to $Destination"
  Write-Host "Restart Claude Code if the skill does not appear."
}

function New-ClaudeAiZip {
  if ([string]::IsNullOrWhiteSpace($ZipPath)) {
    $OutputPath = Join-Path $SourceRoot (Join-Path "dist" "$SkillName.zip")
  } else {
    $OutputPath = $ZipPath
  }

  $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
  $OutputDir = Split-Path -Parent $OutputPath
  New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

  $TempPackage = Join-Path ([System.IO.Path]::GetTempPath()) ("$SkillName.package-" + [guid]::NewGuid().ToString("N"))
  $PackageSkillRoot = Join-Path $TempPackage $SkillName

  try {
    New-Item -ItemType Directory -Force -Path $PackageSkillRoot | Out-Null
    Copy-SkillItems -DestinationRoot $PackageSkillRoot

    if (Test-Path -LiteralPath $OutputPath) {
      Remove-Item -LiteralPath $OutputPath -Force
    }

    Compress-Archive -LiteralPath $PackageSkillRoot -DestinationPath $OutputPath -Force
  } finally {
    if (Test-Path -LiteralPath $TempPackage) {
      Remove-Item -LiteralPath $TempPackage -Recurse -Force
    }
  }

  Write-Host "Created Claude.ai upload package at $OutputPath"
}

if (-not $ZipOnly) {
  Install-ClaudeCodeSkill
}

if ($Zip -or $ZipOnly -or -not [string]::IsNullOrWhiteSpace($ZipPath)) {
  New-ClaudeAiZip
}
