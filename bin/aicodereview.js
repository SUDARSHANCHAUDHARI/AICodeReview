#!/usr/bin/env node
'use strict';

const path = require('node:path');
const args = process.argv.slice(2);
const command = args[0];
const moduleName = command === 'hooks' ? 'hooks' : command === 'eval' ? 'eval' : 'runtime';
const moduleArgs = moduleName === 'runtime' ? args : args.slice(1);
const compiled = path.join(__dirname, '..', 'dist', `${moduleName}.js`);

try {
  const { main } = require(compiled);
  process.exitCode = main(moduleArgs);
} catch (error) {
  if (error && error.code === 'MODULE_NOT_FOUND') {
    console.error('AICodeReview CLI is not built. Run `npm install && npm run build`.');
  } else {
    console.error(error instanceof Error ? error.message : String(error));
  }
  process.exitCode = 1;
}
