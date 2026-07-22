#!/usr/bin/env node
'use strict';

const path = require('node:path');
const runtime = path.join(__dirname, '..', 'dist', 'runtime.js');

try {
  const { main } = require(runtime);
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  if (error && error.code === 'MODULE_NOT_FOUND') {
    console.error('AICodeReview CLI is not built. Run `npm install && npm run build`.');
  } else {
    console.error(error instanceof Error ? error.message : String(error));
  }
  process.exitCode = 1;
}
