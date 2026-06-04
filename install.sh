#!/usr/bin/env bash
set -euo pipefail

skill_name="cyber-classifier-workflow"
source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_file="$source_root/SKILL.md"

if [ ! -f "$skill_file" ]; then
  echo "SKILL.md was not found. Run this script from the cloned skill repository." >&2
  exit 1
fi

if [ $# -gt 1 ]; then
  echo "Usage: install.sh [skills-dir]" >&2
  exit 2
fi

if [ $# -eq 1 ]; then
  skills_dir="$1"
else
  codex_home="${CODEX_HOME:-$HOME/.codex}"
  skills_dir="$codex_home/skills"
fi

mkdir -p "$skills_dir"
skills_dir="$(cd "$skills_dir" && pwd)"
destination="$skills_dir/$skill_name"

if [ "$source_root" = "$destination" ]; then
  echo "Skill is already installed at $destination"
  echo "Restart Codex or reload skills to use it."
  exit 0
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

cleanup() {
  rm -rf "$temp_destination"
}
trap cleanup EXIT

for item in SKILL.md references scripts agents assets; do
  if [ -e "$source_root/$item" ]; then
    cp -R "$source_root/$item" "$temp_destination/"
  fi
done

rm -rf "$destination"
mv "$temp_destination" "$destination"
trap - EXIT

echo "Installed $skill_name to $destination"
echo "Restart Codex or reload skills to use it."
