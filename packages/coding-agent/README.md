<p align="center">
  <a href="https://pi.dev">
    <img src="https://pi.dev/logo.svg" alt="pi logo" width="128">
  </a>
</p>
<p align="center">
  <a href="https://discord.com/invite/3cU7Bz4UPx"><img alt="Discord" src="https://img.shields.io/badge/discord-community-5865F2?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://www.npmjs.com/package/@mariozechner/pi-coding-agent"><img alt="npm" src="https://img.shields.io/npm/v/@mariozechner/pi-coding-agent?style=flat-square" /></a>
  <a href="https://github.com/badlogic/pi-mono/actions/workflows/ci.yml"><img alt="Build status" src="https://img.shields.io/github/actions/workflow/status/badlogic/pi-mono/ci.yml?style=flat-square&branch=main" /></a>
</p>
<p align="center">
  <a href="https://pi.dev">pi.dev</a> domain graciously donated by
  <br /><br />
  <a href="https://exe.dev"><img src="docs/images/exy.png" alt="Exy mascot" width="48" /><br />exe.dev</a>
</p>

> New issues and PRs from new contributors are auto-closed by default. Maintainers review auto-closed issues daily. See [CONTRIBUTING.md](../../CONTRIBUTING.md).

---

Pi is a minimal terminal coding harness. Adapt pi to your workflows, not the other way around, without having to fork and modify pi internals. Extend it with TypeScript [Extensions](#extensions), [Skills](#skills), [Prompt Templates](#prompt-templates), and [Themes](#themes). Put your extensions, skills, prompt templates, and themes in [Pi Packages](#pi-packages) and share them with others via npm or git.

Pi ships with powerful defaults but skips features like sub agents and plan mode. Instead, you can ask pi to build what you want or install a third party pi package that matches your workflow.

Pi runs in four modes: interactive, print or JSON, RPC for process integration, and an SDK for embedding in your own apps. See [openclaw/openclaw](https://github.com/openclaw/openclaw) for a real-world SDK integration.

## Share your OSS coding agent sessions

If you use pi for open source work, please share your coding agent sessions.

Public OSS session data helps improve models, prompts, tools, and evaluations using real development workflows.

For the full explanation, see [this post on X](https://x.com/badlogicgames/status/2037811643774652911).

To publish sessions, use [`badlogic/pi-share-hf`](https://github.com/badlogic/pi-share-hf). Read its README.md for setup instructions. All you need is a Hugging Face account, the Hugging Face CLI, and `pi-share-hf`.

You can also watch [this video](https://x.com/badlogicgames/status/2041151967695634619), where I show how I publish my `pi-mono` sessions.

I regularly publish my own `pi-mono` work sessions here:

- [badlogicgames/pi-mono on Hugging Face](https://huggingface.co/datasets/badlogicgames/pi-mono)

## Table of Contents

- [Quick Start](#quick-start)
- [Providers & Models](#providers--models)
- [Interactive Mode](#interactive-mode)
  - [Editor](#editor)
  - [Commands](#commands)
  - [Keyboard Shortcuts](#keyboard-shortcuts)
  - [Message Queue](#message-queue)
- [Sessions](#sessions)
  - [Branching](#branching)
  - [Compaction](#compaction)
- [Settings](#settings)
- [Context Files](#context-files)
- [Customization](#customization)
  - [Prompt Templates](#prompt-templates)
  - [Skills](#skills)
  - [Extensions](#extensions)
  - [Themes](#themes)
  - [Pi Packages](#pi-packages)
- [Programmatic Usage](#programmatic-usage)
- [Philosophy](#philosophy)
- [CLI Reference](#cli-reference)

---

## Quick Start

```bash
npm install -g @mariozechner/pi-coding-agent
```

Authenticate with an API key:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
pi
```

Or use your existing subscription:

```bash
pi
/login  # Then select provider
```

Then just talk to pi. By default, pi gives the model four tools: `read`, `write`, `edit`, and `bash`. The model uses these to fulfill your requests. Add capabilities via [skills](#skills), [prompt templates](#prompt-templates), [extensions](#extensions), or [pi packages](#pi-packages).

**Platform notes:** [Windows](docs/windows.md) | [Termux (Android)](docs/termux.md) | [tmux](docs/tmux.md) | [Terminal setup](docs/terminal-setup.md) | [Shell aliases](docs/shell-aliases.md)

---

## Providers & Models

For each built-in provider, pi maintains a list of tool-capable models, updated with every release. Authenticate via subscription (`/login`) or API key, then select any model from that provider via `/model` (or Ctrl+L).

**Subscriptions:**
- Anthropic Claude Pro/Max
- OpenAI ChatGPT Plus/Pro (Codex)
- GitHub Copilot
- Google Gemini CLI
- Google Antigravity

**API keys:**
- Anthropic
- OpenAI
- Azure OpenAI
- DeepSeek
- Google Gemini
- Google Vertex
- Amazon Bedrock
- Mistral
- Groq
- Cerebras
- Cloudflare Workers AI
- xAI
- OpenRouter
- Vercel AI Gateway
- ZAI
- OpenCode Zen
- OpenCode Go
- Hugging Face
- Fireworks
- Kimi For Coding
- MiniMax

See [docs/providers.md](docs/providers.md) for detailed setup instructions.

**Custom providers & models:** Add providers via `~/.pi/agent/models.json` if they speak a supported API (OpenAI, Anthropic, Google). For custom APIs or OAuth, use extensions. See [docs/models.md](docs/models.md) and [docs/custom-provider.md](docs/custom-provider.md).

---

## Interactive Mode

<p align="center"><img src="docs/images/interactive-mode.png" alt="Interactive Mode" width="600"></p>

The interface from top to bottom:

- **Startup header** - Shows shortcuts (`/hotkeys` for all), loaded AGENTS.md files, prompt templates, skills, and extensions
- **Messages** - Your messages, assistant responses, tool calls and results, notifications, errors, and extension UI
- **Editor** - Where you type; border color indicates thinking level
- **Footer** - Working directory, session name, total token/cache usage, cost, context usage, current model

The editor can be temporarily replaced by other UI, like built-in `/settings` or custom UI from extensions (e.g., a Q&A tool that lets the user answer model questions in a structured format). [Extensions](#extensions) can also replace the editor, add widgets above/below it, a status line, custom footer, or overlays.

### Editor

| Feature | How |
|---------|-----|
| File reference | Type `@` to fuzzy-search project files |
| Path completion | Tab to complete paths |
| Multi-line | Shift+Enter (or Ctrl+Enter on Windows Terminal) |
| Images | Ctrl+V to paste (Alt+V on Windows), or drag onto terminal |
| Bash commands | `!command` runs and sends output to LLM, `!!command` runs without sending |

Standard editing keybindings for delete word, undo, etc. See [docs/keybindings.md](docs/keybindings.md).

### Commands

Type `/` in the editor to trigger commands. [Extensions](#extensions) can register custom commands, [skills](#skills) are available as `/skill:name`, and [prompt templates](#prompt-templates) expand via `/templatename`.

| Command | Description |
|---------|-------------|
| `/login`, `/logout` | OAuth authentication |
| `/model` | Switch models |
| `/scoped-models` | Enable/disable models for Ctrl+P cycling |
| `/settings` | Thinking level, theme, message delivery, transport |
| `/resume` | Pick from previous sessions |
| `/new` | Start a new session |
| `/name <name>` | Set session display name |
| `/session` | Show session info (file, ID, messages, tokens, cost) |
| `/tree` | Jump to any point in the session and continue from there |
| `/fork` | Create a new session from a previous user message |
| `/clone` | Duplicate the current active branch into a new session |
| `/compact [prompt]` | Manually compact context, optional custom instructions |
| `/copy` | Copy last assistant message to clipboard |
| `/export [file]` | Export session to HTML file |
| `/share` | Upload as private GitHub gist with shareable HTML link |
| `/reload` | Reload keybindings, extensions, skills, prompts, and context files (themes hot-reload automatically) |
| `/hotkeys` | Show all keyboard shortcuts |
| `/changelog` | Display version history |
| `/quit` | Quit pi |

### Keyboard Shortcuts

See `/hotkeys` for the full list. Customize via `~/.pi/agent/keybindings.json`. See [docs/keybindings.md](docs/keybindings.md).

**Commonly used:**

| Key | Action |
|-----|--------|
| Ctrl+C | Clear editor |
| Ctrl+C twice | Quit |
| Escape | Cancel/abort |
| Escape twice | Open `/tree` |
| Ctrl+L | Open model selector |
| Ctrl+P / Shift+Ctrl+P | Cycle scoped models forward/backward |
| Shift+Tab | Cycle thinking level |
| Ctrl+O | Collapse/expand tool output |
| Ctrl+T | Collapse/expand thinking blocks |

### Message Queue

Submit messages while the agent is working:

- **Enter** queues a *steering* message, delivered after the current assistant turn finishes executing its tool calls
- **Alt+Enter** queues a *follow-up* message, delivered only after the agent finishes all work
- **Escape** aborts and restores queued messages to editor
- **Alt+Up** retrieves queued messages back to editor

On Windows Terminal, `Alt+Enter` is fullscreen by default. Remap it in [docs/terminal-setup.md](docs/terminal-setup.md) so pi can receive the follow-up shortcut.

Configure delivery in [settings](docs/settings.md): `steeringMode` and `followUpMode` can be `"one-at-a-time"` (default, waits for response) or `"all"` (delivers all queued at once). `transport` selects provider transport preference (`"sse"`, `"websocket"`, or `"auto"`) for providers that support multiple transports.

---

## Sessions

Sessions are stored as JSONL files with a tree structure. Each entry has an `id` and `parentId`, enabling in-place branching without creating new files. See [docs/session-format.md](docs/session-format.md) for file format.

### Management

Sessions auto-save to `~/.pi/agent/sessions/` organized by working directory.

```bash
pi -c                  # Continue most recent session
pi -r                  # Browse and select from past sessions
pi --no-session        # Ephemeral mode (don't save)
pi --session <path|id> # Use specific session file or ID
pi --fork <path|id>    # Fork specific session file or ID into a new session
```

Use `/session` in interactive mode to see the current session ID before reusing it with `--session <id>` or `--fork <id>`.

### Branching

**`/tree`** - Navigate the session tree in-place. Select any previous point, continue from there, and switch between branches. All history preserved in a single file.

<p align="center"><img src="docs/images/tree-view.png" alt="Tree View" width="600"></p>

- Search by typing, fold/unfold and jump between branches with Ctrl+←/Ctrl+→ or Alt+←/Alt+→, page with ←/→
- Filter modes (Ctrl+O): default → no-tools → user-only → labeled-only → all
- Press Shift+L to label entries as bookmarks and Shift+T to toggle label timestamps

**`/fork`** - Create a new session file from a previous user message on the active branch. Opens a selector, copies the active path up to that point, and places the selected prompt in the editor for modification.

**`/clone`** - Duplicate the current active branch into a new session file at the current position. The new session keeps the full active-path history and opens with an empty editor.

**`--fork <path|id>`** - Fork an existing session file or partial session UUID directly from the CLI. This copies the full source session into a new session file in the current project.

### Compaction

Long sessions can exhaust context windows. Compaction summarizes older messages while keeping recent ones.

**Manual:** `/compact` or `/compact <custom instructions>`

**Automatic:** Enabled by default. Triggers on context overflow (recovers and retries) or when approaching the limit (proactive). Configure via `/settings` or `settings.json`.

Compaction is lossy. The full history remains in the JSONL file; use `/tree` to revisit. Customize compaction behavior via [extensions](#extensions). See [docs/compaction.md](docs/compaction.md) for internals.

---

## Settings

Use `/settings` to modify common options, or edit JSON files directly:

| Location | Scope |
|----------|-------|
| `~/.pi/agent/settings.json` | Global (all projects) |
| `.pi/settings.json` | Project (overrides global) |

See [docs/settings.md](docs/settings.md) for all options.

To opt out of anonymous install/update telemetry tied to changelog detection, set `enableInstallTelemetry` to `false` in `settings.json`, or set `PI_TELEMETRY=0`.

---

## Context Files

Pi loads `AGENTS.md` (or `CLAUDE.md`) at startup from:
- `~/.pi/agent/AGENTS.md` (global)
- Parent directories (walking up from cwd)
- Current directory

Use for project instructions, conventions, common commands. All matching files are concatenated.

Disable context file loading with `--no-context-files` (or `-nc`).

### System Prompt

Replace the default system prompt with `.pi/SYSTEM.md` (project) or `~/.pi/agent/SYSTEM.md` (global). Append without replacing via `APPEND_SYSTEM.md`.

---

## Customization

### Prompt Templates

Reusable prompts as Markdown files. Type `/name` to expand.

```markdown
<!-- ~/.pi/agent/prompts/review.md -->
Review this code for bugs, security issues, and performance problems.
Focus on: {{focus}}
```

Place in `~/.pi/agent/prompts/`, `.pi/prompts/`, or a [pi package](#pi-packages) to share with others. See [docs/prompt-templates.md](docs/prompt-templates.md).

### Skills

On-demand capability packages following the [Agent Skills standard](https://agentskills.io). Invoke via `/skill:name` or let the agent load them automatically.

```markdown
<!-- ~/.pi/agent/skills/my-skill/SKILL.md -->
# My Skill
Use this skill when the user asks about X.

## Steps
1. Do this
2. Then that
```

Place in `~/.pi/agent/skills/`, `~/.agents/skills/`, `.pi/skills/`, or `.agents/skills/` (from `cwd` up through parent directories) or a [pi package](#pi-packages) to share with others. See [docs/skills.md](docs/skills.md).

### Extensions

<p align="center"><img src="docs/images/doom-extension.png" alt="Doom Extension" width="600"></p>

TypeScript modules that extend pi with custom tools, commands, keyboard shortcuts, event handlers, and UI components.

```typescript
export default function (pi: ExtensionAPI) {
  pi.registerTool({ name: "deploy", ... });
  pi.registerCommand("stats", { ... });
  pi.on("tool_call", async (event, ctx) => { ... });
}
```

The default export can also be `async`. pi waits for async extension factories before startup continues, which is useful for one-time initialization such as fetching remote model lists before calling `pi.registerProvider()`.

**What's possible:**
- Custom tools (or replace built-in tools entirely)
- Sub-agents and plan mode
- Custom compaction and summarization
- Permission gates and path protection
- Custom editors and UI components
- Status lines, headers, footers
- Git checkpointing and auto-commit
- SSH and sandbox execution
- MCP server integration
- Make pi look like Claude Code
- Games while waiting (yes, Doom runs)
- ...anything you can dream up

Place in `~/.pi/agent/extensions/`, `.pi/extensions/`, or a [pi package](#pi-packages) to share with others. See [docs/extensions.md](docs/extensions.md) and [examples/extensions/](examples/extensions/).

### Themes

Built-in: `dark`, `light`. Themes hot-reload: modify the active theme file and pi immediately applies changes.

Place in `~/.pi/agent/themes/`, `.pi/themes/`, or a [pi package](#pi-packages) to share with others. See [docs/themes.md](docs/themes.md).

### Pi Packages

Bundle and share extensions, skills, prompts, and themes via npm or git. Find packages on [npmjs.com](https://www.npmjs.com/search?q=keywords%3Api-package) or [Discord](https://discord.com/channels/1456806362351669492/1457744485428629628).

> **Security:** Pi packages run with full system access. Extensions execute arbitrary code, and skills can instruct the model to perform any action including running executables. Review source code before installing third-party packages.

```bash
pi install npm:@foo/pi-tools
pi install npm:@foo/pi-tools@1.2.3      # pinned version
pi install git:github.com/user/repo
pi install git:github.com/user/repo@v1  # tag or commit
pi install git:git@github.com:user/repo
pi install git:git@github.com:user/repo@v1  # tag or commit
pi install https://github.com/user/repo
pi install https://github.com/user/repo@v1      # tag or commit
pi install ssh://git@github.com/user/repo
pi install ssh://git@github.com/user/repo@v1    # tag or commit
pi remove npm:@foo/pi-tools
pi uninstall npm:@foo/pi-tools          # alias for remove
pi list
pi update                               # update pi and packages (skips pinned packages)
pi update --extensions                  # update packages only
pi update --self                        # update pi only
pi update --self --force                # reinstall pi even if current
pi update npm:@foo/pi-tools             # update one package
pi config                               # enable/disable extensions, skills, prompts, themes
```

Packages install to `~/.pi/agent/git/` (git) or global npm. Use `-l` for project-local installs (`.pi/git/`, `.pi/npm/`). Git packages install dependencies with `npm install --omit=dev` by default, so runtime deps must be listed under `dependencies`; when `npmCommand` is configured, git packages use plain `install` for compatibility with wrappers. If you use a Node version manager and want package installs to reuse a stable npm context, set `npmCommand` in `settings.json`, for example `["mise", "exec", "node@20", "--", "npm"]`.

Create a package by adding a `pi` key to `package.json`:

```json
{
  "name": "my-pi-package",
  "keywords": ["pi-package"],
  "pi": {
    "extensions": ["./extensions"],
    "skills": ["./skills"],
    "prompts": ["./prompts"],
    "themes": ["./themes"]
  }
}
```

Without a `pi` manifest, pi auto-discovers from conventional directories (`extensions/`, `skills/`, `prompts/`, `themes/`).

See [docs/packages.md](docs/packages.md).

---

## Programmatic Usage

### SDK

```typescript
import { AuthStorage, createAgentSession, ModelRegistry, SessionManager } from "@mariozechner/pi-coding-agent";

const authStorage = AuthStorage.create();
const modelRegistry = ModelRegistry.create(authStorage);
const { session } = await createAgentSession({
  sessionManager: SessionManager.inMemory(),
  authStorage,
  modelRegistry,
});

await session.prompt("What files are in the current directory?");
```

For advanced multi-session runtime replacement, use `createAgentSessionRuntime()` and `AgentSessionRuntime`.

See [docs/sdk.md](docs/sdk.md) and [examples/sdk/](examples/sdk/).

### RPC Mode

For non-Node.js integrations, use RPC mode over stdin/stdout:

```bash
pi --mode rpc
```

RPC mode uses strict LF-delimited JSONL framing. Clients must split records on `\n` only. Do not use generic line readers like Node `readline`, which also split on Unicode separators inside JSON payloads.

See [docs/rpc.md](docs/rpc.md) for the protocol.

---

## Philosophy

Pi is aggressively extensible so it doesn't have to dictate your workflow. Features that other tools bake in can be built with [extensions](#extensions), [skills](#skills), or installed from third-party [pi packages](#pi-packages). This keeps the core minimal while letting you shape pi to fit how you work.

**No MCP.** Build CLI tools with READMEs (see [Skills](#skills)), or build an extension that adds MCP support. [Why?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/)

**No sub-agents.** There's many ways to do this. Spawn pi instances via tmux, or build your own with [extensions](#extensions), or install a package that does it your way.

**No permission popups.** Run in a container, or build your own confirmation flow with [extensions](#extensions) inline with your environment and security requirements.

**No plan mode.** Write plans to files, or build it with [extensions](#extensions), or install a package.

**No built-in to-dos.** They confuse models. Use a TODO.md file, or build your own with [extensions](#extensions).

**No background bash.** Use tmux. Full observability, direct interaction.

Read the [blog post](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/) for the full rationale.

---

## CLI Reference

```bash
pi [options] [@files...] [messages...]
```

### Package Commands

```bash
pi install <source> [-l]     # Install package, -l for project-local
pi remove <source> [-l]      # Remove package
pi uninstall <source> [-l]   # Alias for remove
pi update [source|self|pi]   # Update pi and packages (skips pinned packages)
pi update --extensions       # Update packages only
pi update --self             # Update pi only
pi update --self --force     # Reinstall pi even if current
pi update --extension <src>  # Update one package
pi list                      # List installed packages
pi config                    # Enable/disable package resources
```

### Modes

| Flag | Description |
|------|-------------|
| (default) | Interactive mode |
| `-p`, `--print` | Print response and exit |
| `--mode json` | Output all events as JSON lines (see [docs/json.md](docs/json.md)) |
| `--mode rpc` | RPC mode for process integration (see [docs/rpc.md](docs/rpc.md)) |
| `--export <in> [out]` | Export session to HTML |

In print mode, pi also reads piped stdin and merges it into the initial prompt:

```bash
cat README.md | pi -p "Summarize this text"
```

### Model Options

| Option | Description |
|--------|-------------|
| `--provider <name>` | Provider (anthropic, openai, google, etc.) |
| `--model <pattern>` | Model pattern or ID (supports `provider/id` and optional `:<thinking>`) |
| `--api-key <key>` | API key (overrides env vars) |
| `--thinking <level>` | `off`, `minimal`, `low`, `medium`, `high`, `xhigh` |
| `--models <patterns>` | Comma-separated patterns for Ctrl+P cycling |
| `--list-models [search]` | List available models |

### Session Options

| Option | Description |
|--------|-------------|
| `-c`, `--continue` | Continue most recent session |
| `-r`, `--resume` | Browse and select session |
| `--session <path\|id>` | Use specific session file or partial UUID |
| `--fork <path\|id>` | Fork specific session file or partial UUID into a new session |
| `--session-dir <dir>` | Custom session storage directory |
| `--no-session` | Ephemeral mode (don't save) |

### Tool Options

| Option | Description |
|--------|-------------|
| `--tools <list>`, `-t <list>` | Allowlist specific tool names across built-in, extension, and custom tools |
| `--no-builtin-tools`, `-nbt` | Disable built-in tools by default but keep extension/custom tools enabled |
| `--no-tools`, `-nt` | Disable all tools by default |

Available built-in tools: `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls`

### Resource Options

| Option | Description |
|--------|-------------|
| `-e`, `--extension <source>` | Load extension from path, npm, or git (repeatable) |
| `--no-extensions` | Disable extension discovery |
| `--skill <path>` | Load skill (repeatable) |
| `--no-skills` | Disable skill discovery |
| `--prompt-template <path>` | Load prompt template (repeatable) |
| `--no-prompt-templates` | Disable prompt template discovery |
| `--theme <path>` | Load theme (repeatable) |
| `--no-themes` | Disable theme discovery |
| `--no-context-files`, `-nc` | Disable AGENTS.md and CLAUDE.md context file discovery |

Combine `--no-*` with explicit flags to load exactly what you need, ignoring settings.json (e.g., `--no-extensions -e ./my-ext.ts`).

### Other Options

| Option | Description |
|--------|-------------|
| `--system-prompt <text>` | Replace default prompt (context files and skills still appended) |
| `--append-system-prompt <text>` | Append to system prompt |
| `--verbose` | Force verbose startup |
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |

### File Arguments

Prefix files with `@` to include in the message:

```bash
pi @prompt.md "Answer this"
pi -p @screenshot.png "What's in this image?"
pi @code.ts @test.ts "Review these files"
```

### Examples

```bash
# Interactive with initial prompt
pi "List all .ts files in src/"

# Non-interactive
pi -p "Summarize this codebase"

# Non-interactive with piped stdin
cat README.md | pi -p "Summarize this text"

# Different model
pi --provider openai --model gpt-4o "Help me refactor"

# Model with provider prefix (no --provider needed)
pi --model openai/gpt-4o "Help me refactor"

# Model with thinking level shorthand
pi --model sonnet:high "Solve this complex problem"

# Limit model cycling
pi --models "claude-*,gpt-4o"

# Read-only mode
pi --tools read,grep,find,ls -p "Review the code"

# High thinking level
pi --thinking high "Solve this complex problem"
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `PI_CODING_AGENT_DIR` | Override config directory (default: `~/.pi/agent`) |
| `PI_PACKAGE_DIR` | Override package directory (useful for Nix/Guix where store paths tokenize poorly) |
| `PI_SKIP_VERSION_CHECK` | Skip version check at startup |
| `PI_TELEMETRY` | Override install telemetry. Use `1`/`true`/`yes` to enable or `0`/`false`/`no` to disable |
| `PI_CACHE_RETENTION` | Set to `long` for extended prompt cache (Anthropic: 1h, OpenAI: 24h) |
| `VISUAL`, `EDITOR` | External editor for Ctrl+G |

---

## Contributing & Development

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines and [docs/development.md](docs/development.md) for setup, forking, and debugging.

---

## License

MIT

## See Also

- [@mariozechner/pi-ai](https://www.npmjs.com/package/@mariozechner/pi-ai): Core LLM toolkit
- [@mariozechner/pi-agent](https://www.npmjs.com/package/@mariozechner/pi-agent): Agent framework
- [@mariozechner/pi-tui](https://www.npmjs.com/package/@mariozechner/pi-tui): Terminal UI components

---

## Architecture Notes (pi-mono)

A reading of `packages/agent`, `packages/coding-agent`, and `packages/mom` summarized along four axes: context management, tool use, subagents, and failure handling. Followed by a deep dive into compaction (trigger and pipeline).

### 1. Context / State / Memory

State, context, and memory are kept in three separate layers.

#### a) State — in-memory only

`packages/agent/src/agent.ts` (`Agent` class) holds `_state: MutableAgentState`:

- `systemPrompt` / `model` / `thinkingLevel` / `tools` / `messages`
- Runtime flags: `isStreaming`, `streamingMessage`, `pendingToolCalls`, `errorMessage`

The `messages` setter shallow-copies. Every LLM call snapshots `state.messages` via `createContextSnapshot()`. The event stream advances state in `Agent.processEvents` based on `message_start/update/end` and `tool_execution_*` events.

#### b) Context — per-turn pipeline before the LLM call

```
AgentMessage[] → transformContext() → AgentMessage[] → convertToLlm() → Message[] → LLM
```

- `transformContext` is the hook for context-window management (prune / inject) — invoked in `streamAssistantResponse` in `agent-loop.ts`.
- `convertToLlm` filters UI-only messages and converts custom message types into the LLM-compatible `user / assistant / toolResult` shape.

#### c) Memory — persisted to disk, reloaded next session

Two distinct mechanisms:

**(i) `AGENTS.md` / `CLAUDE.md` (project-level, auto-loaded into the system prompt).**
`loadProjectContextFiles` (`coding-agent/src/core/resource-loader.ts`) loads, in order:

1. `~/.pi/agent/AGENTS.md` (global)
2. Every ancestor of `cwd` (walking up), then `cwd` itself, picking the first of `AGENTS.md` / `CLAUDE.md` per directory.

The resulting files are concatenated into the `# Project Context` section of the system prompt (`coding-agent/src/core/system-prompt.ts`). pi never writes these — they are user-maintained.

**(ii) `MEMORY.md` (runtime self-write, only used by the `mom` Slack agent).**
The "agent writes its own memory.md" pattern lives in `packages/mom/src/agent.ts`:

- `getMemory()` is called at the start of every run and reads `<workspace>/MEMORY.md` and `<channel>/MEMORY.md`, splicing them into the system prompt.
- The system prompt explicitly instructs the model to update those files when something is worth remembering.
- There is **no dedicated `write_memory` tool** — the agent uses the regular `write` / `edit` tools against the two known paths. Update timing is fully model-driven by the prompt.

#### d) Compaction — online context compression

See the dedicated section [Compaction Deep Dive](#compaction-deep-dive) below.

### 2. Tool Use

Tools are defined by `AgentTool<TParameters>` (`packages/agent/src/types.ts`): `name` + `label` + Typebox schema + `execute(id, params, signal, onUpdate)` + optional `prepareArguments`, `executionMode`. Built-in coding tools live in `packages/coding-agent/src/core/tools/`: `read / bash / edit / write / grep / find / ls`. Default exposure is `[read, bash, edit, write]`.

Each tool call goes through four stages in `agent-loop.ts`:

1. **prepare** (`prepareToolCall`): tool lookup → `prepareArguments` → schema validation → `beforeToolCall` hook (may return `{ block: true }`, which materializes an error tool result).
2. **execute** (`executePreparedToolCall`): runs `tool.execute`; partial results are forwarded as `tool_execution_update` events; thrown errors become an error tool result.
3. **finalize** (`finalizeExecutedToolCall`): runs `afterToolCall` to optionally override `content / details / isError / terminate`.
4. **emit**: `tool_execution_end` and a `toolResult` message are appended to the transcript.

Execution mode (`coding-agent/src/core/agent-session.ts`, default `parallel`):

- **parallel**: preflight is sequential (so `beforeToolCall` sees stable state), then allowed tools run concurrently. `tool_execution_end` is emitted in completion order, but `toolResult` messages are flushed in assistant source order so the transcript stays deterministic.
- **sequential**: one at a time.
- A single tool may set `executionMode: "sequential"`; if any tool in the batch is sequential, the whole batch degrades to sequential.

`terminate: true` is a hint, not a stop. The loop only stops early when **every** finalized tool result in a batch sets `terminate: true`.

Mid-run injection is exposed via two queues on `Agent`:

- `steer(message)` — injected after the current turn's tool calls finish.
- `followUp(message)` — injected only when the agent would otherwise stop, restarting the loop.

### 3. Subagent / Agent Teams

The core runtime has **no built-in subagent**. Subagents are implemented as an example extension at `packages/coding-agent/examples/extensions/subagent/`, using **process-level fan-out**: each subagent is a fresh `pi` subprocess with its own context window.

Three modes (`subagent/index.ts`):

- `single` — `{ agent, task }`.
- `parallel` — `{ tasks: [...] }`. Capped at 8 tasks, 4 concurrent.
- `chain` — `{ chain: [...] }`. The `{previous}` placeholder in a step's task text is replaced with the prior step's final output.

Each subagent invocation `spawn`s `pi --mode json -p --no-session`, streams `message_end` / `tool_result_end` events back over stdout, and aggregates them. Agent definitions live as Markdown files with frontmatter (`name / description / tools / model`) under `~/.pi/agent/agents/` (user) or `.pi/agents/` (project).

Isolation is real: each subprocess gets its own `--append-system-prompt`, `--tools` allowlist, and `--model`, and never shares the parent transcript. Project-scope agents require explicit opt-in (`agentScope: "project" | "both"`) and prompt for confirmation in interactive mode. Workflow combinations like `/implement` (scout → planner → worker) are just chain presets layered on top of this primitive.

### 4. Failure Handling

Five layers, designed so `Agent` state is always consistent.

**Layer A — Stream contract (`packages/agent/src/types.ts`).** The stream function **must not** throw or reject. All failures are encoded as a final `AssistantMessage` with `stopReason: "error" | "aborted"` and an `errorMessage`. This keeps event flow uniform regardless of provider behavior.

**Layer B — Agent loop (`agent-loop.ts`).** If a streamed message has `stopReason === "error" || "aborted"`, the loop emits `turn_end` + `agent_end` and exits without another LLM call. Tool execution that throws is caught by `executePreparedToolCall` and converted into an error tool result; the loop continues so the model can react. `beforeToolCall` and `afterToolCall` exceptions are handled the same way (`afterToolCall` errors overwrite the result with an error result).

**Layer C — `Agent.runWithLifecycle` (`agent.ts`).** Top-level try/catch. If the stream contract is violated and an exception escapes, `handleRunFailure` synthesizes a fallback assistant message with `stopReason: "error"` and emits `agent_end`. State always converges.

**Layer D — `AgentSession` auto-retry (`coding-agent/src/core/agent-session.ts`, `_handleRetryableError`).**

- `_isRetryableError` matches a long regex covering `overloaded / 429 / 5xx / network errors / connection lost / fetch failed / timeout / terminated / retry delay`.
- **Context overflow is explicitly excluded** — that path is handled by compaction.
- Defaults: `maxRetries = 3`, `baseDelayMs = 2000`, exponential backoff (2 s, 4 s, 8 s).
- The error assistant message is removed from `agent.state.messages` before retry (it is still kept in the persisted session for history).
- Retry is performed via `agent.continue()`, scheduled with `setTimeout` to escape the event handler.
- `auto_retry_start` / `auto_retry_end` events drive UI countdown; the wait is abortable via `_retryAbortController`.

**Layer E — Compaction backstop for context overflow (`agent-session.ts`, `_checkCompaction`).**

- Detect via `isContextOverflow` from `pi-ai`. On overflow, drop the failing assistant message, run `_runAutoCompaction("overflow", willRetry = true)`, then auto-`continue`.
- `_overflowRecoveryAttempted` ensures only one overflow recovery per failure to avoid compact/overflow loops. A second overflow surfaces an actionable error suggesting a larger-context model.

**Subagent layer.** A `chain` halts at the first failing step and reports which step. `parallel` runs are independent. On abort, `SIGTERM` is sent to the subprocess and `SIGKILL` follows after 5 s as a safety net.

The recurring pattern across all five layers: encode failure as data (a message + state field), do not let exceptions escape the loop, and put recovery decisions at the layer that has enough context to make them.

---

## Compaction Deep Dive

Compaction is the mechanism that shrinks the visible context window when a session has accumulated more tokens than the model can carry. It is implemented in `packages/coding-agent/src/core/compaction/compaction.ts` and orchestrated by `AgentSession`.

### Where it sits

```
agent_end ─→ AgentSession._checkCompaction(lastAssistantMessage)
              │
              ├─ overflow path  ─→ _runAutoCompaction("overflow",  willRetry=true)
              │                     └─→ continue() to retry the failed turn
              │
              ├─ threshold path ─→ _runAutoCompaction("threshold", willRetry=false)
              │                     └─→ user continues manually
              │
              └─ manual /compact ─→ _runAutoCompaction("manual",   willRetry=false)
```

### Trigger conditions

There are three triggers, all funnelled through `_runAutoCompaction(reason, willRetry)`:

| Reason | Trigger | Detection | Auto-retry |
|---|---|---|---|
| `overflow` | LLM rejected the request because input exceeded the model's context window | `isContextOverflow(assistantMessage, contextWindow)` returns true on the most recent assistant message; only counted if `assistantMessage.provider === currentModel.provider && assistantMessage.model === currentModel.id` (so an overflow recorded under a smaller model is not re-triggered after switching to a larger one) | Yes — once. `_overflowRecoveryAttempted` blocks a second attempt. |
| `threshold` | Cumulative context tokens have crossed the configured headroom | `shouldCompact(contextTokens, contextWindow, settings)` where `contextTokens > contextWindow - reserveTokens` | No — the user resumes via the next prompt. |
| `manual` | User typed `/compact [instructions]` | n/a | No. The optional instructions are forwarded to the summarizer as `customInstructions`. |

Two pre-checks gate every auto run inside `_checkCompaction`:

1. The triggering message is skipped if `stopReason === "aborted"` (the user cancelled).
2. The triggering message is skipped if it predates the most recent compaction boundary (`assistantMessage.timestamp <= compactionEntry.timestamp`). Without this guard, a stale pre-compaction usage record could re-trigger compaction on the very first prompt after one just finished.

For the `threshold` path on an error message that has no usage data (e.g. persistent 529s), `contextTokens` is estimated from the latest non-aborted assistant message via `estimateContextTokens()`, with a similar staleness guard against pre-compaction usage.

### Token accounting

```ts
calculateContextTokens(usage) =
  usage.totalTokens || (input + output + cacheRead + cacheWrite)
```

When a usage object is unavailable, `estimateTokens(message)` falls back to `chars / 4`, summing text content for `user`, text + thinking + serialized tool calls for `assistant`, content blocks for `toolResult` / `custom`, etc. (see `compaction.ts:232`). Images count as 4800 chars (~1200 tokens) to keep the heuristic conservative.

### Settings (project or `~/.pi/agent/settings.json`)

```json
{
  "compaction": {
    "enabled": true,
    "reserveTokens": 16384,
    "keepRecentTokens": 20000
  }
}
```

- `reserveTokens` — headroom kept for the next response. Threshold = `contextWindow - reserveTokens`.
- `keepRecentTokens` — recent transcript that is **not** summarized. The cut-point walker stops once it has accumulated this many tokens going backwards from the newest entry.
- `enabled = false` disables auto-compaction entirely; `/compact` still works.

### Pipeline

`prepareCompaction(pathEntries, settings)` produces a `CompactionPreparation`, then `compact(preparation, model, apiKey, …)` runs the actual summarization. The full pipeline:

1. **Skip if last entry is already a compaction.** `prepareCompaction` returns `undefined`, and the orchestrator emits `compaction_end` with `result: undefined`.

2. **Find the previous compaction boundary.** Walking backwards through the branch entries, locate the most recent `compaction` entry. Its `firstKeptEntryId` becomes `boundaryStart` (so messages already summarized once are not re-summarized — but messages **kept** by the previous compaction are re-included, preserving cumulative history). Its `summary` becomes `previousSummary`, used by the iterative-update prompt.

3. **Compute `tokensBefore`** from the rebuilt session context, so the saved `CompactionEntry` records the actual size being replaced.

4. **`findCutPoint(boundaryStart, boundaryEnd, keepRecentTokens)`.**

   - Walk backward from the newest entry, summing `estimateTokens(message)` per entry.
   - When the running sum reaches `keepRecentTokens`, snap to the **closest valid cut point at or after** that index.
   - Valid cut points: `user`, `assistant`, `bashExecution`, `custom_message`, `branch_summary`, `compactionSummary`. Never `toolResult` (tool results must stay attached to their tool call).
   - After picking the cut, scan backwards to absorb adjacent non-message entries (`thinking_level_change`, `model_change`, etc.) so they ride along with the message they belong to. Stop at the previous compaction boundary or any prior message.
   - If the cut lands on a non-`user` entry, locate the start of that turn (`findTurnStartIndex`) — the result is a **split turn**.

5. **Slice into three regions.**

   - `messagesToSummarize` — entries `[boundaryStart, historyEnd)`. These get summarized and discarded from context.
   - `turnPrefixMessages` — only populated when `isSplitTurn`: entries `[turnStartIndex, firstKeptEntryIndex)`. The early part of a single oversized turn.
   - Kept region — entries `[firstKeptEntryIndex, end)`. These remain visible to the model.

6. **Extract file operations.** `extractFileOperations` walks `messagesToSummarize` and merges in any `readFiles / modifiedFiles` from the previous compaction's `details` (skipped for extension-provided compactions to avoid double counting). Result: `fileOps = { read: Set<string>, edited: Set<string> }`.

7. **Extension hook (`session_before_compact`).** If any extension is registered, it receives the full `CompactionPreparation` plus the branch entries and an `AbortSignal`. It can:
   - Return `{ cancel: true }` — `compaction_end` fires with `aborted: true` and the run stops.
   - Return `{ compaction: { summary, firstKeptEntryId, tokensBefore, details } }` — the extension's summary replaces pi's. `fromExtension = true` is recorded so file-op details are not later double-merged.
   - Return nothing — pi runs the default summarization.

8. **Generate summaries (default path, `compact()`).**

   - Serialize `messagesToSummarize` via `convertToLlm` + `serializeConversation` so the model sees a transcript instead of an unfinished conversation. Tool results are truncated to 2000 chars during serialization.
   - Wrap in `<conversation>…</conversation>` and `<previous-summary>…</previous-summary>` tags.
   - Pick the prompt template:
     - First-time → `SUMMARIZATION_PROMPT` (sections: Goal / Constraints & Preferences / Progress (Done / In Progress / Blocked) / Key Decisions / Next Steps / Critical Context).
     - Has previous summary → `UPDATE_SUMMARIZATION_PROMPT` (preserve old info, move done items from "In Progress" to "Done", update "Next Steps").
   - `customInstructions` (from `/compact <instructions>`) is appended as "Additional focus".
   - Call `completeSimple()` with `maxTokens = floor(0.8 * reserveTokens)` and a dedicated `SUMMARIZATION_SYSTEM_PROMPT`. Reasoning level is forwarded if the model supports it.
   - **Split-turn case**: `generateSummary(messagesToSummarize, …)` and `generateTurnPrefixSummary(turnPrefixMessages, …)` run concurrently via `Promise.all`. The prefix uses `TURN_PREFIX_SUMMARIZATION_PROMPT` and a smaller `maxTokens = floor(0.5 * reserveTokens)`. Outputs are merged: `${history}\n\n---\n\n**Turn Context (split turn):**\n\n${turnPrefix}`.
   - Append cumulative file operations to the summary as `<read-files>` and `<modified-files>` blocks (`formatFileOperations`).

9. **Persist.** `sessionManager.appendCompaction(summary, firstKeptEntryId, tokensBefore, details, fromExtension)` writes a new `CompactionEntry` to the JSONL session file. Then `buildSessionContext()` rebuilds the in-memory transcript: the kept messages plus a synthetic `compactionSummary` message containing the new summary. `agent.state.messages` is replaced with that rebuild.

10. **Emit `session_compact`** so other extensions can react to the saved entry.

11. **Emit `compaction_end`** with `{ reason, result, aborted, willRetry, errorMessage? }`.

12. **Post-compaction continuation.**

    - **`willRetry`** (overflow only): strip a trailing `stopReason: "error"` assistant message if still present, then `setTimeout(() => agent.continue(), 100)` to retry the failed turn under the new, smaller context.
    - **Has queued messages** (steering or follow-up): kick the loop so they are delivered.
    - **Otherwise**: leave control to the user.

### What the LLM sees afterward

```
┌────────┬─────────────────────────────┬─────┬─────┬──────┬─────┐
│ system │ <compactionSummary message> │ usr │ ass │ tool │ ... │   ← current visible context
└────────┴─────────────────────────────┴─────┴─────┴──────┴─────┘
                                       └─── from firstKeptEntryId ───┘
```

The summary is delivered as a normal message with role `compactionSummary` (converted to an LLM-compatible role by `convertToLlm`), so the model treats it as recap context, not as something to continue.

### Edge cases worth knowing

- **Session needs migration** — if the chosen `firstKeptEntry` has no UUID, `prepareCompaction` returns `undefined` and the run is skipped (older session formats).
- **Aborted compaction** — `_autoCompactionAbortController` is checked after the (potentially long) summarization call. If the user cancelled mid-summary, no entry is written and `compaction_end` reports `aborted: true`.
- **Auth missing** — if `modelRegistry.getApiKeyAndHeaders` fails, compaction emits `compaction_end` with `result: undefined` and never calls the LLM.
- **Cumulative file tracking** — every compaction's `details.readFiles / modifiedFiles` includes prior compactions' lists merged with anything new, so the file footprint of the conversation survives across many compactions.
- **Branch summarization** is a sibling mechanism (`compaction/branch-summarization.ts`) that fires on `/tree` navigation. It uses the same summary format and the same cumulative file tracking, but writes a `BranchSummaryEntry` instead of a `CompactionEntry`.
