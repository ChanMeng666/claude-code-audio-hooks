# Notification Hook Behavior - VERIFIED AND CORRECTED

## ✅ VERIFIED: Notification Hook DOES Trigger on Permission Prompts!

After real-world testing, we have **confirmed** that the **Notification hook** DOES trigger when Claude Code shows permission prompts like:

```
Do you want to proceed?
  1. Yes
❯ 2. Yes, and don't ask again for similar commands
  3. No, and tell Claude what to do differently (esc)
```

**When this prompt appears, the Notification hook triggers and plays `notification-urgent.mp3`.**

## When Notification Hook Triggers:

✅ **Permission prompts** ("Do you want to proceed?")
✅ **Authorization requests** (Tool execution confirmations)
✅ **System-level alerts**
✅ **Claude Code notification events**

## THIS IS THE CORRECT HOOK FOR THE PROJECT'S CORE MISSION

The Notification hook is **exactly what this project needs** to alert users when Claude Code pauses for authorization or confirmation.

## Real-World Evidence

**User Verification (2025-11-01):**
When Claude Code showed the git commit permission prompt "Do you want to proceed?",
the audio that played was `notification-urgent.mp3` (Notification hook), NOT
`task-starting.mp3` (PreToolUse hook).

This confirms: **Notification hook = Permission prompts ✅**

## Recommended Configuration

### ✅ Optimal Setup (3 Essential Hooks)

```json
{
  "enabled_hooks": {
    "notification": true,     // ← Permission prompts ✅
    "stop": true,             // ← Task completion ✅
    "subagent_stop": true,    // ← Background tasks ✅

    "pretooluse": false,      // ← NOT needed! Too noisy
    "posttooluse": false,
    "userpromptsubmit": false,
    "precompact": false,
    "session_start": false,
    "session_end": false
  }
}
```

**Why this is optimal:**
- ✅ Notification hook alerts on permission prompts
- ✅ Stop hook alerts when Claude finishes
- ✅ SubagentStop alerts on background tasks
- ❌ No noise from PreToolUse (which fires on EVERY tool)
- ❌ No unnecessary confirmations

## What About PreToolUse Hook?

**PreToolUse is NOT needed for permission prompts!**

PreToolUse fires **before every single tool execution**:
- Before Read
- Before Write
- Before Edit
- Before Bash
- Before Grep
- Before Glob
- etc.

This means you'd hear `task-starting.mp3` constantly during development,
which is extremely noisy and NOT what this project is designed for.

**The Notification hook already handles permission prompts perfectly.**

## Example: Git Commit Flow (Verified)

### With Recommended Config (Notification + Stop + SubagentStop)

```
1. Claude prepares git commit
2. 🔊 notification-urgent.mp3 plays ← Notification hook (permission prompt!)
3. [You see "Do you want to proceed?"]
4. You select option
5. Git commit executes
6. 🔊 task-complete.mp3 plays ← Stop hook (Claude finishes response)
```

**This is clean, effective, and exactly what the project needs!**

### With PreToolUse Enabled (NOT recommended)

```
1. Claude prepares git commit
2. 🔊 task-starting.mp3 plays ← PreToolUse (before prompt)
3. 🔊 notification-urgent.mp3 plays ← Notification (permission prompt)
4. [You see "Do you want to proceed?"]
5. You select option
6. Git commit executes
7. 🔊 task-complete.mp3 plays ← Stop hook

Plus you'd hear task-starting.mp3 before EVERY Read, Write, Edit, etc.
This is extremely noisy and unnecessary!
```

## Comparison Table

| Scenario | Notification Hook | PreToolUse Hook | Stop Hook |
|----------|-------------------|-----------------|-----------|
| Permission prompt appears | ✅ Yes | ❌ No (fires before) | ❌ No |
| User confirms command | ❌ No | ❌ No | ❌ No |
| Command executes | ❌ No | ❌ No | ❌ No |
| Claude finishes response | ❌ No | ❌ No | ✅ Yes |
| Before ANY tool | ❌ No | ✅ Yes (NOISY!) | ❌ No |

## Previous Misconception

Earlier documentation incorrectly stated that Notification hook does NOT trigger
on permission prompts. This was based on incomplete testing.

**The user's real-world verification corrected this misunderstanding.**

When the user saw "Do you want to proceed?" during a git commit, they heard
`notification-urgent.mp3`, which confirmed that Notification hook is the
correct and only hook needed for permission prompt alerts.

## Summary

✅ **Notification hook DOES trigger on permission prompts**
✅ **This is the correct and optimal hook for the project's mission**
✅ **Default configuration (Notification + Stop + SubagentStop) is perfect**
❌ **PreToolUse is NOT needed and creates unnecessary noise**

**Keep the default configuration:**
- **notification: true** → Permission prompts ("Do you want to proceed?")
- **stop: true** → Task completion
- **subagent_stop: true** → Background tasks
- **Everything else: false** → Avoid noise

This configuration achieves the project's core mission:
**"Alert user whenever Claude Code stops or pauses for ANY reason"**
