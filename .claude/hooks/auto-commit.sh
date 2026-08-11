#!/usr/bin/env bash
#
# Stop hook — commits and pushes whatever the turn left behind.
# Wired up in .claude/settings.json; see the "커밋" section of CLAUDE.md.
#
# Deliberately narrow: it only ever runs on main, only when something actually
# changed, and never prompts. Anything else it leaves alone and exits quietly,
# because a Stop hook runs after *every* turn — including turns that only
# answered a question.
set -u

# Run from the repo root no matter what the hook's working directory is.
cd "$(dirname "$0")/../.." || exit 0

# A credential prompt inside a hook would block the session with nowhere to
# type, so make git fail fast instead.
export GIT_TERMINAL_PROMPT=0

[ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" = "main" ] || exit 0

# stdout is parsed as the hook's JSON result, so nothing else may reach it.
# `git diff --cached --quiet` is not quiet enough — it prints the diff header
# for added files — hence the name-only emptiness check.
git add -A 2>/dev/null || exit 0
[ -n "$(git diff --cached --name-only 2>/dev/null)" ] || exit 0

stamp=$(date '+%Y-%m-%d %H:%M')

if ! git commit -q -m "chore: 작업 자동 저장 $stamp" >/dev/null 2>&1; then
  echo "{\"systemMessage\": \"자동 커밋 실패 - git status를 확인하세요\"}"
  exit 0
fi

if git push -q origin main; then
  echo "{\"systemMessage\": \"자동 커밋·푸시 완료 ($stamp)\"}"
else
  echo "{\"systemMessage\": \"커밋은 됐지만 push 실패 - 직접 git push 하세요\"}"
fi
exit 0
