#!/usr/bin/env node
// Generates the CSS, TypeScript, and Dart outputs from tokens.json.
//
//   node packages/design-tokens/scripts/build.mjs           write the files
//   node packages/design-tokens/scripts/build.mjs --check   fail if they are stale
//
// The outputs are committed so contributors never need to run this to build.
// CI runs --check to make drift impossible.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, resolve, relative } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const SOURCE = resolve(ROOT, "packages/design-tokens/tokens.json");

const TARGETS = {
  css: resolve(ROOT, "apps/web/src/generated/tokens.css"),
  ts: resolve(ROOT, "apps/web/src/generated/tokens.ts"),
  dart: resolve(ROOT, "apps/mobile/lib/core/generated/dukaan_tokens.dart"),
};

const KNOWN_GROUPS = new Set([
  "$meta",
  "contrast",
  "font",
  "color",
  "space",
  "radius",
  "size",
  "shadow",
  "motion",
  "type",
]);

const BANNER = "GENERATED FILE — DO NOT EDIT. Source: packages/design-tokens/tokens.json. Regenerate: make tokens-generate";

// ---------------------------------------------------------------- utilities

const fail = (message) => {
  console.error(`\n  tokens: ${message}\n`);
  process.exit(1);
};

const kebab = (name) => name.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();

const HEX = /^#([0-9a-fA-F]{6})$/;
const RGBA = /^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)$/;

function parseColor(value, where) {
  const hex = HEX.exec(value);
  if (hex) {
    const int = parseInt(hex[1], 16);
    return { r: (int >> 16) & 255, g: (int >> 8) & 255, b: int & 255, a: 1 };
  }
  const rgba = RGBA.exec(value);
  if (rgba) {
    const [, r, g, b, a] = rgba;
    if ([r, g, b].some((c) => Number(c) > 255) || Number(a) > 1) {
      fail(`${where}: "${value}" is out of range.`);
    }
    return { r: Number(r), g: Number(g), b: Number(b), a: Number(a) };
  }
  fail(`${where}: "${value}" is not #RRGGBB or rgba(r, g, b, a).`);
}

const channelLuminance = (c) => {
  const s = c / 255;
  return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
};

const luminance = ({ r, g, b }) =>
  0.2126 * channelLuminance(r) + 0.7152 * channelLuminance(g) + 0.0722 * channelLuminance(b);

// Alpha-composite a translucent foreground onto an opaque background before
// measuring, so a focus ring is judged by how it actually renders.
const over = (fg, bg) => ({
  r: fg.a * fg.r + (1 - fg.a) * bg.r,
  g: fg.a * fg.g + (1 - fg.a) * bg.g,
  b: fg.a * fg.b + (1 - fg.a) * bg.b,
  a: 1,
});

function contrastRatio(fg, bg) {
  const a = luminance(fg.a < 1 ? over(fg, bg) : fg);
  const b = luminance(bg);
  const [hi, lo] = a > b ? [a, b] : [b, a];
  return (hi + 0.05) / (lo + 0.05);
}

// Dart's Color packs alpha first: 0xAARRGGBB. Alpha arrives as 0-1, channels as 0-255.
const argbHex = ({ r, g, b, a }) =>
  `0x${[a * 255, r, g, b]
    .map((c) => Math.round(c).toString(16).padStart(2, "0"))
    .join("")
    .toUpperCase()}`;

const num = (value) => (Number.isInteger(value) ? `${value}.0` : `${value}`);

// ------------------------------------------------------------------ loading

const raw = readFileSync(SOURCE, "utf8");
let tokens;
try {
  tokens = JSON.parse(raw);
} catch (error) {
  fail(`tokens.json is not valid JSON — ${error.message}`);
}

for (const group of Object.keys(tokens)) {
  if (!KNOWN_GROUPS.has(group)) {
    fail(`unknown group "${group}". Add it to KNOWN_GROUPS or remove it.`);
  }
}

// ----------------------------------------------------------------- contrast

const colorAt = (path) => {
  const [group, name] = path.split(".");
  const value = tokens[group]?.[name];
  if (typeof value !== "string") fail(`contrast pair references unknown color "${path}".`);
  return parseColor(value, `contrast:${path}`);
};

