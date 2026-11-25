#!/usr/bin/env node
// One-off bootstrap: download and prepare the self-hosted font files for both clients.
//
//   node packages/design-tokens/scripts/fetch-fonts.mjs
//
// Web gets Google's subset woff2 with unicode-range, so Hindi and Latin never
// download each other. Flutter cannot read woff2 and resolves families by weight,
// so it gets a static, subsetted TTF per weight: variable sources are instanced
// with fonttools, which also writes OS/2.usWeightClass where Flutter looks.
//
// Re-run only when a family, weight or subset changes. The output is committed.

import { mkdirSync, writeFileSync, existsSync, rmSync } from "node:fs";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const WEB_DIR = resolve(ROOT, "apps/web/public/fonts");
const MOBILE_DIR = resolve(ROOT, "apps/mobile/assets/fonts");
const WORK = join(tmpdir(), `dukaan-fonts-${process.pid}`);

const MODERN_UA =
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const GITHUB = "https://raw.githubusercontent.com/google/fonts/main";

// Latin basic + Latin extended (carries U+20B9 ₹) + the punctuation the UI uses.
const LATIN = [
  "U+0000-00FF", "U+0131", "U+0152-0153", "U+02BB-02BC", "U+02C6", "U+02DA", "U+02DC",
  "U+0304", "U+0308", "U+0329", "U+2000-206F", "U+20A0-20BF", "U+2122",
  "U+2191", "U+2193", "U+2212", "U+2215", "U+FEFF", "U+FFFD",
].join(",");

// Devanagari block + extended + Vedic, with ZWNJ/ZWJ which shaping depends on.
const DEVANAGARI = [
  "U+0900-097F", "U+1CD0-1CF9", "U+A8E0-A8FF", "U+200C-200D", "U+25CC",
].join(",");

const FAMILIES = [
  {
    // Variable source; a static instance is cut for each weight.
    stack: "Manrope",
    slug: "manrope",
    googleFamily: "Manrope",
    webSubsets: ["latin", "latin-ext"],
    source: `${GITHUB}/ofl/manrope/Manrope%5Bwght%5D.ttf`,
    axes: (weight) => [`wght=${weight}`],
    weights: [400, 500, 600, 700, 800],
    unicodes: LATIN,
  },
  {
    stack: "IBMPlexMono",
    slug: "plex-mono",
    googleFamily: "IBM Plex Mono",
    webSubsets: ["latin", "latin-ext"],
    // Already a static family, so no instancing is needed.
    statics: {
      400: `${GITHUB}/ofl/ibmplexmono/IBMPlexMono-Regular.ttf`,
      500: `${GITHUB}/ofl/ibmplexmono/IBMPlexMono-Medium.ttf`,
    },
    weights: [400, 500],
    unicodes: LATIN,
  },
  {
    // Pin wdth to 100 so the wght instances sit on the normal-width axis.
    stack: "NotoSansDevanagari",
    slug: "noto-devanagari",
    googleFamily: "Noto Sans Devanagari",
    webSubsets: ["devanagari", "latin"],
    source: `${GITHUB}/ofl/notosansdevanagari/NotoSansDevanagari%5Bwdth%2Cwght%5D.ttf`,
    axes: (weight) => ["wdth=100", `wght=${weight}`],
    weights: [400, 500, 600, 700],
    unicodes: `${LATIN},${DEVANAGARI}`,
  },
];

