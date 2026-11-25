import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const root = resolve(packageDir, "../..");
const apiDir = join(root, "services/api");
const snapshot = join(packageDir, "openapi.json");
const check = process.argv.includes("--check");
const tempDir = mkdtempSync(join(tmpdir(), "dukaan-openapi-"));
const output = check ? join(tempDir, "openapi.json") : snapshot;

try {
  const result = spawnSync(
    "uv",
    [
      "run",
      "--locked",
      "python",
      "manage.py",
      "spectacular",
      "--file",
      output,
      "--validate",
    ],
    { cwd: apiDir, stdio: "inherit" },
  );
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);

  if (check) {
    const expected = readFileSync(snapshot);
    const actual = readFileSync(output);
    const digest = (value) => createHash("sha256").update(value).digest("hex");
    if (digest(expected) !== digest(actual)) {
      console.error(
        "OpenAPI snapshot is stale. Run `npm run schema:generate` and commit packages/api-contract/openapi.json.",
      );
      process.exitCode = 1;
    } else {
      console.log("OpenAPI snapshot is current.");
    }
  } else {
    console.log(`Generated ${output}`);
  }
} finally {
  rmSync(tempDir, { recursive: true, force: true });
}
