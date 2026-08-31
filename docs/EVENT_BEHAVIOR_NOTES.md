# Observed event behaviour

What Claude Code's hook events **actually do**, measured against a running install — as distinct from what [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks) documents. Everything here was captured from real sessions, not inferred.

This file exists because of v6.3.4. That release was an emergency rollback: echook registered a sound on `WorktreeCreate`, but `WorktreeCreate` is a *provider* hook — registering any command hook on it makes Claude Code delegate worktree creation to that hook and demand a path back. The audio hook returned exit 0 with no path, so every worktree-isolated subagent failed. The event's name said "notify me when a worktree is created"; its contract said "you are now responsible for creating worktrees".

**The lesson, and the rule for this project: verify an event's real semantics before shipping a hook on it.** Record what you observed here, and cite it in the CHANGELOG.

---

## How to capture

Register a shim against the events you care about in `~/.claude/settings.json` (hot-reloads, no restart needed), pointing at a script that appends stdin to a file and exits 0. Keep the shim outside the repo.

For matcher-scoped events, register **a catch-all (`"matcher": ""`) alongside the named matchers**. This is what makes a negative result interpretable: the catch-all sees every value of that matcher field, so if a type never appears there, the type genuinely never occurred — as opposed to the matcher string being unrecognised by this Claude Code version. Without the catch-all, "no sound" has two indistinguishable explanations.

Exercise the paths deliberately — long turns, `Task` subagents, background shells, plan-mode approvals, going idle, ending the session — and correlate by `session_id` and timestamp. Then remove the shim and the `hooks` block.

`CLAUDE_HOOKS_DEBUG=1` also makes echook dump the last status-line stdin, but note that echook's own `hook_start` NDJSON event does **not** record raw stdin, so it cannot substitute for a shim when you need payload fields.

---

## Findings

### `Stop` carries an undocumented `background_tasks` array

Not in the upstream field list. Observed on Claude Code 2.1.215:

```json
{
  "hook_event_name": "Stop",
  "stop_hook_active": false,
  "session_crons": [],
  "background_tasks": [
    {"id": "<opaque-id>", "type": "teammate", "status": "running", "description": "<agent task description>"},
    {"id": "<opaque-id>", "type": "shell",    "status": "running", "description": "<shell command description>"}
  ]
}
```

(Field shapes reproduced from a real capture; ids and descriptions replaced.)

`type` observed as `teammate` and `shell`; `status` observed as `running`. `session_crons` appears alongside it and was empty throughout.

**Why it matters.** `Stop` fires at the end of every turn and nothing in the payload marks a turn as final — but `background_tasks` does tell you whether work is still in flight. That is the closest available proxy for "the batch is finished". echook exposes it as `filters.stop.skip_if_background_tasks_running`. Across 12 real captured `Stop` payloads from a session driving 10–15 teammates, 11 had running tasks (suppressed) and 1 did not (played).

Treat the field as best-effort: it is undocumented, so it may change shape or disappear. The filter reads it defensively and no-ops when it is absent, which is also what happens under Cursor and Codex.

### `agent_completed` and `agent_needs_input` do not fire for local subagents

`Notification` documents eight `notification_type` values. Two of them — `agent_needs_input` and `agent_completed`, both added in Claude Code v2.1.198 — did not fire at all during capture.

| Captured over several concurrent sessions, Claude Code 2.1.215 | Count |
|---|--:|
| `Stop` | 17 |
| `SubagentStop` | 14 |
| `Notification` / `idle_prompt` | 6 |
| `SessionEnd` | 1 |
| `Notification` / `agent_completed` | **0** |
| `Notification` / `agent_needs_input` | **0** |

Captured via a catch-all matcher, with `inputNeededNotifEnabled` and `agentPushNotifEnabled` both `true` in settings.

**Fourteen subagent completions producing zero `agent_completed` establishes that it is not a `Task`-tool subagent signal.** The naming of the two settings that gate it (`agentPushNotifEnabled`) suggests it belongs to the push-notification path for background or remote agents. Unconfirmed.

**Consequence for echook:** both are registered for completeness and forward compatibility, both ship `default: false`, and neither is presented to users as a working "task finished" cue. If you are asked for that cue, recommend `notification` / `idle_prompt` or the `background_tasks` filter instead.

### `idle_prompt` is the real "waiting for you" signal

Fires with `message: "Claude is waiting for your input"` when a session is genuinely parked on the user — not on every turn boundary. Payload keys observed: `session_id`, `transcript_path`, `cwd`, `prompt_id`, `hook_event_name`, `notification_type`, `message`.