const fetchBuffer = async (url, ua = MODERN_UA) => {
  const response = await fetch(url, { headers: { "User-Agent": ua } });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`);
  return Buffer.from(await response.arrayBuffer());
};

const download = async (url, path, ua) => {
  if (existsSync(path)) return "cached";
  const buffer = await fetchBuffer(url, ua);
  writeFileSync(path, buffer);
  return `${(buffer.length / 1024).toFixed(0)}kB`;
};

// Google's css2 prefixes every block with a /* subset */ comment; the legacy
// endpoint returns bare blocks. Both are handled here.
const parseCss = (css) => {
  const out = [];
  const pattern = /(?:\/\*\s*([a-z0-9-]+)\s*\*\/\s*)?@font-face\s*\{([^}]*)\}/g;
  for (const [, subset = null, body] of css.matchAll(pattern)) {
    const weight = Number(/font-weight:\s*(\d+)/.exec(body)?.[1] ?? 0);
    const url = /url\((https:[^)]+?)\)/.exec(body)?.[1];
    const range = /unicode-range:\s*([^;]+);/.exec(body)?.[1]?.trim();
    if (url && weight) out.push({ subset, weight, url, range });
  }
  return out;
};

const fonttools = (module, args) => {
  const result = spawnSync(
    "uv",
    ["run", "--quiet", "--with", "fonttools", "python", "-m", `fontTools.${module}`, ...args],
    { encoding: "utf8" },
  );
  if (result.status !== 0) {
    throw new Error(`fontTools.${module} failed:\n${result.stderr || result.stdout}`);
  }
};

const instance = (source, axes, out) => {
  fonttools("varLib.instancer", [source, ...axes, "--output", out]);
};

const subset = (source, unicodes, out) => {
  fonttools("subset", [source, `--unicodes=${unicodes}`, "--layout-features=*", "--output-file=" + out]);
};

mkdirSync(WEB_DIR, { recursive: true });
mkdirSync(MOBILE_DIR, { recursive: true });
mkdirSync(WORK, { recursive: true });

const blocks = [];

for (const family of FAMILIES) {
  // ---- web: Google's own subset woff2, with unicode-range preserved ----
  const source = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(family.googleFamily)}:wght@${family.weights.join(";")}&display=swap`;
  const css = (await fetchBuffer(source)).toString("utf8");
  for (const record of parseCss(css)) {
    if (!family.webSubsets.includes(record.subset)) continue;
    const file = `${family.slug}-${record.subset}-${record.weight}.woff2`;
    const size = await download(record.url, resolve(WEB_DIR, file));
    blocks.push(
      [
        "@font-face {",
        `  font-family: "${family.stack}";`,
        "  font-style: normal;",
        `  font-weight: ${record.weight};`,
        "  font-display: swap;",
        `  src: url("/fonts/${file}") format("woff2");`,
        `  unicode-range: ${record.range};`,
        "}",
      ].join("\n"),
    );
    console.log(`web  ${file.padEnd(38)} ${size}`);
  }

  // ---- mobile: one static, subsetted TTF per weight ----
  const sourceFont = resolve(WORK, `${family.slug}-source.ttf`);
  if (family.statics) {
    for (const weight of family.weights) {
      const from = family.statics[weight];
      if (!from) throw new Error(`${family.slug} has no static file for weight ${weight}`);
      const raw = resolve(WORK, `${family.slug}-${weight}-raw.ttf`);
      if (!existsSync(raw)) writeFileSync(raw, await fetchBuffer(from));
      const out = resolve(MOBILE_DIR, `${family.slug}-${weight}.ttf`);
      subset(raw, family.unicodes, out);
    }
  } else {
    if (!existsSync(sourceFont)) writeFileSync(sourceFont, await fetchBuffer(family.source));
    for (const weight of family.weights) {
      const instanced = resolve(WORK, `${family.slug}-${weight}.ttf`);
      instance(sourceFont, family.axes(weight), instanced);
      subset(instanced, family.unicodes, resolve(MOBILE_DIR, `${family.slug}-${weight}.ttf`));
    }
  }

  const { readdirSync, statSync } = await import("node:fs");
  for (const file of readdirSync(MOBILE_DIR).filter((f) => f.startsWith(`${family.slug}-`))) {
    const bytes = statSync(resolve(MOBILE_DIR, file)).size;
    console.log(`apk  ${file.padEnd(38)} ${(bytes / 1024).toFixed(0)}kB`);
  }
}

writeFileSync(
  resolve(ROOT, "apps/web/src/styles/fonts.css"),
  [
    "/* Self-hosted woff2. See packages/design-tokens/scripts/fetch-fonts.mjs. */",
    "/* unicode-range keeps Devanagari and Latin from downloading each other. */",
    "",
    blocks.join("\n\n"),
    "",
  ].join("\n"),
);

rmSync(WORK, { recursive: true, force: true });
console.log(`\nwrote apps/web/src/styles/fonts.css (${blocks.length} @font-face rules)`);
