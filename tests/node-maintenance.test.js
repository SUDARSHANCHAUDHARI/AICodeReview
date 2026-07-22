'use strict';

const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const { mkdirSync, mkdtempSync, readFileSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve } = require('node:path');
const test = require('node:test');

const ROOT = resolve(__dirname, '..');
const CLI = join(ROOT, 'bin', 'aicodereview.js');

function sandbox() {
  return mkdtempSync(join(tmpdir(), 'aicodereview-maintenance-test-'));
}

function run(args, env = {}) {
  return spawnSync(process.execPath, [CLI, ...args], {
    cwd: ROOT,
    env: { ...process.env, ...env },
    encoding: 'utf8',
  });
}

function runOk(args, env = {}) {
  const result = run(args, env);
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  return result;
}

test('list reports every installed integration', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const env = { CLAUDE_HOME: join(root, 'claude'), CODEX_HOME: join(root, 'codex') };
  mkdirSync(project);

  runOk(['install', '--agent', 'all', '--project', project], env);
  const result = runOk(['list', '--project', project], env);

  assert.match(result.stdout, /claude\s+code-review\s+installed/);
  assert.match(result.stdout, /cursor\s+onboarding-writer\s+installed/);
  assert.match(result.stdout, /aider\s+code-review\s+installed/);
});

test('health detects drift and update repairs it', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const env = { CLAUDE_HOME: join(root, 'claude'), CODEX_HOME: join(root, 'codex') };
  mkdirSync(project);

  runOk(['install', '--agent', 'all', '--project', project], env);
  runOk(['health', '--project', project], env);

  const cursorRule = join(project, '.cursor', 'rules', 'code-review.mdc');
  writeFileSync(cursorRule, `${readFileSync(cursorRule, 'utf8')}\nmanual drift\n`);

  const unhealthy = run(['health', '--project', project], env);
  assert.equal(unhealthy.status, 1);
  assert.match(unhealthy.stdout, /STALE cursor\/code-review/);

  runOk(['update', '--project', project], env);
  runOk(['health', '--project', project], env);
  assert.doesNotMatch(readFileSync(cursorRule, 'utf8'), /manual drift/);
});

test('update detects selective Aider installation without the catalog', () => {
  const root = sandbox();
  const project = join(root, 'project');
  mkdirSync(project);

  runOk(['install', '--agent', 'aider', '--project', project]);
  require('node:fs').rmSync(join(project, 'AICODEREVIEW.md'), { force: true });
  require('node:fs').rmSync(join(project, 'AICODEREVIEW.md.aicodereview-managed'), { force: true });

  const result = runOk(['update', '--project', project]);
  assert.match(result.stdout, /Detected agents: aider/);
  assert.match(readFileSync(join(project, 'AICODEREVIEW.md'), 'utf8'), /Compact workflow catalog/);
});