This, not `Stop`, is what users mean when they ask for a "task done" sound.

### `Stop` is per-turn and has no finality marker

Confirmed by both the upstream docs ("fires at the end of each turn… not when the session ends") and by capture: 17 `Stop` events across normal working turns. `stop_hook_active` was `false` throughout and denotes re-entrancy, not finality. Use `SessionEnd` for genuine session termination.

### `settings.json` hot-reloads hook registrations

Adding a `hooks` block took effect on the next event with no restart. Useful for capture work; also means a session can pick up registration changes mid-flight.

### Sibling config directories can share `settings.json`

Not a Claude Code behaviour as such, but it bit this investigation: a multi-account setup using `CLAUDE_CONFIG_DIR` may symlink `settings.json` between config dirs, so hook registrations are shared while plugin *data* (`user_preferences.json`) stays per-directory. Check with `realpath` before assuming two accounts are independent — a capture registered for one account will observe both.

### `SessionStart` gained a `fork` source, and echook was silent for it

Claude Code 2.1.213: *"Changed SessionStart hooks to report source `"fork"` when a session begins as a fork instead of `"resume"`."*

Extracted from the 2.1.239 binary — the union is closed, not free-form:

```
SessionStart"),source:Or(["startup","resume","clear","compact","fork"])
```

echook registered the first four. Forked sessions used to land on `resume` and
made a sound; after 2.1.213 they report `fork`, matched nothing, and went
**completely silent**. Nothing failed and nothing logged — the registration was
simply never invoked. Fixed in v6.4.1.

This is the archetype for the drift this file exists to catch: the *event* name
never changed, so no contract test could have noticed. Only the set of values a
matcher can take moved underneath us.

### `StopFailure` has eleven error types; `other` was never one of them

Union from the same binary:

```
["authentication_failed","oauth_org_not_allowed","account_on_hold","billing_error",
 "rate_limit","overloaded","invalid_request","model_not_found","server_error",
 "unknown","max_output_tokens"]
```

Before v6.4.1 echook collapsed six of these onto a single handler registered as
`stop_failure_other`. Two consequences, both invisible from the outside:

- `other` is **not** a Claude Code value (zero occurrences in the binary), so
  the arg named a matcher that could never be emitted.
- Because `is_hook_enabled` received `stop_failure_other` as the variant,
  setting `enabled_hooks.stop_failure_billing_error` had **no effect at all** —
  while `hooks list --variants` and the manifest advertised all five collapsed
  types as independently switchable.

v6.4.1 registers one handler per real type and drops `other`. Claude Code's own
bucketing of these types is a useful guide for choosing sounds: auth
(`authentication_failed`, `oauth_org_not_allowed`, `account_on_hold`), billing
(`billing_error`), model-unavailable (`model_not_found`), and the rest
transient.

### `"async": true` discards the hook's stdout — `terminalSequence` never fires

**Measured on Claude Code 2.1.251, Windows 11, 2026-09-01.** This is the
constraint that makes v6.5.0's `terminalSequence` inert: all 67 handlers in
`plugins/audio-hooks/hooks/hooks.json` are declared `"async": true`.

One shim script registered on `PreToolUse` matcher `Glob` in
`~/.claude/settings.json`, printing
`{"terminalSequence":"\u001b]2;PROBE-<phase>-<ms>\u0007"}` (OSC 2, set window
title) and logging its own invocations. A second process polled
`[Console]::Title` every 5 ms. Same script, same event, same payload — only the
`async` field differed between phases:

| phase | invocations | OSC reached the terminal |
|---|---|---|
| `"async": true` | 3 | 0 |
| sync (no `async`) | 2 | 2, within ~28 ms |

The hook ran in both phases (`stdin_bytes=568` — a real hook payload), which is
what rules out a registration failure rather than a stdout failure. Two
incidental confirmations: `settings.json` hook registration hot-reloads with no
restart, and Claude Code writes OSC 2 titles itself (the console title during
the run was `◐ <branch-name>`).

**Why, from the 2.1.251 binary.** `Ege()` is the only function that writes an
escape to the terminal, and its only caller is
`jie(e,t){if(!e||!_p(e)||!e.terminalSequence)return;…Ege(vge(e.terminalSequence))}`.
`jie` has four call sites, all on **synchronous** result paths (command-hook
stdout, HTTP, MCP, callback), e.g. `let{json:Ke,…}=I0e(We.stdout);…jie(Ke,O);`.
A config-async hook never reaches them — it returns before stdout is collected:

    if((e.async||e.asyncRewake&&bn)&&!B){…
      if(Kxt({…asyncResponse:{async:!0,asyncTimeout:nn}…}))
        return{stdout:"",stderr:"",output:"",status:0,backgrounded:!0}}

