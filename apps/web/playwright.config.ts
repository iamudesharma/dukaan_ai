import { defineConfig } from "@playwright/test";

const webBase = process.env.DUKAAN_WEB_URL ?? "http://127.0.0.1:4174";

export default defineConfig({
  testDir: "./e2e",
  timeout: 60_000,
  retries: process.env.CI ? 1 : 0,
  use: {
    baseURL: webBase,
    channel: "chrome",
    headless: true,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
  },
  webServer: process.env.DUKAAN_NO_WEBSERVER
    ? undefined
    : {
        command: "npm run dev -- --port 4174 --strictPort",
        url: webBase,
        reuseExistingServer: false,
        timeout: 90_000,
      },
});
