#!/bin/bash
#
# 财经博主简报任务 - launchd 触发的无头执行
# 由 ~/Library/LaunchAgents/com.liuyizhen.claude.finance-news.plist 调度
#

set -uo pipefail

CLAUDE="/Users/liuyizhen/.npm-global/bin/claude"
PROMPT_FILE="$HOME/.claude/prompts/finance-news.md"
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/finance-news-$(date +%Y%m%d).log"

# launchd 的 PATH 极简，确保 claude 能调用到 node 等依赖
# 同时加入 ~/bin（longbridge CLI 所在）
export PATH="/Users/liuyizhen/.npm-global/bin:/Users/liuyizhen/.local/bin:/Users/liuyizhen/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Clash Verge 代理（常驻 7897）— Longbridge API 需走代理才能访问
export https_proxy="http://127.0.0.1:7897"
export http_proxy="http://127.0.0.1:7897"
export all_proxy="socks5://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
export HTTP_PROXY="http://127.0.0.1:7897"
export ALL_PROXY="socks5://127.0.0.1:7897"
export no_proxy="localhost,127.0.0.1"

{
  echo "==================== $(date '+%Y-%m-%d %H:%M:%S %Z') START ===================="

  if [[ ! -x "$CLAUDE" ]]; then
    echo "ERROR: claude CLI not found at $CLAUDE"
    exit 1
  fi
  if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "ERROR: prompt file missing: $PROMPT_FILE"
    exit 1
  fi

  cd "$HOME"

  # Pre-compute Longbridge snapshot (shifts 30+ LB calls + raw klines OUT of claude prompt)
  # Best-effort: if it fails we still run claude with whatever cached snapshot exists
  SNAPSHOT_SCRIPT="$HOME/.claude/scripts/lb-snapshot.sh"
  if [[ -x "$SNAPSHOT_SCRIPT" ]]; then
    echo "--- Running lb-snapshot.sh (pre-process Longbridge data) ---"
    if "$SNAPSHOT_SCRIPT"; then
      echo "--- Snapshot OK ---"
    else
      echo "WARN: lb-snapshot.sh failed (exit=$?); claude will use stale/empty cache if present"
    fi
    echo ""
  else
    echo "WARN: $SNAPSHOT_SCRIPT not found or not executable; skipping snapshot pre-compute"
  fi

  # IMPORTANT: claude → api.anthropic.com must NOT go through Clash —
  # the proxy drops long-running streaming connections (observed ECONNRESET after ~8 min).
  # Snapshot script sets its own proxy internally; we unset here so claude uses direct egress.
  unset https_proxy http_proxy all_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY no_proxy

  # 注入北京时间，避免 Claude 用 UTC 生成错误的标题时间戳
  LOCAL_NOW=$(TZ="Asia/Shanghai" date '+%Y-%m-%d %H:%M')
  { echo "当前北京时间：${LOCAL_NOW}，请用此时间生成标题中的 HH:mm。"; echo; cat "$PROMPT_FILE"; } | \
  "$CLAUDE" -p \
    --permission-mode bypassPermissions \
    --output-format text &
  CLAUDE_PID=$!

  # Watchdog: kill claude after 25 min if still running
  ( sleep 1500 && kill "$CLAUDE_PID" 2>/dev/null && echo "ERROR: claude timed out after 25 min (killed PID $CLAUDE_PID)" ) &
  WATCHDOG_PID=$!

  wait "$CLAUDE_PID"
  EXIT_CODE=$?
  kill "$WATCHDOG_PID" 2>/dev/null
  wait "$WATCHDOG_PID" 2>/dev/null
  echo ""
  echo "==================== $(date '+%Y-%m-%d %H:%M:%S %Z') END (exit=$EXIT_CODE) ===================="
} >> "$LOG_FILE" 2>&1