so `jie` is later handed `I0e("")` → no JSON → immediate return.

The backgrounded stdout is **not** discarded, it is delivered somewhere that
cannot reach the terminal. `Kxt`→`z2e` registers the process; `G2e` polls it and
on completion parses the first non-`async` JSON line via `j2e`; `DYn` wraps that
in an `async_hook_response` attachment. `terminalSequence` **is** in the
hook-output schema (`terminalSequence:i().optional().describe("A terminal escape
sequence …")`), so `j2e` validates and preserves it — and then the attachment
renderer reads only two fields:

    case"async_hook_response":{…"systemMessage"in d?…;
      …"hookSpecificOutput"…additionalContext…;return hs(u)}

The field is carried the whole way and dropped at the last step. That makes this
an upstream oversight, not a deliberate design: a single `jie(o,d)` inside
`DYn`'s map would make async `terminalSequence` work. An issue is drafted but
**not filed** as of 6.5.1.

**What a backgrounded hook can still deliver:** `systemMessage`,
`hookSpecificOutput.additionalContext`, `metrics`, and — with `asyncRewake` —
exit code 2. **Not** `terminalSequence`, `decision`, `continue`, or
`permissionDecision`. The published docs' blanket *"doesn't read its stdout"* is
correct for terminal purposes and slightly overstated in general.

**What 6.5.1 does about it:** `audio-hooks diagnose` reports
`TERMINAL_SEQUENCE_INERT` when the flag is on and points at the desktop-toast
channel instead. The code is unchanged and the feature is not silently removed.

