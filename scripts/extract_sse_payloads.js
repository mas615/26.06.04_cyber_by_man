#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

function usage() {
  console.error("Usage: node extract_sse_payloads.js --in <raw-sse.txt> --out-dir <dir>");
  process.exit(2);
}

const args = process.argv.slice(2);
let inputPath = null;
let outDir = null;

for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--in") {
    inputPath = args[++i];
  } else if (args[i] === "--out-dir") {
    outDir = args[++i];
  } else {
    usage();
  }
}

if (!inputPath || !outDir) usage();

const raw = fs.readFileSync(inputPath, "utf8");
const lines = raw.split(/\r?\n/);

let currentEvent = null;
let currentData = [];
const apiTraceObjects = [];

function flushEvent() {
  if (currentEvent !== "api_trace" || currentData.length === 0) {
    currentEvent = null;
    currentData = [];
    return;
  }

  const dataText = currentData.join("\n");
  try {
    apiTraceObjects.push(JSON.parse(dataText));
  } catch {
    // Ignore non-JSON trace fragments. The payload extraction must stay exact.
  }

  currentEvent = null;
  currentData = [];
}

for (const line of lines) {
  if (line === "") {
    flushEvent();
    continue;
  }

  if (line.startsWith("event:")) {
    flushEvent();
    currentEvent = line.slice("event:".length).trim();
    currentData = [];
    continue;
  }

  if (line.startsWith("data:")) {
    currentData.push(line.slice("data:".length).trimStart());
  }
}
flushEvent();

let requestPayload = null;
let responsePayload = null;

for (const item of apiTraceObjects) {
  if (item && item.payload && item.payload.request) {
    requestPayload = item.payload.request;
  }
  if (item && item.payload && item.payload.response) {
    responsePayload = item.payload.response;
  }
}

fs.mkdirSync(outDir, { recursive: true });

let wrote = 0;
if (requestPayload) {
  fs.writeFileSync(path.join(outDir, "request.json"), JSON.stringify(requestPayload, null, 2) + "\n", "utf8");
  wrote += 1;
}

if (responsePayload) {
  fs.writeFileSync(path.join(outDir, "response.json"), JSON.stringify(responsePayload, null, 2) + "\n", "utf8");
  wrote += 1;
}

if (wrote === 0) {
  console.error("No data.payload.request or data.payload.response values found.");
  process.exit(1);
}

console.log(`Wrote ${wrote} payload file(s) to ${outDir}`);
