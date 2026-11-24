// GENERATED FILE — DO NOT EDIT. Source: packages/design-tokens/tokens.json. Regenerate: make tokens-generate

export const tokens = {
  "font": {
    "sansStack": "\"Manrope\", \"NotoSansDevanagari\", system-ui, -apple-system, \"Segoe UI\", sans-serif",
    "sansFamily": "Manrope",
    "monoStack": "\"IBMPlexMono\", ui-monospace, SFMono-Regular, Menlo, monospace",
    "monoFamily": "IBMPlexMono",
    "devanagariStack": "\"NotoSansDevanagari\", sans-serif",
    "devanagariFamily": "NotoSansDevanagari"
  },
  "color": {
    "canvas": "#F7F5F0",
    "surface": "#FFFFFF",
    "surfaceSunken": "#F2EFE9",
    "line": "#E5E1D8",
    "lineStrong": "#D3CEC2",
    "borderControl": "#828B82",
    "ink": "#16211B",
    "inkMuted": "#4E5952",
    "inkFaint": "#67716A",
    "primary": "#1B6B4C",
    "primaryStrong": "#14523A",
    "primaryWash": "#E6F0E9",
    "primaryInk": "#12442F",
    "onPrimary": "#FFFFFF",
    "positive": "#1B6B4C",
    "positiveWash": "#E6F0E9",
    "positiveInk": "#12442F",
    "attention": "#8F5608",
    "attentionWash": "#FAF0D9",
    "attentionInk": "#6E4106",
    "danger": "#A6392B",
    "dangerWash": "#FAE9E5",
    "dangerInk": "#7F2A1F",
    "onDanger": "#FFFFFF",
    "hero": "#15211A",
    "heroRaised": "#1E2C24",
    "onHero": "#EEF3EE",
    "onHeroMuted": "#A9B7AC",
    "heroAccent": "#7CCFA6",
    "focusRing": "rgba(27, 107, 76, 0.72)",
    "focusRingOnHero": "#7CCFA6",
    "scrim": "rgba(13, 22, 17, 0.52)"
  },
  "space": {
    "1": 4,
    "2": 8,
    "3": 12,
    "4": 16,
    "5": 20,
    "6": 24,
    "8": 32,
    "10": 40,
    "12": 48,
    "16": 64
  },
  "radius": {
    "xs": 6,
    "control": 10,
    "card": 14,
    "panel": 18,
    "sheet": 22,
    "pill": 999
  },
  "size": {
    "hit": 48,
    "control": 44,
    "controlCompact": 36,
    "tile": 40,
    "avatar": 36,
    "railWidth": 264,
    "topbar": 74,
    "bottomNav": 68,
    "contentMax": 1540
  },
  "shadow": {
    "raised": {
      "x": 0,
      "y": 1,
      "blur": 3,
      "spread": 0,
      "color": "rgba(22, 33, 27, 0.06)"
    },
    "overlay": {
      "x": 0,
      "y": 18,
      "blur": 48,
      "spread": -8,
      "color": "rgba(22, 33, 27, 0.2)"
    }
  },
  "motion": {
    "fast": 120,
    "base": 180,
    "slow": 260,
    "ease": "cubic-bezier(0.2, 0.7, 0.3, 1)",
    "exitRatio": 0.7
  },
  "type": {
    "display": {
      "size": 36,
      "lineHeight": 1.1,
      "weight": 800,
      "tracking": -0.02
    },
    "title": {
      "size": 26,
      "lineHeight": 1.2,
      "weight": 700,
      "tracking": -0.02
    },
    "heading": {
      "size": 19,
      "lineHeight": 1.3,
      "weight": 700,
      "tracking": -0.01
    },
    "subhead": {
      "size": 17,
      "lineHeight": 1.4,
      "weight": 600,
      "tracking": 0
    },
    "body": {
      "size": 15,
      "lineHeight": 1.55,
      "weight": 400,
      "tracking": 0
    },
    "label": {
      "size": 13,
      "lineHeight": 1.4,
      "weight": 600,
      "tracking": 0.01
    },
    "caption": {
      "size": 11,
      "lineHeight": 1.35,
      "weight": 600,
      "tracking": 0.08
    },
    "amount": {
      "size": 15,
      "lineHeight": 1.4,
      "weight": 500,
      "tracking": 0,
      "mono": true
    },
    "amountLarge": {
      "size": 22,
      "lineHeight": 1.25,
      "weight": 500,
      "tracking": -0.01,
      "mono": true
    }
  }
} as const;

export type Tokens = typeof tokens;