**Fix shape, if it is ever built.** The emitting handler must be synchronous.
[`claude-plugins-official#351`](https://github.com/anthropics/claude-plugins-official/issues/351)'s
Windows startup-hang argument does **not** cover these events — none of the 9
`TERMINAL_SEQUENCE_SAFE_EVENTS` is a startup event, and `SessionStart`/`Setup`
are in `TERMINAL_SEQUENCE_FORBIDDEN_EVENTS` either way. The honest cost is
per-turn latency: a Python spawn on `Stop` and `Notification` for every install,
serving a feature that is off by default. So do not flip the 38 existing
handlers on those 9 events (`Notification` 16, `StopFailure` 11, `SessionEnd` 5,
one each for `Stop`, `PermissionRequest`, `PermissionDenied`, `SubagentStop`,
`TaskCompleted`, `TeammateIdle`). Register instead a **second, sync, minimal
handler** beside each async audio handler, whose only job is to check
`terminal_sequence.enabled`, write the one JSON line, and exit — the audio path
keeps async and its Windows safety, and only the opt-in escape pays the sync
cost. Two constraints: gate it Claude-Code-only by invoker, since Cursor runs
all matching hooks from every source without de-duplicating; and make the
`SessionEnd` one the cheapest of the set, since `SessionEnd` hooks share a 1.5 s
budget.

### `PreModelSwitch` is a blocking gate, not a notification — do not register it

Claude Code 2.1.251 added `PreModelSwitch` and `PostModelSwitch`. The changelog
describes them as *"block, confirm, or annotate a model switch"*, and the first
verb is the whole story. Extracted from the 2.1.251 binary:

```
p({hookEventName:N("PreModelSwitch"),
   permissionDecision:ie(["allow","deny","ask"]).optional()
     .describe("Same contract as PreToolUse: allow proceeds (skipping the
      interactive cache-miss confirm), deny cancels the switch, ask asks the
      user to confirm (a headless session refuses instead)"),
   permissionDecisionReason:i().optional()})
```

and, from the same binary, the user-visible consequences of getting it wrong:

```
model switch blocked by a PreModelSwitch hook
Model switch blocked by a PreModelSwitch hook: confirmation required, and this session cannot ask
A PreModelSwitch hook asked you to confirm
PreModelSwitch hooks did not complete:
... did not respond before its timeout
Fast mode was not changed: the PreModelSwitch check failed
Fast mode was not enabled: the model changed while PreModelSwitch hooks ran; try again
plugin hooks could not be loaded, so PreModelSwitch hooks could not be checked
```

Claude Code **waits** for `PreModelSwitch` and treats a non-answer as a failure
mode worth six distinct error strings. That is the same shape as `WorktreeCreate`
in v6.3.4: an event whose name reads like a notification and whose contract makes
the hook responsible for an outcome. echook has nothing to contribute to a model
switch except a sound, and a sound is not worth sitting in the path of `/model`
and fast-mode promotion.

**`PreModelSwitch` will not be registered. `PostModelSwitch` is cleared for a
later release but is not registered in 6.5.1** — 6.5.1 is a fix release and adds
no capability, and a new event needs its own sound in both themes, which needs an
ElevenLabs regeneration run. Everything needed to add it is here.
`PostModelSwitch`'s only output field is `additionalContext`, it is not waited on
for a decision, and it carries the same payload:

```
from_model, to_model, requested_model (nullable), source, context_tokens
source union — PreModelSwitch:  ["command","picker","sdk"]
               PostModelSwitch: ["command","picker","sdk","auto","resume"]
```

When `PostModelSwitch` is added, `PreModelSwitch` must go into
`TERMINAL_SEQUENCE_FORBIDDEN_EVENTS` alongside `MessageDisplay` and the
`Elicitation` pair, for the same reason they are there: its stdout is read as an
answer on the user's behalf.

### The `args` exec form is broken on Windows — keep the shell form

2.1.251's command-hook schema offers an exec form that would remove echook's
entire Windows quoting risk class in one move:

> `args` — *"Argument list for exec form. When present, `command` is resolved as
> an executable and spawned directly with these arguments — no shell. Path
> placeholders like `${CLAUDE_PLUGIN_ROOT}` are substituted per-element as plain
> strings, so paths with quotes, `$`, or backticks never reach a shell parser.
> When absent, `command` runs through a shell (bash on POSIX, PowerShell on
> Windows without Git Bash)."*

Do not adopt it yet. [anthropics/claude-code#90495](https://github.com/anthropics/claude-code/issues/90495)
(open, `platform:windows`) reports the exec form being dropped on Windows and
still routed through `bash.exe` with no argv, breaking all 48 of a reporter's
converted hooks. Windows is this project's primary development platform, so the
shell form stays until that issue closes.

Two neighbouring fields, for the record. `shell` accepts `"bash"` or
`"powershell"` and *"Defaults to bash, or to powershell on Windows when Git Bash
isn't installed"* — but 2.1.251 does not silently fall back for a hook written
for bash; it refuses with *"requires bash but Git Bash was not found. Install Git
for Windows … or add `\"shell\": \"powershell\"` to this hook's config."* That is
loud, and it takes every handler down at once, which is why `diagnose` gained
`WINDOWS_NO_GIT_BASH`. And `commandWindows` is not a real field —
[#90122](https://github.com/anthropics/claude-code/issues/90122) confirms it was
never implemented and is silently ignored, which the Codex template already says.

### Re-verified against 2.1.251: the unions did not move

The whole investigation behind 6.5.1 started from "Claude Code broke the hooks."
It had not. Extracted from the 2.1.251 binary and compared against what v6.5.0
registers:

| Contract | 2.1.251 | Verdict |
|---|---|---|
| `SessionStart.source` | `["startup","resume","clear","compact","fork"]` | unchanged since 2.1.239 |
| `Notification.notification_type` | 14 values, `permission_prompt` … `quota_auto_resume_disabled` | unchanged; echook registers all 14 |
| `Notification` payload | `{message, title?, notification_type}` | unchanged — echook reads `message` |
| `StopFailure.error_type` | 11 values | unchanged |
| `Stop` payload | `stop_hook_active`, `last_assistant_message`, `background_tasks` | unchanged, now *documented* |
| plugin `hooks/hooks.json` discovery | *"The standard hooks/hooks.json is loaded automatically"* | unchanged, undeprecated |
| `async` / `timeout` hook fields | still in the command-hook schema | unchanged |

Two corrections to what the published docs say, in echook's favour:

- **`Stop`'s `background_tasks` and `last_assistant_message` are no longer
  undocumented.** The 2.1.239 note above called `background_tasks` absent from
  the upstream field list; at 2.1.251 both are in the schema with descriptions,
  `background_tasks` explicitly framed as *"Lets hooks distinguish 'session is
  done' from 'session is paused waiting for background work'"* — which is what
  `filters.stop.skip_if_background_tasks_running` already does with it.
- **Four `Notification` matchers echook registers are absent from the docs but
  present in the binary**: `worker_permission_prompt`, `push_notification`,
  `computer_use_enter`, `computer_use_exit`. They are in the closed
  `notification_type` union at 2.1.251. The documentation is behind, not echook.

Also: the hooks reference moved. `docs.claude.com/en/docs/claude-code/hooks` now
301-redirects to [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks).

### New gates that skip hooks entirely, none of which fired here

Worth knowing, because each produces total silence with no error in the plugin:

- **Workspace trust.** `hooksSkippedForTrust: () => !isWorkspaceTrusted()`, and
  every hook call site short-circuits with `Skipping <event> hook execution -
  workspace trust not accepted`. The status line and `subagentStatusLine` are
  skipped by the same gate. `hasTrustDialogAccepted` per project lives in
  `~/.claude.json`.
- **`disableAllHooks`** (user or managed), **`allowManagedHooksOnly`**, and
  `--bare`, which reports `hooks are disabled in this mode (--bare)`.
- **`SessionEnd` hooks share a 1.5-second budget**, raised only to match a longer
  per-hook `timeout` up to 60 s. Combined with Windows killing an async hook's
  **process tree** at session end, a `session_end` sound can be cut off or never
  start. Do not present `session_end` as a reliable cue on Windows.

### Cursor's `stop` *does* carry finality; Claude Code's does not

The rule that `stop` cannot mean "task complete" is a **Claude Code** fact and
must not be generalised. Cursor's `stop` payload carries `status`
(`completed` / `aborted` / `error`) and `loop_count`, per
[cursor.com/docs/hooks](https://cursor.com/docs/hooks). On Cursor you can at
minimum give aborted and errored turns a different sound, or mute them.

Sibling payload fields worth knowing on Cursor: `sessionEnd.reason`
(`completed|aborted|error|window_close|user_close`), and `subagentStop`'s
`status` / `duration_ms` / `tool_call_count` / `modified_files[]` / `summary` —
that `summary` is a ready-made spoken notification with no transcript parsing.

### Cursor bridges Claude Code hooks without de-duplicating

[cursor.com/docs/reference/third-party-hooks](https://cursor.com/docs/reference/third-party-hooks):
*"All matching hooks from every source run. When responses conflict,
higher-priority sources take precedence during merge."*

Priority decides whose *verdict* wins, not whether a duplicate side effect
executes — and playing a sound is a side effect, not a verdict. So the native
`--cursor` install genuinely double-fires alongside the bridged plugin, and
`DUPLICATE_BRIDGE` is load-bearing. The user-facing toggle (Settings → Rules,
Skills, Subagents → "Include third-party Plugins, Skills, and other configs")
has **no effect on `cursor-agent`**, where bridging is hardcoded, so on the CLI
the abort is the only defence available.

### Windows: Cursor mis-executes bridged Claude Code hooks

Reported on the Cursor forum and acknowledged by staff (2026-07-29): hooks
imported from Claude Code are composed as PowerShell but executed with bash,
which silently blocks every tool call. Relevant to this project specifically,
since Windows is its primary development platform.

---

## Matcher coverage as of v6.4.1

44 variants across 8 matcher-scoped events.

| Event | Matchers registered | Notes |
|---|---|---|
| `Notification` | 8 of the 14 typed values | 4 added in v6.4; `agent_*` pair unverified (above). The six unregistered types — `elicitation_url_dialog`, `worker_permission_prompt`, `push_notification`, `computer_use_enter`/`_exit`, `quota_auto_resume_fired`/`_stale`/`_disabled` — still reach the catch-all, but share one sound with no per-variant toggle. `notification_type` is a bare string in the payload, not an enum, so unknown values are expected |
| `SessionEnd` | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled\|other` | first four were dead code until v6.4 — defined in `SYNTHETIC_EVENT_MAP` but the event was registered with no matcher, so nothing invoked them. `bypass_permissions_disabled` is not a real upstream value; it is a harmless dead alternation kept only so the group still matches `other` |
| `SessionStart` | `startup`, `resume`, `clear`, `compact`, **`fork`** | `fork` added in v6.4.1 — see above; forked sessions were silent from Claude Code 2.1.213 until then |
| `StopFailure` | **all 11 upstream types, one handler each** | v6.4.1 unwound the five-way collapse onto `stop_failure_other` and dropped `other`, which was never a Claude Code value. Every variant toggle now actually works; the contract-test allowlist is empty as a result |
| `PreCompact` / `PostCompact` / `Setup` | both/both/both | |
| `PermissionRequest` | `""` (catch-all) | |

`Notification` and `PermissionRequest` have no Cursor or Codex equivalent; the runner hard-skips them for those invokers regardless of registration.