const contrastRows = [];
for (const pair of tokens.contrast ?? []) {
  const ratio = contrastRatio(colorAt(pair.fg), colorAt(pair.bg));
  const ok = ratio >= pair.min;
  contrastRows.push({ ...pair, ratio, ok });
  if (!ok) {
    fail(
      `contrast ${pair.fg} on ${pair.bg} is ${ratio.toFixed(2)}:1, needs ${pair.min}:1 (${pair.why})`,
    );
  }
}

// -------------------------------------------------------------------- emit

const lines = {
  css: [
    `/* ${BANNER} */`,
    "",
    ":root {",
  ],
  dart: [
    `// ${BANNER}`,
    "",
    "import 'package:flutter/material.dart';",
    "",
    "/// Design tokens shared with the React console.",
    "///",
    "/// Values come from packages/design-tokens/tokens.json.",
    "abstract final class DukaanTokens {",
  ],
};

const tsTree = {};
const push = (group, name, cssValue, dartLine, tsValue) => {
  lines.css.push(`  --${kebab(group)}-${kebab(name)}: ${cssValue};`);
  tsTree[group] ??= {};
  tsTree[group][name] = tsValue;
  if (dartLine) lines.dart.push(`  ${dartLine}`);
};

// font
lines.css.push("  /* font */");
lines.dart.push("  // Fonts");
for (const [name, value] of Object.entries(tokens.font)) {
  const pascal = name[0].toUpperCase() + name.slice(1);
  // Keep generated Dart already `dart format`-clean (80 columns) so running the
  // formatter never makes the drift check fail. A long font stack is the only
  // value here that overflows, and Dart wraps it after the `=`.
  const oneLine = `  static const font${pascal} = '${value}';`;
  lines.dart.push(
    ...(oneLine.length <= 80
      ? [oneLine]
      : [
          `  static const font${pascal} =`,
          `      '${value}';`,
        ]),
  );
  push("font", name, value, null, value);
}
lines.css.push("");

// color
lines.css.push("  /* color */");
lines.dart.push("", "  // Colors");
for (const [name, value] of Object.entries(tokens.color)) {
  const color = parseColor(value, `color.${name}`);
  push(
    "color",
    name,
    color.a === 1 ? value.toUpperCase() : `rgba(${color.r}, ${color.g}, ${color.b}, ${color.a})`,
    `static const color${name[0].toUpperCase()}${name.slice(1)} = Color(${argbHex(color)});`,
    value,
  );
}
lines.css.push("");

// numeric scales
for (const group of ["space", "radius", "size"]) {
  lines.css.push(`  /* ${group} */`);
  lines.dart.push("", `  // ${group[0].toUpperCase()}${group.slice(1)}`);
  for (const [name, value] of Object.entries(tokens[group])) {
    if (typeof value !== "number") fail(`${group}.${name} must be a number.`);
    const pascal = name[0].toUpperCase() + name.slice(1);
    push(
      group,
      name,
      `${value}px`,
      `static const ${group}${pascal} = ${num(value)};`,
      value,
    );
  }
  lines.css.push("");
}

// shadow — structural so both platforms can build real elevation
lines.css.push("  /* shadow */");
lines.dart.push("", "  // Shadow");
for (const [name, shadow] of Object.entries(tokens.shadow)) {
  const color = parseColor(shadow.color, `shadow.${name}.color`);
  const css = `${shadow.x}px ${shadow.y}px ${shadow.blur}px ${shadow.spread}px rgba(${color.r}, ${color.g}, ${color.b}, ${color.a})`;
  push("shadow", name, css, null, { ...shadow });
  const pascal = name[0].toUpperCase() + name.slice(1);
  lines.dart.push(
    `  static const List<BoxShadow> shadow${pascal} = <BoxShadow>[`,
    `    BoxShadow(`,
    `      color: Color(${argbHex(color)}),`,
    `      offset: Offset(${num(shadow.x)}, ${num(shadow.y)}),`,
    `      blurRadius: ${num(shadow.blur)},`,
    `      spreadRadius: ${num(shadow.spread)},`,
    `    ),`,
    `  ];`,
    "",
  );
}
lines.css.push("");

