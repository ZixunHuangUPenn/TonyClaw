// Load .env from project root (and a few likely locations) at module-load time.
// Importing this module for its side effect MUST happen before any code that reads
// process.env.OPENAI_* / MOM_SLACK_* — otherwise top-level evaluation will see
// undefined values.
//
// Requires Node >= 20.12 (process.loadEnvFile). Failures are ignored silently
// because env vars may also be supplied by the shell or a parent process.

import { existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));

const candidates = [
	// Run from packages/mom (typical: `npx tsx src/main.ts ...`)
	resolve(process.cwd(), ".env"),
	resolve(process.cwd(), "..", ".env"),
	resolve(process.cwd(), "..", "..", ".env"),
	// Walk up from this file's location regardless of cwd
	resolve(here, "..", ".env"),
	resolve(here, "..", "..", ".env"),
	resolve(here, "..", "..", "..", ".env"),
];

const seen = new Set<string>();
for (const candidate of candidates) {
	if (seen.has(candidate)) continue;
	seen.add(candidate);
	if (!existsSync(candidate)) continue;
	try {
		(process as unknown as { loadEnvFile: (p: string) => void }).loadEnvFile(candidate);
	} catch {
		// node < 20.12 or unreadable file — fall through
	}
}
