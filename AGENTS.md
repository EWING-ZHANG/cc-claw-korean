# AGENTS.md

This repository is a fork of `ultraworkers/claw-code-parity` with local additions for:

- OpenAI-compatible domestic models such as Qwen
- `openai/codex-plugin-cc` installation and compatibility
- automatic Codex delegation from the main chat loop
- clearer remote-server workflows through the built-in `bash` tool

## Working Directory

- Main Rust workspace: `rust/`
- Main CLI crate: `rust/crates/rusty-claude-cli`
- Runtime prompt assembly: `rust/crates/runtime/src/prompt.rs`
- Provider/model routing: `rust/crates/api/src/providers/mod.rs`
- Plugin bridge: `rust/crates/plugins/src/lib.rs`

Do most build, test, and runtime commands from `rust/`.

## Git Remotes

- `origin` should point to the maintained fork for this workspace.
- `upstream` should point to `https://github.com/ultraworkers/claw-code-parity.git`.

Keep local feature work pushable to `origin`, and pull from `upstream` when syncing parity changes.

## Current Fork-Specific Behavior

### OpenAI-compatible models

- If `OPENAI_API_KEY` or `OPENAI_BASE_URL` is set, the CLI defaults to `qwen3-coder-next`.
- Supported shorthand aliases include:
  - `qwen-coder`
  - `qwen-coder-plus`
  - `qwen-coder-next`
- Windows helper script:
  - `rust/start-qwen-compatible.ps1`

Recommended launch:

```powershell
cd rust
$env:DASHSCOPE_API_KEY="your-key"
powershell -ExecutionPolicy Bypass -File .\start-qwen-compatible.ps1 -Release
```

### Codex plugin + automatic delegation

- `openai/codex-plugin-cc` can be installed directly from the repo root URL.
- Once the `codex` plugin is installed and enabled, the main assistant exposes internal delegation tools so the front model can ask Codex to implement, test, or review without requiring manual `/codex:*` commands every time.
- Manual plugin commands still work and are useful for smoke checks:
  - `/plugin list`
  - `/codex:setup`
  - `/codex:status`

### Remote server workflows

- The assistant is expected to use the built-in `bash` tool for `ssh`, `scp`, and `rsync` when the user asks to work on a remote machine.
- Bare shell-style inputs such as `ssh ubuntu@example.com` should be interpreted as action requests when the intent is clear.
- Prefer non-interactive SSH commands whenever possible.
- For unattended work, SSH key auth is strongly preferred over password prompts.

## Local Runtime Notes

- Local plugin state is stored under `rust/.claw/`.
- Do not commit `.claw/` runtime artifacts.
- Release binary path:
  - `rust/target/release/claw.exe`

## Build And Test

Recommended validation:

```powershell
cd rust
cargo fmt --all
cargo test -p rusty-claude-cli -- --nocapture
cargo build --release -p rusty-claude-cli
```

Notes:

- Some workspace tests under `runtime` are Unix-specific and may fail on Windows test targets even when the main CLI build is healthy.
- For this fork, the `rusty-claude-cli` test suite is the most important Windows verification surface.

## Development Workflow For Codex

1. Read `README.md`, this `AGENTS.md`, and the relevant Rust crate before editing.
2. Keep changes scoped to the fork-specific behavior being modified.
3. If changing provider selection, model aliases, or prompt assembly, verify with `cargo test -p rusty-claude-cli`.
4. If changing plugin integration, also smoke check:
   - `.\target\release\claw.exe "/plugin list"`
   - `.\target\release\claw.exe "/codex:setup"`
5. If changing system prompt guidance, inspect:
   - `.\target\release\claw.exe system-prompt --cwd .`
6. If changing remote-operation behavior, test with a clear natural-language prompt instead of only slash commands.

## Suggested User Prompts

Design-first with automatic Codex handoff:

```text
Design the change yourself, then have Codex implement it, run tests, and report back.
```

Remote-server task:

```text
Connect to ubuntu@162.14.100.101, inspect /home/ubuntu/ewing/SentenceStudio, make the requested change, run the relevant tests, and report back.
```

## Avoid

- Do not commit `.claw/` state, local credentials, or session artifacts.
- Do not assume Anthropic auth is configured when running Qwen/OpenAI-compatible flows.
- Do not rely on interactive password prompts for automated remote tasks if a non-interactive route is possible.
