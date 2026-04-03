# 🦞 Claw Code — Rust Implementation

A high-performance Rust rewrite of the Claw Code CLI agent harness. Built for speed, safety, and native tool execution.

## Quick Start

```bash
# Build
cd rust/
cargo build --release

# Run interactive REPL
./target/release/claw

# One-shot prompt
./target/release/claw prompt "explain this codebase"

# With specific model
./target/release/claw --model sonnet prompt "fix the bug in main.rs"

# With DashScope / Qwen
OPENAI_API_KEY=your-key OPENAI_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1 ./target/release/claw --model qwen-coder prompt "review this Rust project"
```

## Configuration

Set your API credentials:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
# Or use a proxy
export ANTHROPIC_BASE_URL="https://your-proxy.com"
```

Or use an OpenAI-compatible domestic model endpoint such as DashScope:

```bash
export OPENAI_API_KEY="your-dashscope-or-openai-compatible-key"
export OPENAI_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
export OPENAI_MODEL="qwen3-coder-next"
```

Or use Baidu Qianfan Coding Plan through its Anthropic-compatible endpoint:

```bash
export ANTHROPIC_AUTH_TOKEN="your-qianfan-coding-plan-key"
export ANTHROPIC_BASE_URL="https://qianfan.baidubce.com/anthropic/coding"
export ANTHROPIC_MODEL="qianfan-code-latest"
```

Or authenticate via OAuth:

```bash
claw login
```

## Features

| Feature | Status |
|---------|--------|
| Anthropic API + streaming | ✅ |
| OAuth login/logout | ✅ |
| Interactive REPL (rustyline) | ✅ |
| Tool system (bash, read, write, edit, grep, glob) | ✅ |
| Web tools (search, fetch) | ✅ |
| Sub-agent orchestration | ✅ |
| Todo tracking | ✅ |
| Notebook editing | ✅ |
| CLAUDE.md / project memory | ✅ |
| Config file hierarchy (.claude.json) | ✅ |
| Permission system | ✅ |
| MCP server lifecycle | ✅ |
| Session persistence + resume | ✅ |
| Extended thinking (thinking blocks) | ✅ |
| Cost tracking + usage display | ✅ |
| Git integration | ✅ |
| Markdown terminal rendering (ANSI) | ✅ |
| Model aliases (opus/sonnet/haiku) | ✅ |
| OpenAI-compatible models (Qwen / GLM / Kimi / DeepSeek families) | ✅ |
| Slash commands (/status, /compact, /clear, etc.) | ✅ |
| Hooks (PreToolUse/PostToolUse) | 🔧 Config only |
| Claude-style plugin install/list | ✅ |
| `openai/codex-plugin-cc` compatibility (`/codex:setup`, `/codex:status`, `/codex:review`, `/codex:rescue`) | ✅ |
| Skills registry | 📋 Planned |

## Model Aliases

Short names resolve to the latest model versions:

| Alias | Resolves To |
|-------|------------|
| `opus` | `claude-opus-4-6` |
| `sonnet` | `claude-sonnet-4-6` |
| `haiku` | `claude-haiku-4-5-20251213` |
| `qianfan-code` | `qianfan-code-latest` |
| `qianfan-code-latest` | `qianfan-code-latest` |
| `qwen-coder` | `qwen3-coder-next` |
| `qwen-coder-plus` | `qwen3-coder-plus` |
| `qwen-coder-next` | `qwen3-coder-next` |

If `OPENAI_API_KEY` or `OPENAI_BASE_URL` is set and no explicit model is passed, the CLI now defaults to `qwen3-coder-next`.

If `ANTHROPIC_BASE_URL` points to Baidu Qianfan Coding Plan and no explicit model is passed, the CLI now defaults to `qianfan-code-latest`.

## DashScope Helper Script

On Windows, you can launch the CLI against DashScope/Qwen with:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-qwen-compatible.ps1 --version
```

The helper script accepts `OPENAI_API_KEY`, `DASHSCOPE_API_KEY`, or `BAILIAN_API_KEY`, maps them to the CLI's OpenAI-compatible provider, and defaults to:

- Base URL: `https://dashscope.aliyuncs.com/compatible-mode/v1`
- Model: `qwen3-coder-next`

## Qianfan Coding Plan Helper Script

On Windows, you can launch the CLI against Baidu Qianfan Coding Plan with:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-qianfan-coding.ps1 --version
```

The helper script accepts `ANTHROPIC_AUTH_TOKEN`, `QIANFAN_API_KEY`, `QIANFAN_CODING_API_KEY`, `BAIDU_QIANFAN_API_KEY`, or `BCE_QIANFAN_API_KEY`, maps them to the CLI's Anthropic-compatible provider, and defaults to:

- Base URL: `https://qianfan.baidubce.com/anthropic/coding`
- Model: `qianfan-code-latest`

Use the full Coding Plan key value as the bearer token, for example `bce-v3/...`, instead of splitting it into separate `AK/SK` headers. This was verified against the live `https://qianfan.baidubce.com/anthropic/coding/v1/messages` endpoint with the current official auth flow.

This matches Baidu's official Coding Plan documentation for Anthropic-compatible tools. According to the current official docs, the Anthropic-compatible base URL is `https://qianfan.baidubce.com/anthropic/coding`, the full messages endpoint is `https://qianfan.baidubce.com/anthropic/coding/v1/messages`, and `qianfan-code-latest` is the recommended default model name. Official docs:

