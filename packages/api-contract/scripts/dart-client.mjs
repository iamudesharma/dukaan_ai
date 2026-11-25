import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import {
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const snapshot = join(packageDir, "openapi.json");
const committed = join(packageDir, "dart");
const check = process.argv.includes("--check");
const tempDir = check ? mkdtempSync(join(tmpdir(), "dukaan-dart-client-")) : null;
const output = check ? join(tempDir, "client") : committed;

function run(command, args, cwd) {
  const result = spawnSync(command, args, { cwd, stdio: "inherit" });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

function files(root, current = root) {
  const result = [];
  for (const name of readdirSync(current)) {
    if (name === ".dart_tool") continue;
    const path = join(current, name);
    const stat = statSync(path);
    if (stat.isDirectory()) result.push(...files(root, path));
    else result.push(relative(root, path));
  }
  return result.sort();
}

function digestTree(root) {
  return Object.fromEntries(
    files(root).map((name) => [
      name,
      createHash("sha256").update(readFileSync(join(root, name))).digest("hex"),
    ]),
  );
}

try {
  if (!check) rmSync(committed, { recursive: true, force: true });
  run(
    "openapi-generator-cli",
    [
      "generate",
      "-i",
      snapshot,
      "-g",
      "dart-dio",
      "-o",
      output,
      "--additional-properties",
      [
        "pubName=dukaanai_api_client",
        "pubLibrary=dukaanai_api_client",
        "pubDescription=DukaanAI-OpenAPI-client",
        "pubPublishTo=none",
        "pubVersion=0.1.0",
        "sourceFolder=src",
        "enumUnknownDefaultCase=false",
        "useOptional=false",
        "serializationLibrary=json_serializable",
        "hideGenerationTimestamp=true",
      ].join(","),
      "--global-property",
      "apiDocs=false,modelDocs=false,apiTests=false,modelTests=false",
    ],
    packageDir,
  );
  // OpenAPI Generator 7.27 emits a private enum constructor for schema
  // defaults even though the generated enum exposes named constants. Normalize
  // those defaults so the package compiles without patching generated files by
  // hand after every schema change.
  for (const name of files(output)) {
    if (!name.endsWith(".dart")) continue;
    const path = join(output, name);
    const source = readFileSync(path, "utf8");
    const normalized = source.replace(
      /(?:const\s+)?\b([A-Za-z0-9_]+Enum)\._\('([^']+)'\)/g,
      "$1.$2",
    );
    if (normalized !== source) writeFileSync(path, normalized);
  }

  const pubspecPath = join(output, "pubspec.yaml");
  const pubspec = readFileSync(pubspecPath, "utf8").replace(
    /sdk: '[^']+'/,
    "sdk: '>=3.8.0 <4.0.0'",
  );
  writeFileSync(pubspecPath, pubspec);
  const ignorePath = join(output, ".gitignore");
  writeFileSync(
    ignorePath,
    readFileSync(ignorePath, "utf8").replace(/^pubspec\.lock\r?\n/m, ""),
  );
  run("dart", ["pub", "get"], output);
  run("dart", ["run", "build_runner", "build"], output);
  // Generated templates can contain trailing spaces and an extra EOF blank
  // line. Format Dart and normalize generated docs so checked-in output and
  // drift checks stay clean.
  run("dart", ["format", output], output);
  for (const name of files(output)) {
    if (!name.endsWith(".dart") && !name.endsWith(".md")) continue;
    const path = join(output, name);
    const source = readFileSync(path, "utf8");
    const normalized = source.replace(/[ \t]+$/gm, "").replace(/\n+$/, "\n");
    if (normalized !== source) writeFileSync(path, normalized);
  }

  if (check) {
    const expected = digestTree(committed);
    const actual = digestTree(output);
    if (JSON.stringify(expected) !== JSON.stringify(actual)) {
      console.error(
        "Generated Dart client is stale. Run `npm run clients:generate` and commit packages/api-contract/dart.",
      );
      process.exitCode = 1;
    } else {
      console.log("Generated Dart client is current.");
    }
  } else {
    console.log(`Generated ${output}`);
  }
} finally {
  if (tempDir) rmSync(tempDir, { recursive: true, force: true });
}
