'use strict';

const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve } = require('node:path');
const test = require('node:test');

const ROOT = resolve(__dirname, '..');
const CLI = join(ROOT, 'bin', 'aicodereview.js');

function sandbox() {
  return mkdtempSync(join(tmpdir(), 'aicodereview-node-test-'));
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

test('validates canonical repository metadata', () => {
  const result = runOk(['validate']);
  assert.match(result.stdout, /Validated 31 canonical skills/);
});

test('backward-compatible flags install every generated Cursor rule', () => {
  const root = sandbox();
  const project = join(root, 'project');
  mkdirSync(project);

  runOk(['--agent', 'cursor', '--project', project]);

  assert.ok(existsSync(join(project, '.cursor', 'rules', 'code-review.mdc')));
  assert.ok(existsSync(join(project, '.cursor', 'rules', 'onboarding-writer.mdc')));
  assert.match(readFileSync(join(project, '.cursor', 'rules', 'code-review.mdc'), 'utf8'), /# Code Review/);
});

test('Aider installs a compact catalog and selective canonical skills', () => {
  const root = sandbox();
  const project = join(root, 'project');
  mkdirSync(project);

  runOk(['install', '--agent', 'aider', '--project', project]);

  const catalog = readFileSync(join(project, 'AICODEREVIEW.md'), 'utf8');
  assert.match(catalog, /\/read \.aicodereview\/skills\/<skill-name>\/SKILL\.md/);
  assert.ok(catalog.split(/\r?\n/).length < 100);
  assert.ok(existsSync(join(project, '.aicodereview', 'skills', 'code-review', 'SKILL.md')));
  assert.ok(existsSync(join(project, '.aicodereview', 'skills', 'onboarding-writer', 'SKILL.md')));
  assert.match(readFileSync(join(project, '.aider.conf.yml'), 'utf8'), /AICODEREVIEW\.md/);
});

test('force backs up unmanaged native conflicts', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const conflict = join(project, '.github', 'skills', 'code-review');
  mkdirSync(conflict, { recursive: true });
  writeFileSync(join(conflict, 'custom.txt'), 'user-owned\n');

  runOk(['install', '--agent', 'copilot', '--project', project, '--force']);

  const parent = join(project, '.github', 'skills');
  const backup = readdirSync(parent).find((name) => name.startsWith('code-review.aicodereview-backup-'));
  assert.ok(backup);
  assert.equal(readFileSync(join(parent, backup, 'custom.txt'), 'utf8'), 'user-owned\n');
});

test('force backs up an orphan unmanaged file marker', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const rules = join(project, '.cursor', 'rules');
  const marker = join(rules, 'code-review.mdc.aicodereview-managed');
  mkdirSync(rules, { recursive: true });
  writeFileSync(marker, 'user-owned marker\n');

  runOk(['install', '--agent', 'cursor', '--project', project, '--force']);

  const backup = readdirSync(rules).find((name) => name.startsWith('code-review.mdc.aicodereview-managed.aicodereview-backup-'));
  assert.ok(backup);
  assert.equal(readFileSync(join(rules, backup), 'utf8'), 'user-owned marker\n');
  assert.ok(existsSync(join(rules, 'code-review.mdc')));
});

test('legacy migration preserves user-owned content and outer whitespace', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const instructions = join(project, '.github', 'copilot-instructions.md');
  mkdirSync(join(project, '.github'), { recursive: true });
  writeFileSync(instructions, [
    '',
    '  Keep this user instruction.  ',
    '',
    '# >>> AICodeReview START <<<',
    'Legacy review context.',
    '# >>> AICodeReview END <<<',
    '',
    '  Keep this trailing instruction.  ',
    '',
  ].join('\n'));

  runOk(['install', '--agent', 'copilot', '--project', project]);

  const result = readFileSync(instructions, 'utf8');
  assert.ok(result.startsWith('\n  Keep this user instruction.  '));
  assert.ok(result.endsWith('  Keep this trailing instruction.  \n'));
  assert.doesNotMatch(result, /AICodeReview START/);
});

test('all-agent preflight prevents partial global installation', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const claude = join(root, 'claude');
  const codex = join(root, 'codex');
  mkdirSync(project);
  writeFileSync(join(project, 'GEMINI.md'), '# >>> AICodeReview START <<<\ncorrupt\n');

  const result = run(['install', '--agent', 'all', '--project', project], {
    CLAUDE_HOME: claude,
    CODEX_HOME: codex,
  });

  assert.equal(result.status, 1);
  assert.ok(!existsSync(join(claude, 'skills', 'code-review')));
  assert.ok(!existsSync(join(codex, 'skills', 'code-review')));
  assert.ok(!existsSync(join(project, '.cursor', 'rules', 'code-review.mdc')));
});

test('uninstall removes an orphan managed file marker', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const marker = join(project, '.cursor', 'rules', 'code-review.mdc.aicodereview-managed');
  mkdirSync(join(project, '.cursor', 'rules'), { recursive: true });
  writeFileSync(marker, 'source=SUDARSHANCHAUDHARI/AICodeReview\nitem=cursor-rule:code-review\n');

  runOk(['uninstall', '--agent', 'cursor', '--project', project]);

  assert.ok(!existsSync(marker));
});

test('uninstall removes only ownership-marked content', () => {
  const root = sandbox();
  const project = join(root, 'project');
  const claude = join(root, 'claude');
  const codex = join(root, 'codex');
  mkdirSync(project);

  runOk(['install', '--agent', 'all', '--project', project], {
    CLAUDE_HOME: claude,
    CODEX_HOME: codex,
  });

  const unmanaged = join(project, '.aicodereview', 'skills', 'user-owned');
  mkdirSync(unmanaged, { recursive: true });
  writeFileSync(join(unmanaged, 'keep.txt'), 'keep\n');

  runOk(['uninstall', '--agent', 'all', '--project', project], {
    CLAUDE_HOME: claude,
    CODEX_HOME: codex,
  });

  assert.ok(!existsSync(join(claude, 'skills', 'code-review')));
  assert.ok(!existsSync(join(codex, 'skills', 'code-review')));
  assert.ok(!existsSync(join(project, '.github', 'skills', 'code-review')));
  assert.ok(!existsSync(join(project, 'AICODEREVIEW.md')));
  assert.equal(readFileSync(join(unmanaged, 'keep.txt'), 'utf8'), 'keep\n');
});
