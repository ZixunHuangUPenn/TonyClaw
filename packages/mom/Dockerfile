# syntax=docker/dockerfile:1.6
#
# Build context MUST be the monorepo root (not packages/mom/), because mom
# depends on sibling workspace packages (pi-ai, pi-agent-core, pi-coding-agent).
# Run from repo root: docker build -f packages/mom/Dockerfile -t mom .
#
FROM node:20-bookworm-slim

# docker CLI: mom shells out to `docker exec mom-sandbox ...` (sandbox.ts).
# Installing docker.io brings the CLI; the daemon binary inside this image is
# never started — we mount the host's docker.sock instead.
RUN apt-get update \
 && apt-get install -y --no-install-recommends docker.io ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- Dependency layer ---
# Copy lockfile + every workspace's package.json so `npm ci` resolves the
# graph. Source changes below this line don't bust the install cache.
COPY package.json package-lock.json ./
COPY packages/ai/package.json           packages/ai/package.json
COPY packages/agent/package.json        packages/agent/package.json
COPY packages/coding-agent/package.json packages/coding-agent/package.json
COPY packages/mom/package.json          packages/mom/package.json
COPY packages/tui/package.json          packages/tui/package.json
COPY packages/web-ui/package.json       packages/web-ui/package.json
COPY packages/pods/package.json         packages/pods/package.json

# --ignore-scripts skips native postinstalls (canvas etc. in dev deps we
# don't need at runtime). tsgo/typescript are pure JS — they don't need it.
RUN npm ci --ignore-scripts

# --- Source + build layer ---
COPY packages packages

# Build only the chain mom transitively imports. Skip tui/web-ui/pods.
# pi-ai's build hits openrouter.ai / models.dev for model registry — needs net.
RUN cd packages/ai           && npm run build \
 && cd ../agent              && npm run build \
 && cd ../coding-agent       && npm run build \
 && cd ../mom                && npm run build

WORKDIR /app/packages/mom
ENV NODE_ENV=production

# /workspace/data: bind-mounted from host (see docker-compose.yml)
# --sandbox=docker:mom-sandbox: name of the sibling container we exec into
CMD ["node", "dist/main.js", "--sandbox=docker:mom-sandbox", "/workspace/data"]
