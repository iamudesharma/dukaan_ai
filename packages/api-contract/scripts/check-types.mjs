import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const snapshot = join(packageDir, "openapi.json");
const generated = join(packageDir, "src/types.ts");
const tempDir = mkdtempSync(join(tmpdir(), "dukaan-openapi-types-"));
const output = join(tempDir, "types.ts");

try {
  const result = spawnSync("openapi-typescript", [snapshot, "-o", output], {
    cwd: packageDir,
    stdio: "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
  const digest = (path) =>
    createHash("sha256").update(readFileSync(path)).digest("hex");
  if (digest(generated) !== digest(output)) {
    console.error(
      "Generated API types are stale. Run `npm run clients:generate` and commit packages/api-contract/src/types.ts.",
    );
    process.exitCode = 1;
  } else {
    console.log("Generated API types are current.");
  }
} finally {
  rmSync(tempDir, { recursive: true, force: true });
}