// motion
lines.css.push("  /* motion */");
lines.dart.push("  // Motion");
{
  const { easing, exitRatio, ...durations } = tokens.motion;
  for (const [name, value] of Object.entries(durations)) {
    push("motion", name, `${value}ms`, `static const motion${name[0].toUpperCase()}${name.slice(1)} = Duration(milliseconds: ${value});`, value);
  }
  const easeCss = `cubic-bezier(${easing.join(", ")})`;
  push("motion", "ease", easeCss, `static const motionEase = Cubic(${easing.join(", ")});`, easeCss);
  lines.css.push(`  --motion-exit-ratio: ${exitRatio};`);
  lines.dart.push(`  static const motionExitRatio = ${num(exitRatio)};`);
  tsTree.motion ??= {};
  tsTree.motion.exitRatio = exitRatio;
}
lines.css.push("");

// type
lines.css.push("  /* type */");
lines.dart.push("", "  // Type");
for (const [name, spec] of Object.entries(tokens.type)) {
  const { size, lineHeight, weight, tracking, mono } = spec;
  if (![size, lineHeight, weight, tracking].every((v) => typeof v === "number")) {
    fail(`type.${name} needs numeric size, lineHeight, weight and tracking.`);
  }
  if (weight % 100 !== 0 || weight < 100 || weight > 900) {
    fail(`type.${name}.weight must be a multiple of 100 between 100 and 900.`);
  }
  const family = mono ? "var(--font-mono-stack)" : "var(--font-sans-stack)";
  lines.css.push(
    `  --type-${kebab(name)}-size: ${size}px;`,
    `  --type-${kebab(name)}-line: ${lineHeight};`,
    `  --type-${kebab(name)}-weight: ${weight};`,
    `  --type-${kebab(name)}-tracking: ${tracking}em;`,
    `  --type-${kebab(name)}-family: ${family};`,
  );
  const pascal = name[0].toUpperCase() + name.slice(1);
  // The Latin UI face has no Devanagari glyphs, so every non-mono style carries
  // the bundled Devanagari family as a fallback. Without this in the TextStyle
  // itself, Hindi silently renders from a system font and the two clients stop
  // matching. A fallback declared on ThemeData does not reach explicit styles.
  lines.dart.push(
    `  static const TextStyle text${pascal} = TextStyle(`,
    `    fontFamily: ${mono ? "fontMonoFamily" : "fontSansFamily"},`,
    ...(mono
      ? []
      : [`    fontFamilyFallback: <String>[fontDevanagariFamily],`]),
    `    fontSize: ${num(size)},`,
    `    height: ${lineHeight},`,
    `    fontWeight: FontWeight.w${weight},`,
    `    letterSpacing: ${(tracking * size).toFixed(2)},`,
    `  );`,
    "",
  );
  tsTree.type ??= {};
  tsTree.type[name] = spec;
}
lines.css.push("");

lines.css.push("}");
lines.css.push("");
// Drop the trailing blank that each type style leaves behind, so the closing
// brace sits directly after the last member the way dart format wants it.
while (lines.dart.at(-1) === "") lines.dart.pop();
lines.dart.push("}");

// ------------------------------------------------------------------ verify

const expected = {
  css: lines.css.join("\n"),
  ts: [
    `// ${BANNER}`,
    "",
    "export const tokens = " + JSON.stringify(tsTree, null, 2) + " as const;",
    "",
    "export type Tokens = typeof tokens;",
    "",
  ].join("\n"),
  dart: lines.dart.join("\n") + "\n",
};

const check = process.argv.includes("--check");

if (check) {
  const stale = [];
  for (const [kind, path] of Object.entries(TARGETS)) {
    let actual = null;
    try {
      actual = readFileSync(path, "utf8");
    } catch {
      stale.push(`${relative(ROOT, path)} — missing`);
      continue;
    }
    if (actual !== expected[kind]) stale.push(`${relative(ROOT, path)} — out of date`);
  }
  if (stale.length) {
    console.error("\n  Generated token files are stale:\n");
    for (const entry of stale) console.error(`    ${entry}`);
    console.error("\n  Run: make tokens-generate\n");
    process.exit(1);
  }
  console.log(`  tokens: ${contrastRows.length} contrast pairs pass, generated files are up to date.`);
} else {
  for (const [kind, path] of Object.entries(TARGETS)) {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, expected[kind], "utf8");
    console.log(`  wrote ${relative(ROOT, path)}`);
  }
  const lowest = contrastRows.reduce((min, row) => (row.ratio < min.ratio ? row : min));
  console.log(
    `  ${contrastRows.length} contrast pairs pass; lowest is ${lowest.ratio.toFixed(2)}:1 (${lowest.fg} on ${lowest.bg}).`,
  );
}
