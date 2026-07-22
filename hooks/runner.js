#!/usr/bin/env node
'use strict';

const { mkdirSync, readFileSync, writeFileSync } = require('node:fs');
const { spawnSync } = require('node:child_process');
const { isAbsolute, join, resolve } = require('node:path');

function gitResult(args) {
  return spawnSync('git', args, { cwd: process.cwd(), encoding: 'utf8' });
}

function git(args) {
  const result = gitResult(args);
  if (result.error) return `unavailable: ${result.error.message}`;
  return `${result.stdout || ''}${result.stderr || ''}`.trim() || '(clean)';
}

function reportDirectory() {
  const result = gitResult(['rev-parse', '--git-dir']);
  if (!result.error && result.status === 0 && result.stdout.trim()) {
    const gitDir = result.stdout.trim();
    return join(isAbsolute(gitDir) ? gitDir : resolve(process.cwd(), gitDir), 'aicodereview', 'reports');
  }
  return join(process.cwd(), '.aicodereview', 'reports');
}

function input() {
  try {
    const raw = readFileSync(0, 'utf8').trim();
    return raw ? JSON.parse(raw) : {};
  } catch (error) {
    console.error(`AICodeReview hook input warning: ${error.message}`);
    return {};
  }
}

function report(event, payload) {
  const directory = reportDirectory();
  mkdirSync(directory, { recursive: true });
  const timestamp = new Date().toISOString();
  const branch = git(['branch', '--show-current']);
  const status = git(['status', '--short']);
  const diffCheck = event === 'agent-stop' ? git(['diff', '--check']) : '(not run at session start)';
  const body = [
    '# AICodeReview lifecycle report',
    '',
    `- Event: ${event}`,
    `- Timestamp: ${timestamp}`,
    `- Branch: ${branch}`,
    payload.session_id || payload.sessionId ? `- Session: ${payload.session_id || payload.sessionId}` : '',
    '',
    '## Git status',
    '',
    '```text',
    status,
    '```',
    '',
    '## Diff check',
    '',
    '```text',
    diffCheck,
    '```',
    '',
    'This report records deterministic repository state only. It is not an AI code review.',
    '',
  ].filter(Boolean).join('\n');
  writeFileSync(join(directory, event === 'session-start' ? 'session-start.md' : 'latest.md'), body, 'utf8');
}

try {
  report(process.argv[2] || 'agent-stop', input());
} catch (error) {
  console.error(`AICodeReview hook warning: ${error.message}`);
}

process.stdout.write('{}\n');
