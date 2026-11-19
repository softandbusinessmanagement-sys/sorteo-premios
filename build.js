const fs = require("node:fs");
const path = require("node:path");

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Set SUPABASE_URL and SUPABASE_ANON_KEY before building.");
}

const outputDirectory = path.join(__dirname, "dist");
fs.rmSync(outputDirectory, { recursive: true, force: true });
fs.mkdirSync(outputDirectory, { recursive: true });
fs.copyFileSync(path.join(__dirname, "index.html"), path.join(outputDirectory, "index.html"));
fs.writeFileSync(
  path.join(outputDirectory, "config.js"),
  `window.APP_CONFIG = ${JSON.stringify({ supabaseUrl, supabaseAnonKey })};\n`
);