- [Coding Plan](https://cloud.baidu.com/doc/qianfan/s/imlg0beiu)
- [Claude Code 接入指南](https://cloud.baidu.com/doc/qianfan/s/0mn2mnemj)

The same official docs also list these currently supported model IDs for Coding Plan configuration:

- `qianfan-code-latest`
- `kimi-k2.5`
- `deepseek-v3.2`
- `glm-5`
- `minimax-m2.5`

## Codex Plugin Compatibility

Claw can now install the official `openai/codex-plugin-cc` repository root directly, resolve the nested `codex` plugin automatically, and run its primary slash commands without Claude Code:

```powershell
.\target\release\claw.exe "/plugin install https://github.com/openai/codex-plugin-cc.git"
.\target\release\claw.exe "/codex:setup"
.\target\release\claw.exe "/codex:status"
```

Supported `codex-plugin-cc` commands currently include:

- `/codex:setup`
- `/codex:status`
- `/codex:result`
- `/codex:cancel`
- `/codex:review`
- `/codex:adversarial-review`
- `/codex:rescue`

When the `codex` plugin is installed and enabled, the interactive assistant can also delegate to Codex automatically during a normal conversation through two runtime tools:

- `codex_delegate`
- `codex_review`

This means you can stay in the same chat and ask for a design-first workflow such as:

```text
Design the change yourself, then have Codex implement it, run tests, and report back.
```

Claw will expose the delegation tools to the current model and append guidance to the system prompt so the main assistant can decide when to hand off implementation or review work to Codex without requiring you to type `/codex:*` manually.

Notes:

- Claw adds a Windows-friendly Node.js path fallback so the plugin can still find `node`, `npm`, and `codex` when they are installed but missing from the active shell `PATH`.
- The plugin's optional stop-time review gate metadata can be stored by `/codex:setup`, but Claw does not yet emulate Claude Code's full stop-hook lifecycle.

## Remote Server Workflows

Claw already includes the built-in `bash` tool, so the assistant can connect to remote servers and work there through normal chat turns when the current permission mode allows shell commands.

For example, after starting the REPL, you can say:

```text
Connect to ubuntu@162.14.100.101, inspect /home/ubuntu/ewing/SentenceStudio, make the requested code changes there, run the relevant tests, and report back.
```

You can also paste a bare shell-style line such as:

```text
ssh ubuntu@162.14.100.101
```

and Claw's system prompt now instructs the model to interpret that as an action request and use the `bash` tool rather than treating it like ordinary chat text when the intent is clear.

For reliable unattended remote work, prefer SSH key auth or non-interactive helper scripts over password prompts.

## CLI Flags

```
claw [OPTIONS] [COMMAND]

Options:
  --model MODEL                    Set the model (alias or full name)
  --dangerously-skip-permissions   Skip all permission checks
  --permission-mode MODE           Set read-only, workspace-write, or danger-full-access
  --allowedTools TOOLS             Restrict enabled tools
  --output-format FORMAT           Output format (text or json)
  --version, -V                    Print version info

Commands:
  prompt <text>      One-shot prompt (non-interactive)
  login              Authenticate via OAuth
  logout             Clear stored credentials
  init               Initialize project config
  doctor             Check environment health
  self-update        Update to latest version
```

## Slash Commands (REPL)

Tab completion now expands not just slash command names, but also common workflow arguments like model aliases, permission modes, and recent session IDs.

| Command | Description |
|---------|-------------|
| `/help` | Show help |
| `/status` | Show session status (model, tokens, cost) |
| `/cost` | Show cost breakdown |
| `/compact` | Compact conversation history |
| `/clear` | Clear conversation |
| `/model [name]` | Show or switch model |
| `/permissions` | Show or switch permission mode |
| `/config [section]` | Show config (env, hooks, model) |
| `/memory` | Show CLAUDE.md contents |
| `/diff` | Show git diff |
| `/export [path]` | Export conversation |
| `/session [id]` | Resume a previous session |
| `/version` | Show version |

## Workspace Layout

```
rust/
├── Cargo.toml              # Workspace root
├── Cargo.lock
└── crates/
    ├── api/                # Anthropic API client + SSE streaming
    ├── commands/           # Shared slash-command registry
    ├── compat-harness/     # TS manifest extraction harness
    ├── runtime/            # Session, config, permissions, MCP, prompts
    ├── rusty-claude-cli/   # Main CLI binary (`claw`)
    └── tools/              # Built-in tool implementations
```

### Crate Responsibilities

- **api** — HTTP client, SSE stream parser, request/response types, auth (API key + OAuth bearer)
- **commands** — Slash command definitions and help text generation
- **compat-harness** — Extracts tool/prompt manifests from upstream TS source
- **runtime** — `ConversationRuntime` agentic loop, `ConfigLoader` hierarchy, `Session` persistence, permission policy, MCP client, system prompt assembly, usage tracking
- **rusty-claude-cli** — REPL, one-shot prompt, streaming display, tool call rendering, CLI argument parsing
- **tools** — Tool specs + execution: Bash, ReadFile, WriteFile, EditFile, GlobSearch, GrepSearch, WebSearch, WebFetch, Agent, TodoWrite, NotebookEdit, Skill, ToolSearch, REPL runtimes

## Stats

- **~20K lines** of Rust
- **6 crates** in workspace
- **Binary name:** `claw`
- **Default model:** `claude-opus-4-6`
- **Default permissions:** `danger-full-access`

## License

See repository root.
