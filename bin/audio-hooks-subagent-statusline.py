#!/usr/bin/env python3
"""echook subagent status line — one rendered row per running subagent.

Claude Code's `subagentStatusLine` setting is a second, separate status-line
surface from `statusLine`: it renders a row for every task in the agent panel
rather than one line for the session. echook did not claim it before v6.5, and
with agent teams in common use it is where most of the interesting state now
lives.

The contract (recovered from Claude Code 2.1.239, since it is barely
documented) is *not* the same as the main status line, and getting it wrong
produces silence rather than an error:

  stdin   one JSON object::

              {"columns": 120,
               "tasks": [{"id", "name", "type", "status", "description",
                          "label", "startTime", "model", "effort",
                          "contextWindowSize", "tokenCount", "tokenSamples",
                          "cwd"}, ...],
               ... plus the usual session/project fields}

  stdout  NDJSON — **one JSON object per line**, not free text::

              {"id": "<the task's id>", "content": "<rendered row>"}

          Claude Code keys the result by `id`, so a row whose id does not match
          a task is silently dropped. A non-JSON line is logged as
          "subagentStatusLine emitted non-JSON line" and skipped; a line that
          parses but lacks id/content is "emitted invalid schema".

  timeout 5000 ms (upstream constant), so this stays dependency-free and does
          no I/O beyond reading stdin.

Like the main status line this must never crash the caller: every failure path
exits 0 having written nothing, which Claude Code renders as "no custom row".
"""

from __future__ import annotations

import json
import sys
import time

# Upstream truncates hard; keep rows well inside a panel column.
MAX_CONTENT = 120


def _num(value, default=0):
    try:
        if value is None:
            return default
        return float(value)
    except (TypeError, ValueError):
        return default


def _fmt_tokens(n: float) -> str:
    n = int(n)
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def _fmt_elapsed(start_ms: float) -> str:
    """Wall-clock since the task started. Empty when the clock looks wrong."""
    if start_ms <= 0:
        return ""
    now_ms = time.time() * 1000.0
    delta = (now_ms - start_ms) / 1000.0
    # startTime has been observed in both ms and s; treat an absurd result as
    # unusable rather than rendering "in 55 years".
    if delta < 0 or delta > 60 * 60 * 24 * 7:
        return ""
    if delta < 60:
        return f"{int(delta)}s"
    if delta < 3600:
        return f"{int(delta // 60)}m{int(delta % 60):02d}s"
    return f"{int(delta // 3600)}h{int((delta % 3600) // 60):02d}m"


_STATUS_ICON = {
    "running": "▶",
    "pending": "…",
    "queued": "…",
    "done": "✓",
    "completed": "✓",
    "success": "✓",
    "failed": "✗",
    "error": "✗",
    "cancelled": "⊘",
    "canceled": "⊘",
    "awaiting": "⏸",
    "blocked": "⏸",
}


def render_row(task: dict) -> str:
    """Build one subagent's row. Never raises."""
    parts = []

    status = str(task.get("status") or "").lower()
    icon = _STATUS_ICON.get(status)
    if icon:
        parts.append(icon)

    model = task.get("model")
    if model:
        # Model ids are long; the trailing segment is the useful part.
        label = str(model).split("/")[-1]
        for prefix in ("claude-", "anthropic."):
            if label.startswith(prefix):
                label = label[len(prefix):]
        parts.append(label)

    effort = task.get("effort")
    if effort:
        parts.append(f"🧠{effort}")

    tokens = _num(task.get("tokenCount"))
    window = _num(task.get("contextWindowSize"))
    if tokens > 0:
        if window > 0:
            pct = min(999, int(tokens / window * 100))
            parts.append(f"◔{pct}% {_fmt_tokens(tokens)}/{_fmt_tokens(window)}")
        else:
            parts.append(f"◔{_fmt_tokens(tokens)}")

    elapsed = _fmt_elapsed(_num(task.get("startTime")))
    if elapsed:
        parts.append(f"⏱{elapsed}")

    row = " · ".join(p for p in parts if p)
    return row[:MAX_CONTENT]


def main() -> int:
    try:
        raw = sys.stdin.read()
    except (OSError, ValueError):
        return 0
    if not raw.strip():
        return 0
    try:
        data = json.loads(raw)
    except (json.JSONDecodeError, ValueError):
        return 0
    if not isinstance(data, dict):
        return 0

    tasks = data.get("tasks")
    if not isinstance(tasks, list):
        return 0

    out = []
    for task in tasks:
        if not isinstance(task, dict):
            continue
        task_id = task.get("id")
        # Claude Code keys results by id — a row without one is unroutable.
        if not isinstance(task_id, str) or not task_id:
            continue
        try:
            content = render_row(task)
        except Exception:
            continue
        if not content:
            continue
        out.append(json.dumps({"id": task_id, "content": content}, ensure_ascii=False))

    if out:
        sys.stdout.write("\n".join(out) + "\n")
        sys.stdout.flush()
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # A status line must never take the session down with it.
        sys.exit(0)
