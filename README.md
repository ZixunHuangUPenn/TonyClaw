# TonyClaw

基于 [pi-mono](https://github.com/badlogic/pi-mono) fork 的私有 Coding Agent，通过 Slack 与用户协作，部署在阿里云硅谷节点上 7×24 待命，目前主要服务 **HRMS（人事系统）** 项目的日常开发。

---

## 1. 项目功能介绍

### 核心能力

- **Slack 触发**：在 Slack 频道里 @TonyClaw 或私信即可调用，每个频道维护独立的会话历史
- **代码协作**：read / write / edit / bash 全套工具，按 TDD 分批纪律提交（先 `test:` 再 `feat:` / `fix:`），代码注释英文、回复中文
- **Docker 沙箱隔离**：所有 bash 命令在隔离容器里跑，agent 看不到宿主机文件系统，只能访问显式挂载的目录
- **持久化记忆**：`MEMORY.md`（全局）+ 每个频道单独的 `MEMORY.md`，跨会话记住偏好、决策、上下文
- **自管理环境**：`apk add` 自己装工具、自己存凭据，第一次问你要 token，之后自己用
- **事件调度**：支持一次性提醒、cron 周期任务、外部触发（webhook 写文件即唤醒），见 [packages/mom/docs/events.md](packages/mom/docs/events.md)
- **附件处理**：图片直接读、其他文件挂到工作目录，agent 用 bash 工具分析
- **GitHub Actions CI/CD**：每次 push 到 main 自动构建镜像 → 推 GHCR → 服务器 pull + restart，约 5–10 分钟从代码到生效

### 运行架构

```
GitHub repo ──push──▶ GHA Build → GHCR (ghcr.io/.../pi-mono-mom:latest)
                                          │
                                          ▼  docker pull
┌─────────────────── Aliyun Silicon Valley (47.89.211.16) ──────────────────┐
│                                                                          │
│   mom container ────────► docker exec ────────► mom-sandbox container    │
│   (Slack WebSocket,       (via /var/run/                                  │
│    LLM API calls,           docker.sock)        bash / read / write 在这跑│
│    tool dispatch)                                                        │
│       │                                          │                       │
│       └──── /opt/mom/.env (secrets) ───┐         └─ /opt/projects/       │
│       └──── /opt/mom/data ─────────────┴─ shared host volume ─ hrsystem  │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
       ▲
       │ Slack Socket Mode (outbound WebSocket only, no inbound port)
       │
   Slack workspace
```

---

## 2. 项目结构

```
pi-mono/
├── packages/
│   ├── mom/                  # Slack 机器人主体（这是 TonyClaw 的入口）
│   │   ├── src/
│   │   │   ├── main.ts             # CLI 入口、Slack 连接、handler 装配
│   │   │   ├── agent.ts            # 每频道 AgentRunner、system prompt（含项目纪律）
│   │   │   ├── slack.ts            # Socket Mode 客户端、消息收发、附件下载
│   │   │   ├── sandbox.ts          # Host / Docker 执行器抽象
│   │   │   ├── events.ts           # 事件调度（one-shot / periodic / immediate）
│   │   │   ├── context.ts          # context.jsonl 同步、settings 管理
│   │   │   ├── store.ts            # 频道数据存储、附件下载
│   │   │   └── tools/              # bash / read / write / edit / attach
│   │   ├── Dockerfile              # mom 镜像构建定义（monorepo root 作为 build context）
│   │   └── docs/                   # sandbox / events / Slack 配置说明
│   ├── coding-agent/         # 通用 coding agent runtime（mom 依赖）
│   ├── agent/                # Agent 状态机 + 工具调用核心
│   ├── ai/                   # 多 provider LLM SDK（OpenAI 兼容、Anthropic、Gemini 等）
│   └── tui/                  # 终端 UI 库（coding-agent CLI 依赖）
│
├── docker-compose.yml        # 服务器侧编排：mom + mom-sandbox 两容器
├── .dockerignore
├── .github/workflows/
│   ├── deploy.yml            # 推 main 触发：build → GHCR → SSH 重启服务器容器
│   └── ci.yml                # 上游的 lint / build / test
├── tsconfig.base.json        # 所有 package 共享的 TS 配置
├── package.json              # npm workspaces 根
└── README.md
```

### 服务器侧目录

```
/opt/mom/
├── docker-compose.yml        # CI 自动 scp 上来
├── .env                      # 密钥（手工维护，不入 git）
├── data/                     # mom 工作区，频道历史 / skills / 附件
└── sandbox-ssh/              # （可选）给 sandbox 容器的 SSH key + git 配置

/opt/projects/
└── hrsystem/                 # 被 mount 进 sandbox 的项目代码
```

---

## 3. 项目使用说明

### 3.1 本地开发

```powershell
git clone git@github.com:ZixunHuangUPenn/pi-mono.git
cd pi-mono
npm install
npm run build

# 在 packages/mom/ 或 repo root 准备 .env：
#   MOM_SLACK_APP_TOKEN=xapp-...
#   MOM_SLACK_BOT_TOKEN=xoxb-...
#   OPENAI_API_KEY=...
#   OPENAI_API_BASE_URL=https://api.siliconflow.cn/v1
#   OPENAI_MODEL=Pro/zai-org/GLM-4.7

# Windows 下用 dev.sh（git bash）启动，sandbox 容器自动建立
cd packages/mom
./dev.sh
```

### 3.2 部署到阿里云（首次）

服务器一次性准备：
```bash
# 装 docker
curl -fsSL https://get.docker.com | sh && systemctl enable --now docker

# 建目录 + 写 .env
mkdir -p /opt/mom/data
nano /opt/mom/.env && chmod 600 /opt/mom/.env

# 给 GHA 用的 SSH key（私钥粘到 GitHub Secret DEPLOY_SSH_KEY）
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/gha -N ""
cat ~/.ssh/gha.pub >> ~/.ssh/authorized_keys

# 让服务器能拉私有 GHCR 镜像（PAT 需 read:packages）
echo "<github_pat>" | docker login ghcr.io -u ZixunHuangUPenn --password-stdin
```

GitHub Secrets（仓库设置 → Secrets and variables → Actions）：
| Name | Value |
|---|---|
| `DEPLOY_HOST` | 服务器 IP |
| `DEPLOY_USER` | `root` |
| `DEPLOY_SSH_KEY` | `cat ~/.ssh/gha` 完整内容 |

之后只要 `git push origin main`，CI 自动跑：
1. **build-push** job：buildx 构建镜像 → 打两个 tag（`:latest` + `:sha-<commit>`）→ 推 GHCR
2. **deploy** job：scp 最新 `docker-compose.yml` 到 `/opt/mom/` → SSH 进去 `docker compose pull && up -d` → 健康检查

### 3.3 挂载项目代码给 agent 工作

```bash
# 服务器
mkdir -p /opt/projects
git clone git@github.com:<org>/hrsystem.git /opt/projects/hrsystem
```

`docker-compose.yml` 已经预留了挂载点：
```yaml
mom-sandbox:
  volumes:
    - /opt/mom/data:/workspace
    - /opt/projects/hrsystem:/workspace/hrsystem    # agent 在这里改代码
```

> agent 默认**只能 commit 不能 push**（[packages/mom/src/agent.ts](packages/mom/src/agent.ts) 的 system prompt 明确禁止）。开放 push 权限的步骤见 [packages/mom/docs/sandbox.md](packages/mom/docs/sandbox.md)。

### 3.4 日常运维

```bash
# 看 mom 日志
docker logs -f mom

# 改 .env 后必须重启
cd /opt/mom && docker compose restart mom

# 进 sandbox 看 agent 装了什么
docker exec -it mom-sandbox sh

# 回滚到旧版本（按 commit SHA）
docker pull ghcr.io/zixunhuangupenn/pi-mono-mom:sha-<旧SHA>
docker tag  ghcr.io/zixunhuangupenn/pi-mono-mom:sha-<旧SHA> ghcr.io/zixunhuangupenn/pi-mono-mom:latest
docker compose up -d
```

### 3.5 Slack 端使用

- 频道里 `@TonyClaw <你的需求>` 触发
- 私信也行
- 说 `stop` 中断当前任务
- 长任务可以让它创建 event 在指定时间提醒你（见 [docs/events.md](packages/mom/docs/events.md)）

---

## 4. 项目原型和选择原因

### 4.1 为什么选 [pi-mono](https://github.com/badlogic/pi-mono) 作为原型

调研过 [Aider](https://github.com/Aider-AI/aider)、[OpenHands](https://github.com/All-Hands-AI/OpenHands)、[continue.dev](https://github.com/continuedev/continue)、自研。最终选 pi-mono 的原因：

| 维度 | pi-mono | Aider | OpenHands | 自研 |
|---|---|---|---|---|
| Slack 集成 | ✅ 原生 mom 包 | ❌ 仅 CLI | ⚠️ 需要套壳 | 自己写 |
| 沙箱隔离 | ✅ Docker exec 模式 | ❌ 直接跑宿主机 | ✅ Docker | 自己搞 |
| 持久化记忆 | ✅ MEMORY.md 跨会话 | ⚠️ 仅项目文档 | ⚠️ 弱 | 自己设计 |
| 可定制 system prompt | ✅ 一处文件 | ⚠️ 嵌入较深 | ⚠️ 复杂 | 完全自由 |
| 多 LLM provider | ✅ OpenAI 兼容 + Anthropic + Gemini... | ✅ 有 | ✅ 有 | 自己接 |
| 代码量 | 小（~5k LOC for mom） | 中 | 大 | — |
| 上手成本 | 1 天读完 | 半天 | 1 周 | 数周 |

**关键决策点**：

1. **代码可读**：mom 包的核心逻辑全在 [packages/mom/src/](packages/mom/src/) 11 个文件里，读得完、改得动。OpenHands 是个庞然大物，定制反而更费劲
2. **Slack Socket Mode**：pi-mono 用了 WebSocket 出站连接（不需要公网 IP / HTTPS 回调），部署门槛极低
3. **Skill 机制**：agent 自己创建可复用 CLI 工具的设计 ([链接](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/))，比 MCP 简单得多，且符合"agent 自我管理环境"的哲学
4. **MIT 协议**：可以闭源 fork 改造为公司私有版本

### 4.2 为什么选 Slack 而不是微信

| | Slack | 个人微信 | 企业微信 |
|---|---|---|---|
| 官方 API | ✅ 完善 | ❌ 无 | ✅ 有 |
| 封号风险 | 无 | **极高**（违反用户协议） | 无 |
| 部署门槛 | Socket Mode = 零公网要求 | 第三方协议 + 易封 | 需公网 HTTPS 回调 + ICP |
| 线程消息 | ✅ 工具调用详情放线程很合适 | ❌ 无原生概念 | ❌ 无 |
| 团队接受度 | 技术团队普遍熟 | 个人化 | 部分团队用 |

技术团队场景下 Slack 是首选。微信集成（企业微信）作为 Phase 2 的 nice-to-have 暂未做。

### 4.3 为什么选阿里云硅谷而不是国内节点

**Slack 在中国大陆被墙**。要在大陆节点跑 mom，必须额外配代理，且 `@slack/socket-mode` 默认不读 `HTTPS_PROXY`，需要改代码注入 `agent`——成本高、稳定性差。

阿里云硅谷节点：
- Slack 直连
- LLM 调用走 SiliconFlow（`api.siliconflow.cn`）国内端，从硅谷出口回中国虽多一跳延迟，但**单次 1–2s 在 LLM 响应时间面前可忽略**
- 价格跟国内节点相当（包年包月 2c8g 约 ¥150/月）

### 4.4 为什么用 Docker 镜像 + GHCR 而不是 systemd + git pull

试过两条路：

**Path A：服务器装 Node + git pull + systemd**
- 优点：服务器已有 Node 编一次就能跑，零额外基础设施
- 缺点：服务器要配 GitHub deploy key、服务器要装 build toolchain、build 在服务器上跑且不可复现、回滚靠 git reset

**Path B（最终选这个）：CI 构建镜像 + GHCR + 服务器 docker pull**
- 优点 1：服务器**只要 docker**，不装 node / npm / git
- 优点 2：build 在 CI 跑，镜像不可变 → 完全可复现
- 优点 3：回滚 = `docker tag :sha-<旧> :latest && docker compose up -d`，秒级
- 优点 4：每次 deploy 在服务器上只 pull 差异层，秒级生效
- 缺点：要写 Dockerfile（一次性成本）

Phase 1 直觉选 A 是对的（最快上线），但**项目稳定后切到 B**带来的运维收益值得。

### 4.5 为什么 mom 容器要挂 `/var/run/docker.sock`

mom 进程通过 `docker exec mom-sandbox <cmd>` 调用沙箱容器。这要求：
- 要么把 mom 也跑在宿主机（违背"mom 也容器化"的初衷）
- 要么 mom 容器内能调宿主机的 docker daemon → 挂 docker.sock

挂 docker.sock 等于给 mom 容器宿主机 root 权限。**取舍**：

- ✅ agent 的 bash 工具走 sandbox（**没有** docker.sock），LLM 提示注入攻击**不能**直接逃出沙箱
- ⚠️ 风险只在于 mom 自己的 Node 代码若被 RCE，攻击者能拿到宿主机
- 业界主流做法（Jenkins / GitLab Runner / Drone CI 全这样），可接受

如果要**彻底**消除这点，方案是 sysbox 或 docker-in-docker——比 docker.sock 复杂数倍，目前规模不值得。

---

## 致谢

- 上游项目：[badlogic/pi-mono](https://github.com/badlogic/pi-mono)（MIT License）
- 模型推理：[SiliconFlow](https://siliconflow.cn/)
- 部署：阿里云 ECS 硅谷节点

## License

MIT（继承上游）
