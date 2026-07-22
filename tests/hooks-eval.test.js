'use strict';

const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const { existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve } = require('node:path');
const test = require('node:test');

const ROOT = resolve(__dirname, '..');
const CLI = join(ROOT, 'bin', 'aicodereview.js');

function sandbox() {
  return mkdtempSync(join(tmpdir(), 'aicodereview-hooks-test-'));
}
function run(args, options = {}) {
  return spawnSync(process.execPath, [CLI, ...args], {
    cwd: options.cwd || ROOT,
    input: options.input,
    env: { ...process.env, ...(options.env || {}) },
    encoding: 'utf8',
  });
}
function runOk(args, options = {}) {
  const result = run(args, options);
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  return result;
}

test('installs documented Copilot and Gemini hook packages', () => {
  const project = sandbox();
  runOk(['hooks', 'install', '--agent', 'all', '--project', project]);

  const copilot = JSON.parse(readFileSync(join(project, '.github', 'hooks', 'aicodereview.json'), 'utf8'));
  assert.equal(copilot.version, 1);
  assert.match(copilot.hooks.agentStop[0].command, /runner\.js/);

  const gemini = JSON.parse(readFileSync(join(project, '.aicodereview', 'gemini-extension', 'hooks', 'hooks.json'), 'utf8'));
  assert.ok(gemini.hooks.SessionStart);
  assert.ok(gemini.hooks.AfterAgent);
  assert.match(gemini.hooks.AfterAgent[0].hooks[0].command, /\$\{extensionPath\}/);

  const status = runOk(['hooks', 'status', '--agent', 'all', '--project', project]);
  assert.match(status.stdout, /copilot\s+installed/);
  assert.match(status.stdout, /gemini\s+installed/);
});

test('hook runner writes a deterministic report and emits JSON only', () => {
  const project = sandbox();
  runOk(['hooks', 'install', '--agent', 'copilot', '--project', project]);
  const runner = join(project, '.aicodereview', 'hooks', 'runner.js');
  const result = spawnSync(process.execPath, [runner, 'agent-stop'], { cwd: project, input: '{}', encoding: 'utf8' });

  assert.equal(result.status, 0);
  assert.equal(result.stdout, '{}\n');
  const report = readFileSync(join(project, '.aicodereview', 'reports', 'latest.md'), 'utf8');
  assert.match(report, /deterministic repository state only/);
  assert.match(report, /## Diff check/);
});

test('hook uninstall preserves unmanaged replacements', () => {
  const project = sandbox();
  runOk(['hooks', 'install', '--agent', 'copilot', '--project', project]);
  const config = join(project, '.github', 'hooks', 'aicodereview.json');
  require('node:fs').rmSync(`${config}.aicodereview-managed`, { force: true });
  writeFileSync(config, '{"userOwned":true}\n');

  runOk(['hooks', 'uninstall', '--agent', 'copilot', '--project', project]);
  assert.equal(readFileSync(config, 'utf8'), '{"userOwned":true}\n');
});

test('validates fixtures and scores a perfect result', () => {
  const listed = runOk(['eval', '--validate']);
  assert.match(listed.stdout, /Validated 3 evaluation fixtures/);

  const root = sandbox();
  const results = join(root, 'results.json');
  writeFileSync(results, JSON.stringify({ fixtures: [
    { id: 'secret-exposure', findings: [{ id: 'hardcoded-production-secret', severity: 'P0' }] },
    { id: 'missing-authorization', findings: [{ id: 'missing-object-authorization', severity: 'P1' }] },
    { id: 'false-positive-safe', findings: [] },
  ] }));

  const score = JSON.parse(runOk(['eval', '--results', results]).stdout);
  assert.equal(score.precision, 1);
  assert.equal(score.recall, 1);
  assert.equal(score.severityAccuracy, 1);
});

test('evaluation scorer counts false positives and missed required findings', () => {
  const root = sandbox();
  const results = join(root, 'results.json');
  mkdirSync(root, { recursive: true });
  writeFileSync(results, JSON.stringify({ fixtures: [
    { id: 'secret-exposure', findings: [] },
    { id: 'missing-authorization', findings: [{ id: 'invented-style-issue', severity: 'P2' }] },
    { id: 'false-positive-safe', findings: [{ id: 'hardcoded-production-secret', severity: 'P0' }] },
  ] }));

  const score = JSON.parse(runOk(['eval', '--results', results]).stdout);
  assert.equal(score.truePositives, 0);
  assert.equal(score.falsePositives, 2);
  assert.equal(score.falseNegatives, 2);
});
