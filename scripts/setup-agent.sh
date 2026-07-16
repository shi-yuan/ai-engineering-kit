#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "用法: $0 <project-root> <openspec-root-or-parent>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$1" && pwd)"
OPENSPEC_INPUT="$(cd "$2" && pwd)"

if [ -f "$OPENSPEC_INPUT/config.yaml" ] && [ -d "$OPENSPEC_INPUT/agent" ]; then
  OPEN_SPEC_ROOT="$OPENSPEC_INPUT"
  OPENSPEC_REPO_ROOT="$(cd "$OPEN_SPEC_ROOT/.." && pwd)"
else
  OPENSPEC_REPO_ROOT="$OPENSPEC_INPUT"
  OPEN_SPEC_ROOT="$(cd "$OPENSPEC_REPO_ROOT/openspec" && pwd)"
fi

PROJECT_RULES="$OPEN_SPEC_ROOT/agent/project-rules.md"
LEGACY_PROJECT_RULES="$OPENSPEC_REPO_ROOT/agent/project-rules.md"
KIT_VERSION="$(tr -d '[:space:]' < "$KIT_ROOT/VERSION")"

if [ ! -f "$PROJECT_RULES" ]; then
  if [ -f "$LEGACY_PROJECT_RULES" ]; then
    PROJECT_RULES="$LEGACY_PROJECT_RULES"
  else
    echo "未找到项目规则文件。请创建 $PROJECT_RULES"
    exit 1
  fi
fi

REL_OPEN_SPEC="$(python3 - "$PROJECT_ROOT" "$OPEN_SPEC_ROOT" <<'PY'
import os, sys
print(os.path.relpath(sys.argv[2], sys.argv[1]).replace("\\", "/"))
PY
)"
REL_SKILLS_ROOT="$REL_OPEN_SPEC/agent/skills"

echo "KitRoot       : $KIT_ROOT"
echo "KitVersion    : $KIT_VERSION"
echo "ProjectRoot   : $PROJECT_ROOT"
echo "OpenSpecInput : $OPENSPEC_INPUT"
echo "OpenSpecRoot  : $REL_OPEN_SPEC"
echo "ProjectRules  : $PROJECT_RULES"
echo "SkillsRoot    : $REL_SKILLS_ROOT"

{
  cat "$KIT_ROOT/AGENTS.base.md"
  printf '\n\n---\n\n# 项目专属规则\n\n'
  printf '> 以下内容由项目 OpenSpec 的 `agent/project-rules.md` 合并生成。\n'
  printf '> 请勿直接修改聚合目录中的 AGENTS.md；应修改源文件后重新执行 setup-agent。\n\n'
  cat "$PROJECT_RULES"
} > "$PROJECT_ROOT/AGENTS.md"

cp "$KIT_ROOT/adapters/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
cp "$KIT_ROOT/adapters/CODEBUDDY.md" "$PROJECT_ROOT/CODEBUDDY.md"
cp "$KIT_ROOT/adapters/CODEX.md" "$PROJECT_ROOT/CODEX.md"

rm -rf "$OPEN_SPEC_ROOT/agent/skills"
mkdir -p "$OPEN_SPEC_ROOT/agent/skills"
cp -R "$KIT_ROOT/skills/." "$OPEN_SPEC_ROOT/agent/skills/"

cat > "$PROJECT_ROOT/.agent-env.md" <<EOF
# Agent Environment

AI_ENGINEERING_KIT_VERSION=$KIT_VERSION
AI_ENGINEERING_KIT_HOME=$KIT_ROOT
WORKSPACE_ROOT=.
OPEN_SPEC_ROOT=$REL_OPEN_SPEC
AGENT_SKILLS_ROOT=$REL_SKILLS_ROOT

> 本文件由 ai-engineering-kit 生成。
> 不要手工修改；修改源配置后重新执行 setup-agent。
EOF

echo
echo "Agent workspace setup completed."
echo "请从以下聚合目录启动 Agent:"
echo "  $PROJECT_ROOT"
