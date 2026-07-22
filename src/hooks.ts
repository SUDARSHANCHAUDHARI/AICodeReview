#!/usr/bin/env node

import { existsSync, mkdirSync, readFileSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';

const SOURCE = 'SUDARSHANCHAUDHARI/AICodeReview';
const MARKER_SUFFIX = '.aicodereview-managed';
const AGENTS = ['copilot', 'gemini', 'all'] as const;
type HookAgent = (typeof AGENTS)[number];

interface Options {
  action: 'install' | 'uninstall' | 'status';
  agent: HookAgent;
  project: string;
  force: boolean;
  dryRun: boolean;
}

function root(): string {
  return resolve(process.env.AICODEREVIEW_ROOT || join(__dirname, '..'));
}

function fail(message: string): never { throw new Error(message); }
function marker(path: string): string { return `${path}${MARKER_SUFFIX}`; }
function managed(path: string): boolean {
  return existsSync(path) && existsSync(marker(path)) && readFileSync(marker(path), 'utf8').includes(`source=${SOURCE}`);
}
function backup(path: string): string {
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\.\d{3}Z$/, 'Z');
  let candidate = `${path}.aicodereview-backup-${stamp}`;
  let index = 1;
  while (existsSync(candidate)) candidate = `${path}.aicodereview-backup-${stamp}-${index++}`;
  return candidate;
}
function writeManaged(path: string, content: string, force: boolean, dryRun: boolean): void {
  if (managed(path) && !force) { console.log(`Skipping ${path}; already installed`); return; }
  if ((existsSync(path) || existsSync(marker(path))) && !managed(path) && !force) fail(`${path} is unmanaged. Use --force to back it up.`);
  if (dryRun) { console.log(`Would install ${path}`); return; }
  mkdirSync(dirname(path), { recursive: true });
  const id = `${process.pid}-${Math.random().toString(16).slice(2)}`;
  const temp = `${path}.tmp-${id}`;
  const tempMarker = marker(temp);
  writeFileSync(temp, content, 'utf8');
  writeFileSync(tempMarker, `source=${SOURCE}\nitem=hook\n`, 'utf8');
  let old = '', oldMarker = '', keepOld = false, keepMarker = false;
  try {
    if (existsSync(path)) {
      old = managed(path) ? `${path}.old-${id}` : backup(path);
      keepOld = !managed(path);
      renameSync(path, old);
    }
    if (existsSync(marker(path))) {
      oldMarker = managed(path) ? `${marker(path)}.old-${id}` : backup(marker(path));
      keepMarker = !managed(path);
      renameSync(marker(path), oldMarker);
    }
    renameSync(temp, path);
    renameSync(tempMarker, marker(path));
    if (old && !keepOld) rmSync(old, { recursive: true, force: true });
    if (oldMarker && !keepMarker) rmSync(oldMarker, { recursive: true, force: true });
  } catch (error) {
    rmSync(temp, { recursive: true, force: true });
    rmSync(tempMarker, { recursive: true, force: true });
    if (existsSync(path)) rmSync(path, { recursive: true, force: true });
    if (existsSync(marker(path))) rmSync(marker(path), { recursive: true, force: true });
    if (old && existsSync(old)) renameSync(old, path);
    if (oldMarker && existsSync(oldMarker)) renameSync(oldMarker, marker(path));
    throw error;
  }
  if (keepOld) console.log(`Backed up unmanaged file -> ${old}`);
  if (keepMarker) console.log(`Backed up unmanaged marker -> ${oldMarker}`);
  console.log(`Installed ${path}`);
}
function removeManaged(path: string, dryRun: boolean): void {
  if (!managed(path)) return;
  if (dryRun) { console.log(`Would remove ${path}`); return; }
  rmSync(path, { recursive: true, force: true });
  rmSync(marker(path), { recursive: true, force: true });
  console.log(`Removed ${path}`);
}
function parse(argv: string[]): Options {
  const args = [...argv];
  const action = (args.shift() || 'status') as Options['action'];
  if (!['install', 'uninstall', 'status'].includes(action)) fail(`Unknown hooks action: ${action}`);
  let agent: HookAgent = 'all';
  let project = '';
  let force = false;
  let dryRun = false;
  while (args.length) {
    const arg = args.shift()!;
    if (arg === '--agent') {
      const value = args.shift();
      if (!value || !AGENTS.includes(value as HookAgent)) fail(`Unknown hook agent: ${value || ''}`);
      agent = value as HookAgent;
    } else if (arg === '--project') {
      const value = args.shift();
      if (!value) fail('--project requires a path');
      project = resolve(value);
    } else if (arg === '--force') force = true;
    else if (arg === '--dry-run') dryRun = true;
    else if (arg === '--help' || arg === '-h') {
      console.log('Usage: aicodereview hooks <install|uninstall|status> --agent <copilot|gemini|all> --project <path> [--force] [--dry-run]');
      process.exit(0);
    } else fail(`Unknown option: ${arg}`);
  }
  if (!project || !existsSync(project)) fail('--project must reference an existing directory');
  return { action, agent, project, force, dryRun };
}
function copilotConfig(): string {
  return JSON.stringify({
    version: 1,
    hooks: {
      sessionStart: [{ type: 'command', command: 'node ".aicodereview/hooks/runner.js" session-start', cwd: '.', timeoutSec: 30 }],
      agentStop: [{ type: 'command', command: 'node ".aicodereview/hooks/runner.js" agent-stop', cwd: '.', timeoutSec: 30 }],
    },
  }, null, 2) + '\n';
}
function geminiManifest(): string {
  return JSON.stringify({ name: 'aicodereview-hooks', version: '1.0.0', description: 'Optional AICodeReview repository lifecycle reports' }, null, 2) + '\n';
}
function geminiHooks(): string {
  return JSON.stringify({ hooks: {
    SessionStart: [{ matcher: '*', hooks: [{ type: 'command', name: 'aicodereview-session-start', command: 'node "${extensionPath}${/}scripts${/}runner.js" session-start', timeout: 30000 }] }],
    AfterAgent: [{ matcher: '*', hooks: [{ type: 'command', name: 'aicodereview-after-agent', command: 'node "${extensionPath}${/}scripts${/}runner.js" agent-stop', timeout: 30000 }] }],
  } }, null, 2) + '\n';
}
function install(options: Options): void {
  const runner = readFileSync(join(root(), 'hooks', 'runner.js'), 'utf8');
  if (options.agent === 'copilot' || options.agent === 'all') {
    writeManaged(join(options.project, '.aicodereview', 'hooks', 'runner.js'), runner, options.force, options.dryRun);
    writeManaged(join(options.project, '.github', 'hooks', 'aicodereview.json'), copilotConfig(), options.force, options.dryRun);
  }
  if (options.agent === 'gemini' || options.agent === 'all') {
    const extension = join(options.project, '.aicodereview', 'gemini-extension');
    writeManaged(join(extension, 'gemini-extension.json'), geminiManifest(), options.force, options.dryRun);
    writeManaged(join(extension, 'hooks', 'hooks.json'), geminiHooks(), options.force, options.dryRun);
    writeManaged(join(extension, 'scripts', 'runner.js'), runner, options.force, options.dryRun);
    console.log(`Gemini extension ready. Link it with: gemini extensions link "${extension}"`);
  }
}
function uninstall(options: Options): void {
  if (options.agent === 'copilot' || options.agent === 'all') {
    removeManaged(join(options.project, '.github', 'hooks', 'aicodereview.json'), options.dryRun);
    removeManaged(join(options.project, '.aicodereview', 'hooks', 'runner.js'), options.dryRun);
  }
  if (options.agent === 'gemini' || options.agent === 'all') {
    const extension = join(options.project, '.aicodereview', 'gemini-extension');
    removeManaged(join(extension, 'gemini-extension.json'), options.dryRun);
    removeManaged(join(extension, 'hooks', 'hooks.json'), options.dryRun);
    removeManaged(join(extension, 'scripts', 'runner.js'), options.dryRun);
  }
}
function status(options: Options): void {
  const rows: Array<[string, string]> = [];
  if (options.agent === 'copilot' || options.agent === 'all') rows.push(['copilot', managed(join(options.project, '.github', 'hooks', 'aicodereview.json')) ? 'installed' : 'missing']);
  if (options.agent === 'gemini' || options.agent === 'all') rows.push(['gemini', managed(join(options.project, '.aicodereview', 'gemini-extension', 'hooks', 'hooks.json')) ? 'installed' : 'missing']);
  for (const [agent, state] of rows) console.log(`${agent.padEnd(10)} ${state}`);
}
export function main(argv = process.argv.slice(2)): number {
  try {
    const options = parse(argv);
    if (options.action === 'install') install(options);
    else if (options.action === 'uninstall') uninstall(options);
    else status(options);
    return 0;
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
}
if (require.main === module) process.exitCode = main();
