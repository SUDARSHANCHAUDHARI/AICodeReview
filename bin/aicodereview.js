#!/usr/bin/env node
'use strict';

const { execSync } = require('child_process');
const path = require('path');

const installScript = path.join(__dirname, '..', 'install.sh');
const args = process.argv.slice(2).join(' ');

// Show help if no args given
if (process.argv.slice(2).length === 0) {
  console.log('AICodeReview — AI-agnostic code review skill pack\n');
  console.log('Usage:');
  console.log('  npx aicodereview --agent claude');
  console.log('  npx aicodereview --agent all --project /path/to/project');
  console.log('  npx aicodereview --dry-run');
  console.log('  npx aicodereview --help\n');
  console.log('Delegates to install.sh. Run with --help for full option list.');
  process.exit(0);
}

try {
  execSync(`bash "${installScript}" ${args}`, { stdio: 'inherit' });
} catch (err) {
  process.exit(err.status || 1);
}
