#!/usr/bin/env bash
set -euo pipefail

skill_name="cyber-classifier-workflow"
source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
skill_file="$source_root/SKILL.md"
skills_dir=""
create_zip=0
zip_only=0
zip_path=""

usage() {
  cat <<'EOF'
Usage:
  install-claude.sh [skills-dir]
  install-claude.sh --skills-dir DIR
  install-claude.sh --zip [--zip-path FILE]
  install-claude.sh --zip-only [--zip-path FILE]

Installs this skill for Claude Code by default:
  ~/.claude/skills/cyber-classifier-workflow

Use --zip or --zip-only to create a Claude.ai upload package:
  dist/cyber-classifier-workflow.zip
EOF
}

if [ ! -f "$skill_file" ]; then
  echo "SKILL.md was not found. Run this script from the cloned skill repository." >&2
  exit 1
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skills-dir)
      if [ "$#" -lt 2 ]; then
        echo "--skills-dir requires a directory." >&2
        exit 2
      fi
      skills_dir="$2"
      shift 2
      ;;
    --zip)
      create_zip=1
      shift
      ;;
    --zip-only)
      create_zip=1
      zip_only=1
      shift
      ;;
    --zip-path)
      if [ "$#" -lt 2 ]; then
        echo "--zip-path requires a file path." >&2
        exit 2
      fi
      create_zip=1
      zip_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$skills_dir" ]; then
        echo "Only one skills directory can be provided." >&2
        exit 2
      fi
      skills_dir="$1"
      shift
      ;;
  esac
done

copy_skill_items() {
  destination_root="$1"

  for item in SKILL.md references scripts agents assets .claude-plugin; do
    if [ -e "$source_root/$item" ]; then
      cp -R "$source_root/$item" "$destination_root/"
    fi
  done
}

install_claude_code_skill() {
  if [ -z "$skills_dir" ]; then
    claude_home="${CLAUDE_HOME:-$HOME/.claude}"
    skills_dir="$claude_home/skills"
  fi

  mkdir -p "$skills_dir"
  skills_dir="$(cd "$skills_dir" && pwd -P)"
  destination="$skills_dir/$skill_name"

  if [ "$source_root" = "$destination" ]; then
    echo "Skill is already installed at $destination"
    echo "Restart Claude Code if the skill does not appear."
    return
  fi

  case "$destination" in
    "$skills_dir"/*) ;;
    *)
      echo "Refusing to install outside the skills directory: $destination" >&2
      exit 1
      ;;
  esac

  temp_destination="$skills_dir/.$skill_name.installing-$$"
  rm -rf "$temp_destination"
  mkdir -p "$temp_destination"

  cleanup_install() {
    rm -rf "$temp_destination"
  }
  trap cleanup_install EXIT

  copy_skill_items "$temp_destination"

  rm -rf "$destination"
  mv "$temp_destination" "$destination"
  trap - EXIT

  echo "Installed $skill_name for Claude Code to $destination"
  echo "Restart Claude Code if the skill does not appear."
}

create_claude_ai_zip() {
  if ! command -v zip >/dev/null 2>&1; then
    echo "The zip command was not found. Install zip or create the package manually." >&2
    exit 1
  fi

  if [ -z "$zip_path" ]; then
    zip_path="$source_root/dist/$skill_name.zip"
  fi

  case "$zip_path" in
    /*) zip_abs="$zip_path" ;;
    *) zip_abs="$source_root/$zip_path" ;;
  esac

  zip_dir="$(dirname "$zip_abs")"
  mkdir -p "$zip_dir"
  zip_dir="$(cd "$zip_dir" && pwd -P)"
  zip_abs="$zip_dir/$(basename "$zip_abs")"

  temp_package="$(mktemp -d "${TMPDIR:-/tmp}/${skill_name}.package.XXXXXX")"
  cleanup_package() {
    rm -rf "$temp_package"
  }
  trap cleanup_package EXIT

  mkdir -p "$temp_package/$skill_name"
  copy_skill_items "$temp_package/$skill_name"

  rm -f "$zip_abs"
  (
    cd "$temp_package"
    zip -qr "$zip_abs" "$skill_name"
  )

  trap - EXIT
  rm -rf "$temp_package"

  echo "Created Claude.ai upload package at $zip_abs"
}

if [ "$zip_only" -eq 0 ]; then
  install_claude_code_skill
fi

if [ "$create_zip" -eq 1 ]; then
  create_claude_ai_zip
fi
