#!/usr/bin/env node

import {
  cpSync,
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { createHash } from 'node:crypto';
import { homedir } from 'node:os';
import { dirname, join, relative, resolve } from 'node:path';

const SOURCE = 'SUDARSHANCHAUDHARI/AICodeReview';
const DIR_MARKER = '.aicodereview-managed';
const FILE_MARKER_SUFFIX = '.aicodereview-managed';
const LEGACY_START = '# >>> AICodeReview START <<<';
const LEGACY_END = '# >>> AICodeReview END <<<';
const AIDER_START = '# >>> AICodeReview Aider read START <<<';
const AIDER_END = '# <<< AICodeReview Aider read END <<<';
const OBSOLETE = ['cursor.mdc', 'copilot.md', 'gemini.md', 'aider.md'];
const AGENTS = ['global', 'claude', 'codex', 'cursor', 'copilot', 'gemini', 'opencode', 'aider', 'all'] as const;
const PROJECT_AGENTS = new Set<Agent>(['cursor', 'copilot', 'gemini', 'opencode', 'aider', 'all']);

type Agent = (typeof AGENTS)[number];
type SectionState = 'absent' | 'unmanaged' | 'managed' | 'corrupt';
type Status = 'installed' | 'stale' | 'legacy' | 'unmanaged' | 'missing' | 'broken';

interface CliOptions {
  agent: Agent;
  project?: string;
  dryRun: boolean;
  force: boolean;
  write: boolean;
}

interface SkillData {
  name: string;
  description: string;
  body: string;
  path: string;
}

const DISPLAY_OVERRIDES: Record<string, string> = {
  'api-design-review': 'API Design Review',
  'ci-review': 'CI Review',
  'graphql-review': 'GraphQL Review',
  'ios-review': 'iOS Review',
  'kmp-review': 'Kotlin Multiplatform Review',
  'pr-summary': 'Pull Request Summary',
  'react-native-review': 'React Native Review',
  'tech-debt-audit': 'Technical Debt Audit',
};

function repositoryRoot(): string {
  return resolve(process.env.AICODEREVIEW_ROOT || join(__dirname, '..'));
}

function usage(): string {
  return `AICodeReview cross-platform CLI

Usage:
  aicodereview install [--agent <agent>] [--project <path>] [--dry-run] [--force]
  aicodereview uninstall [--agent <agent>] [--project <path>] [--dry-run]
  aicodereview list [--project <path>]
  aicodereview health [--project <path>]
  aicodereview update [--project <path>] [--dry-run]
  aicodereview validate
  aicodereview generate [--check | --write]

Backward compatible:
  aicodereview --agent claude
  aicodereview --agent all --project /path/to/project

Agents:
  global, claude, codex, cursor, copilot, gemini, opencode, aider, all

Requirements:
  Node.js 18 or later. Bash and Python are not required.`;
}

function fail(message: string): never {
  throw new Error(message);
}

function parseArgs(argv: string[]): { command: string; options: CliOptions } {
  const args = [...argv];
  let command = 'install';
  if (args[0] && !args[0].startsWith('-')) command = args.shift()!;
  const options: CliOptions = { agent: 'global', dryRun: false, force: false, write: false };
  while (args.length) {
    const arg = args.shift()!;
    if (arg === '--agent') {
      const value = args.shift();
      if (!value || !AGENTS.includes(value as Agent)) fail(`Unknown agent: ${value || ''}`);
      options.agent = value as Agent;
    } else if (arg === '--project') {
      const value = args.shift();
      if (!value) fail('--project requires a path');
      options.project = resolve(value);
    } else if (arg === '--dry-run') options.dryRun = true;
    else if (arg === '--force') options.force = true;
    else if (arg === '--write') options.write = true;
    else if (arg === '--check') options.write = false;
    else if (arg === '--help' || arg === '-h') {
      console.log(usage());
      process.exit(0);
    } else fail(`Unknown option: ${arg}`);
  }
  return { command, options };
}

function readText(path: string): string {
  return readFileSync(path, 'utf8');
}

function nonce(): string {
  return `${process.pid}-${Math.random().toString(16).slice(2)}`;
}

function atomicWrite(path: string, content: string): void {
  mkdirSync(dirname(path), { recursive: true });
  const id = nonce();
  const temp = `${path}.aicodereview-tmp-${id}`;
  const previous = `${path}.aicodereview-old-${id}`;
  writeFileSync(temp, content, 'utf8');
  let movedPrevious = false;
  let installed = false;
  try {
    if (existsSync(path)) {
      rmSync(previous, { recursive: true, force: true });
      renameSync(path, previous);
      movedPrevious = true;
    }
    renameSync(temp, path);
    installed = true;
    if (movedPrevious) rmSync(previous, { recursive: true, force: true });
  } catch (error) {
    if (installed && existsSync(path)) rmSync(path, { recursive: true, force: true });
    rmSync(temp, { recursive: true, force: true });
    if (movedPrevious && existsSync(previous)) renameSync(previous, path);
    throw error;
  }
}

function skills(root: string): SkillData[] {
  const skillsRoot = join(root, 'skills');
  if (!existsSync(skillsRoot)) fail(`Missing skills directory: ${skillsRoot}`);
  const names = readdirSync(skillsRoot)
    .filter((name: string) => statSync(join(skillsRoot, name)).isDirectory())
    .sort();
  if (!names.length) fail('No skills found');
  return names.map((name: string) => parseSkill(root, name));
}

function parseSkill(root: string, name: string): SkillData {
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name)) fail(`Invalid skill name: ${name}`);
  const file = join(root, 'skills', name, 'SKILL.md');
  if (!existsSync(file)) fail(`Missing ${file}`);
  const lines = readText(file).split(/\r?\n/);
  if (lines[0] !== '---') fail(`${file} must start with YAML frontmatter`);
  const end = lines.indexOf('---', 1);
  if (end < 0) fail(`${file} has no closing frontmatter fence`);
  const metadata: Record<string, string> = {};
  for (const line of lines.slice(1, end)) {
    const index = line.indexOf(':');
    if (index > 0) metadata[line.slice(0, index).trim()] = line.slice(index + 1).trim().replace(/^['"]|['"]$/g, '');
  }
  if (metadata.name !== name) fail(`${file} name must match directory ${name}`);
  if (!metadata.description) fail(`${file} has an empty description`);
  if (metadata.description.length > 1024) fail(`${file} description exceeds 1,024 characters`);
  const body = lines.slice(end + 1).join('\n').trim();
  if (!body) fail(`${file} has an empty body`);
  return { name, description: metadata.description, body, path: dirname(file) };
}

function displayName(name: string): string {
  return DISPLAY_OVERRIDES[name] || name.split('-').map((part) => part[0].toUpperCase() + part.slice(1)).join(' ');
}

function renderOpenAi(skill: SkillData): string {
  const display = displayName(skill.name);
  const short = `Run the ${display} workflow`;
  if (short.length < 25 || short.length > 64) fail(`${skill.name}: invalid generated short description length`);
  return [
    'interface:',
    `  display_name: ${JSON.stringify(display)}`,
    `  short_description: ${JSON.stringify(short)}`,
    `  default_prompt: ${JSON.stringify(`Use $${skill.name} to apply this workflow to the current repository.`)}`,
    '',
  ].join('\n');
}

function renderCursor(skill: SkillData): string {
  return ['---', `description: ${JSON.stringify(skill.description)}`, 'globs: []', 'alwaysApply: false', '---', '', skill.body, ''].join('\n');
}

function renderAiderCatalog(allSkills: SkillData[]): string {
  const lines = [
    '# AICodeReview', '',
    'Compact workflow catalog generated from canonical `SKILL.md` files.', '',
    '## Activate a workflow', '',
    'Load only the workflow needed for the current task:', '',
    '`/read .aicodereview/skills/<skill-name>/SKILL.md`', '',
    'Example:', '',
    '`/read .aicodereview/skills/code-review/SKILL.md`', '',
    'Then ask Aider to use that workflow by name.', '',
    '## Shared rules', '',
    '- Inspect repository state and relevant files before making claims.',
    '- Keep review and audit workflows read-only unless the user explicitly requests changes.',
    '- Preserve secrets, signing material, private data, and user-owned configuration.', '',
    '## Available workflows',
  ];
  for (const skill of allSkills) lines.push(`- \`${skill.name}\`: ${skill.description}`);
  return `${lines.join('\n')}\n`;
}

function validateRepository(root: string): SkillData[] {
  const allSkills = skills(root);
  for (const skill of allSkills) {
    const agentsDir = join(skill.path, 'agents');
    for (const obsolete of OBSOLETE) if (existsSync(join(agentsDir, obsolete))) fail(`Obsolete adapter remains: ${skill.name}/agents/${obsolete}`);
    const metadata = join(agentsDir, 'openai.yaml');
    if (!existsSync(metadata) || readText(metadata) !== renderOpenAi(skill)) fail(`Stale OpenAI metadata: ${metadata}`);
  }
  return allSkills;
}

function syncMetadata(root: string, write: boolean): void {
  const allSkills = skills(root);
  const stale: string[] = [];
  for (const skill of allSkills) {
    const target = join(skill.path, 'agents', 'openai.yaml');
    const expected = renderOpenAi(skill);
    if (!existsSync(target) || readText(target) !== expected) {
      stale.push(target);
      if (write) atomicWrite(target, expected);
    }
  }
  if (stale.length && !write) fail(`Stale OpenAI metadata:\n${stale.join('\n')}`);
  console.log(`${write ? 'Updated' : 'Verified'} OpenAI metadata for ${allSkills.length} skills.`);
}

function markerForFile(path: string): string {
  return `${path}${FILE_MARKER_SUFFIX}`;
}

function validManagedMarker(marker: string): boolean {
  return existsSync(marker) && readText(marker).includes(`source=${SOURCE}`);
}

function isManagedDir(path: string): boolean {
  return existsSync(path) && validManagedMarker(join(path, DIR_MARKER));
}

function isManagedFile(path: string): boolean {
  return existsSync(path) && validManagedMarker(markerForFile(path));
}

function backupPath(path: string): string {
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\.\d{3}Z$/, 'Z');
  let candidate = `${path}.aicodereview-backup-${stamp}`;
  let counter = 1;
  while (existsSync(candidate)) candidate = `${path}.aicodereview-backup-${stamp}-${counter++}`;
  return candidate;
}

function preflightDir(path: string, force: boolean): void {
  if (existsSync(path) && !isManagedDir(path) && !force) fail(`${path} exists and is not managed by AICodeReview. Use --force to back it up.`);
}

function preflightFile(path: string, force: boolean): void {
  const marker = markerForFile(path);
  const destinationConflict = existsSync(path) && !isManagedFile(path);
  const markerConflict = existsSync(marker) && !validManagedMarker(marker);
  if ((destinationConflict || markerConflict) && !force) fail(`${path} or its ownership marker is unmanaged. Use --force to back it up.`);
}

function installDirectory(source: string, destination: string, skill: string, force: boolean, dryRun: boolean): void {
  if (isManagedDir(destination) && !force) {
    console.log(`Skipping ${skill}; already installed (use --force to update)`);
    return;
  }
  preflightDir(destination, force);
  if (dryRun) {
    console.log(`${existsSync(destination) ? 'Would update' : 'Would install'} ${skill} -> ${destination}`);
    return;
  }
  mkdirSync(dirname(destination), { recursive: true });
  const id = nonce();
  const temp = `${destination}.aicodereview-tmp-${id}`;
  cpSync(source, temp, { recursive: true });
  writeFileSync(join(temp, DIR_MARKER), `source=${SOURCE}\nskill=${skill}\n`, 'utf8');
  let previous = '';
  let keepPrevious = false;
  let movedPrevious = false;
  let installed = false;
  try {
    if (existsSync(destination)) {
      if (isManagedDir(destination)) previous = `${destination}.aicodereview-old-${id}`;
      else { previous = backupPath(destination); keepPrevious = true; }
      rmSync(previous, { recursive: true, force: true });
      renameSync(destination, previous);
      movedPrevious = true;
    }
    renameSync(temp, destination);
    installed = true;
    if (movedPrevious && !keepPrevious) rmSync(previous, { recursive: true, force: true });
  } catch (error) {
    if (installed && existsSync(destination)) rmSync(destination, { recursive: true, force: true });
    rmSync(temp, { recursive: true, force: true });
    if (movedPrevious && existsSync(previous)) renameSync(previous, destination);
    throw error;
  }
  if (keepPrevious) console.log(`Backed up unmanaged destination -> ${previous}`);
  console.log(`Installed ${skill} -> ${destination}`);
}

function installFile(content: string, destination: string, item: string, force: boolean, dryRun: boolean): void {
  const marker = markerForFile(destination);
  if (isManagedFile(destination) && !force) {
    console.log(`Skipping ${item}; already installed (use --force to update)`);
    return;
  }
  preflightFile(destination, force);
  if (dryRun) {
    console.log(`${existsSync(destination) || existsSync(marker) ? 'Would update' : 'Would install'} ${item} -> ${destination}`);
    return;
  }
  mkdirSync(dirname(destination), { recursive: true });
  const id = nonce();
  const temp = `${destination}.aicodereview-tmp-${id}`;
  const tempMarker = markerForFile(temp);
  writeFileSync(temp, content, 'utf8');
  writeFileSync(tempMarker, `source=${SOURCE}\nitem=${item}\n`, 'utf8');
  let previous = '';
  let previousMarker = '';
  let keepPrevious = false;
  let keepPreviousMarker = false;
  let movedPrevious = false;
  let movedPreviousMarker = false;
  let installed = false;
  let installedMarker = false;
  try {
    if (existsSync(destination)) {
      if (isManagedFile(destination)) previous = `${destination}.aicodereview-old-${id}`;
      else { previous = backupPath(destination); keepPrevious = true; }
      rmSync(previous, { recursive: true, force: true });
      renameSync(destination, previous);
      movedPrevious = true;
    }
    if (existsSync(marker)) {
      if (validManagedMarker(marker)) previousMarker = `${marker}.old-${id}`;
      else { previousMarker = backupPath(marker); keepPreviousMarker = true; }
      rmSync(previousMarker, { recursive: true, force: true });
      renameSync(marker, previousMarker);
      movedPreviousMarker = true;
    }
    renameSync(temp, destination);
    installed = true;
    renameSync(tempMarker, marker);
    installedMarker = true;
    if (movedPrevious && !keepPrevious) rmSync(previous, { recursive: true, force: true });
    if (movedPreviousMarker && !keepPreviousMarker) rmSync(previousMarker, { recursive: true, force: true });
  } catch (error) {
    if (installedMarker && existsSync(marker)) rmSync(marker, { force: true });
    if (installed && existsSync(destination)) rmSync(destination, { force: true });
    rmSync(temp, { force: true });
    rmSync(tempMarker, { force: true });
    if (movedPrevious && existsSync(previous)) renameSync(previous, destination);
    if (movedPreviousMarker && existsSync(previousMarker)) renameSync(previousMarker, marker);
    throw error;
  }
  if (keepPrevious) console.log(`Backed up unmanaged destination -> ${previous}`);
  if (keepPreviousMarker) console.log(`Backed up unmanaged ownership marker -> ${previousMarker}`);
  console.log(`Installed ${item} -> ${destination}`);
}

function sectionState(path: string, start: string, end: string): SectionState {
  if (!existsSync(path)) return 'absent';
  const text = readText(path);
  const starts = text.split(start).length - 1;
  const ends = text.split(end).length - 1;
  if (!starts && !ends) return 'unmanaged';
  if (starts !== 1 || ends !== 1 || text.indexOf(end) <= text.indexOf(start)) return 'corrupt';
  return 'managed';
}

function removeSection(path: string, start: string, end: string, dryRun: boolean): void {
  const state = sectionState(path, start, end);
  if (state === 'absent' || state === 'unmanaged') return;
  if (state === 'corrupt') fail(`Invalid AICodeReview markers in ${path}`);
  if (dryRun) { console.log(`Would remove managed section from ${path}`); return; }
  const text = readText(path);
  const startIndex = text.indexOf(start);
  const endIndex = text.indexOf(end, startIndex) + end.length;
  const before = text.slice(0, startIndex);
  const after = text.slice(endIndex);
  const result = before.endsWith('\n') && after.startsWith('\n') ? `${before}${after.slice(1)}` : `${before}${after}`;
  if (result.trim()) atomicWrite(path, result);
  else rmSync(path, { force: true });
}

function configureAider(project: string, dryRun: boolean): void {
  const path = join(project, '.aider.conf.yml');
  const state = sectionState(path, AIDER_START, AIDER_END);
  if (state === 'corrupt') fail(`Invalid AICodeReview Aider markers in ${path}`);
  const current = existsSync(path) ? readText(path) : '';
  const cleaned = state === 'managed'
    ? current.replace(new RegExp(`\\n?${escapeRegExp(AIDER_START)}[\\s\\S]*?${escapeRegExp(AIDER_END)}\\n?`), '\n')
    : current;
  if (/^\s*read\s*:/m.test(cleaned)) {
    if (state === 'managed') removeSection(path, AIDER_START, AIDER_END, dryRun);
    if (!cleaned.includes('AICODEREVIEW.md')) console.log('Aider has a user-managed read setting; add AICODEREVIEW.md to it manually.');
    return;
  }
  const block = `${AIDER_START}\nread:\n  - AICODEREVIEW.md\n${AIDER_END}\n`;
  if (dryRun) { console.log(`Would configure Aider catalog in ${path}`); return; }
  atomicWrite(path, cleaned.trim() ? `${cleaned.trimEnd()}\n\n${block}` : block);
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function requireProject(options: CliOptions): string {
  if (!options.project) fail(`--project is required for agent '${options.agent}'`);
  if (!existsSync(options.project) || !statSync(options.project).isDirectory()) fail(`Project directory does not exist: ${options.project}`);
  return options.project;
}

function homePath(): string {
  return process.env.HOME || process.env.USERPROFILE || homedir();
}

function nativeBase(agent: 'claude' | 'codex'): string {
  return join(process.env[agent === 'claude' ? 'CLAUDE_HOME' : 'CODEX_HOME'] || join(homePath(), `.${agent}`), 'skills');
}

function installNative(allSkills: SkillData[], base: string, options: CliOptions): void {
  for (const skill of allSkills) preflightDir(join(base, skill.name), options.force);
  for (const skill of allSkills) installDirectory(skill.path, join(base, skill.name), skill.name, options.force, options.dryRun);
}

function installProjectNative(allSkills: SkillData[], base: string, legacy: string | undefined, options: CliOptions): void {
  if (legacy && sectionState(legacy, LEGACY_START, LEGACY_END) === 'corrupt') fail(`Invalid AICodeReview markers in ${legacy}`);
  installNative(allSkills, base, options);
  if (legacy) removeSection(legacy, LEGACY_START, LEGACY_END, options.dryRun);
}

function preflightCursor(allSkills: SkillData[], project: string, force: boolean): void {
  for (const skill of allSkills) preflightFile(join(project, '.cursor', 'rules', `${skill.name}.mdc`), force);
}

function installCursor(allSkills: SkillData[], project: string, options: CliOptions): void {
  preflightCursor(allSkills, project, options.force);
  for (const skill of allSkills) installFile(renderCursor(skill), join(project, '.cursor', 'rules', `${skill.name}.mdc`), `cursor-rule:${skill.name}`, options.force, options.dryRun);
}

function preflightAider(allSkills: SkillData[], project: string, options: CliOptions): void {
  const legacy = join(project, 'CONVENTIONS.md');
  const config = join(project, '.aider.conf.yml');
  if (sectionState(legacy, LEGACY_START, LEGACY_END) === 'corrupt') fail(`Invalid AICodeReview markers in ${legacy}`);
  if (sectionState(config, AIDER_START, AIDER_END) === 'corrupt') fail(`Invalid AICodeReview Aider markers in ${config}`);
  for (const skill of allSkills) preflightDir(join(project, '.aicodereview', 'skills', skill.name), options.force);
  preflightFile(join(project, 'AICODEREVIEW.md'), options.force);
}

function installAider(allSkills: SkillData[], project: string, options: CliOptions): void {
  preflightAider(allSkills, project, options);
  installNative(allSkills, join(project, '.aicodereview', 'skills'), options);
  installFile(renderAiderCatalog(allSkills), join(project, 'AICODEREVIEW.md'), 'aider-catalog', options.force, options.dryRun);
  removeSection(join(project, 'CONVENTIONS.md'), LEGACY_START, LEGACY_END, options.dryRun);
  configureAider(project, options.dryRun);
}

function preflightAll(allSkills: SkillData[], project: string, options: CliOptions): void {
  for (const skill of allSkills) {
    preflightDir(join(nativeBase('claude'), skill.name), options.force);
    preflightDir(join(nativeBase('codex'), skill.name), options.force);
    preflightDir(join(project, '.github', 'skills', skill.name), options.force);
    preflightDir(join(project, '.gemini', 'skills', skill.name), options.force);
    preflightDir(join(project, '.opencode', 'skills', skill.name), options.force);
  }
  preflightCursor(allSkills, project, options.force);
  preflightAider(allSkills, project, options);
  for (const legacy of [join(project, '.github', 'copilot-instructions.md'), join(project, 'GEMINI.md')]) {
    if (sectionState(legacy, LEGACY_START, LEGACY_END) === 'corrupt') fail(`Invalid AICodeReview markers in ${legacy}`);
  }
}

function install(root: string, options: CliOptions): void {
  const allSkills = validateRepository(root);
  const project = PROJECT_AGENTS.has(options.agent) ? requireProject(options) : options.project;
  if (options.agent === 'all') preflightAll(allSkills, project!, options);
  if (options.agent === 'global' || options.agent === 'all') {
    installNative(allSkills, nativeBase('codex'), options);
    installNative(allSkills, nativeBase('claude'), options);
  } else if (options.agent === 'codex') installNative(allSkills, nativeBase('codex'), options);
  else if (options.agent === 'claude') installNative(allSkills, nativeBase('claude'), options);
  if (!project) return;
  if (options.agent === 'cursor' || options.agent === 'all') installCursor(allSkills, project, options);
  if (options.agent === 'copilot' || options.agent === 'all') installProjectNative(allSkills, join(project, '.github', 'skills'), join(project, '.github', 'copilot-instructions.md'), options);
  if (options.agent === 'gemini' || options.agent === 'all') installProjectNative(allSkills, join(project, '.gemini', 'skills'), join(project, 'GEMINI.md'), options);
  if (options.agent === 'opencode' || options.agent === 'all') installProjectNative(allSkills, join(project, '.opencode', 'skills'), undefined, options);
  if (options.agent === 'aider' || options.agent === 'all') installAider(allSkills, project, options);
}

function removeDirectory(path: string, dryRun: boolean): void {
  if (!isManagedDir(path)) return;
  if (dryRun) console.log(`Would remove ${path}`);
  else rmSync(path, { recursive: true, force: true });
}

function removeFile(path: string, dryRun: boolean): void {
  const marker = markerForFile(path);
  if (!validManagedMarker(marker)) return;
  if (dryRun) console.log(`Would remove ${existsSync(path) ? `${path} and ` : ''}${marker}`);
  else { rmSync(path, { force: true }); rmSync(marker, { force: true }); }
}

function uninstallNative(allSkills: SkillData[], base: string, dryRun: boolean): void {
  for (const skill of allSkills) removeDirectory(join(base, skill.name), dryRun);
}

function uninstall(root: string, options: CliOptions): void {
  const allSkills = skills(root);
  const project = PROJECT_AGENTS.has(options.agent) ? requireProject(options) : options.project;
  if (options.agent === 'global' || options.agent === 'all') {
    uninstallNative(allSkills, nativeBase('codex'), options.dryRun);
    uninstallNative(allSkills, nativeBase('claude'), options.dryRun);
  } else if (options.agent === 'codex') uninstallNative(allSkills, nativeBase('codex'), options.dryRun);
  else if (options.agent === 'claude') uninstallNative(allSkills, nativeBase('claude'), options.dryRun);
  if (!project) return;
  if (options.agent === 'cursor' || options.agent === 'all') for (const skill of allSkills) removeFile(join(project, '.cursor', 'rules', `${skill.name}.mdc`), options.dryRun);
  if (options.agent === 'copilot' || options.agent === 'all') {
    uninstallNative(allSkills, join(project, '.github', 'skills'), options.dryRun);
    removeSection(join(project, '.github', 'copilot-instructions.md'), LEGACY_START, LEGACY_END, options.dryRun);
  }
  if (options.agent === 'gemini' || options.agent === 'all') {
    uninstallNative(allSkills, join(project, '.gemini', 'skills'), options.dryRun);
    removeSection(join(project, 'GEMINI.md'), LEGACY_START, LEGACY_END, options.dryRun);
  }
  if (options.agent === 'opencode' || options.agent === 'all') uninstallNative(allSkills, join(project, '.opencode', 'skills'), options.dryRun);
  if (options.agent === 'aider' || options.agent === 'all') {
    uninstallNative(allSkills, join(project, '.aicodereview', 'skills'), options.dryRun);
    removeFile(join(project, 'AICODEREVIEW.md'), options.dryRun);
    removeSection(join(project, '.aider.conf.yml'), AIDER_START, AIDER_END, options.dryRun);
    removeSection(join(project, 'CONVENTIONS.md'), LEGACY_START, LEGACY_END, options.dryRun);
    if (!options.dryRun) for (const path of [join(project, '.aicodereview', 'skills'), join(project, '.aicodereview')]) try { rmdirSync(path); } catch { /* preserve non-empty user paths */ }
  }
}

function hashDirectory(path: string): string {
  const hash = createHash('sha256');
  const walk = (current: string): void => {
    for (const entry of readdirSync(current).sort()) {
      if (entry === DIR_MARKER) continue;
      const full = join(current, entry);
      const rel = relative(path, full).replace(/\\/g, '/');
      const stat = statSync(full);
      if (stat.isDirectory()) walk(full);
      else { hash.update(rel); hash.update('\0'); hash.update(readFileSync(full)); hash.update('\0'); }
    }
  };
  walk(path);
  return hash.digest('hex');
}

function nativeStatus(source: string, installed: string): Status {
  if (!existsSync(installed)) return 'missing';
  if (!isManagedDir(installed)) return 'unmanaged';
  try { return hashDirectory(source) === hashDirectory(installed) ? 'installed' : 'stale'; }
  catch { return 'broken'; }
}

function fileStatus(path: string, expected: string): Status {
  if (!existsSync(path) && !existsSync(markerForFile(path))) return 'missing';
  if (!isManagedFile(path)) return 'unmanaged';
  return readText(path) === expected ? 'installed' : 'stale';
}

function rows(root: string, project?: string): Array<[string, string, Status]> {
  const allSkills = skills(root);
  const output: Array<[string, string, Status]> = [];
  for (const [agent, base] of [['claude', nativeBase('claude')], ['codex', nativeBase('codex')]] as const) {
    for (const skill of allSkills) output.push([agent, skill.name, nativeStatus(skill.path, join(base, skill.name))]);
  }
  if (!project) return output;
  for (const skill of allSkills) output.push(['cursor', skill.name, fileStatus(join(project, '.cursor', 'rules', `${skill.name}.mdc`), renderCursor(skill))]);
  for (const [agent, base, legacy] of [
    ['copilot', join(project, '.github', 'skills'), join(project, '.github', 'copilot-instructions.md')],
    ['gemini', join(project, '.gemini', 'skills'), join(project, 'GEMINI.md')],
    ['opencode', join(project, '.opencode', 'skills'), ''],
  ] as const) {
    const legacyState = legacy ? sectionState(legacy, LEGACY_START, LEGACY_END) : 'absent';
    for (const skill of allSkills) {
      let status = nativeStatus(skill.path, join(base, skill.name));
      if (status === 'missing' && legacyState === 'managed') status = 'legacy';
      if (legacyState === 'corrupt') status = 'broken';
      output.push([agent, skill.name, status]);
    }
  }
  const catalogStatus = fileStatus(join(project, 'AICODEREVIEW.md'), renderAiderCatalog(allSkills));
  for (const skill of allSkills) {
    let status = nativeStatus(skill.path, join(project, '.aicodereview', 'skills', skill.name));
    if (status === 'installed' && catalogStatus !== 'installed') status = catalogStatus;
    output.push(['aider', skill.name, status]);
  }
  return output;
}

function listInstalled(root: string, options: CliOptions): void {
  if (options.project && (!existsSync(options.project) || !statSync(options.project).isDirectory())) fail(`Project directory does not exist: ${options.project}`);
  console.log('AGENT      SKILL                        STATUS');
  console.log('------------------------------------------------------');
  for (const [agent, skill, status] of rows(root, options.project)) console.log(`${agent.padEnd(10)} ${skill.padEnd(28)} ${status}`);
}

function health(root: string, options: CliOptions): number {
  validateRepository(root);
  if (options.project && (!existsSync(options.project) || !statSync(options.project).isDirectory())) fail(`Project directory does not exist: ${options.project}`);
  let issues = 0;
  for (const [agent, skill, status] of rows(root, options.project)) {
    if (status === 'installed' || status === 'missing') continue;
    issues += 1;
    console.log(`${status.toUpperCase()} ${agent}/${skill}`);
  }
  if (options.project) {
    const legacyChecks: Array<[string, SectionState]> = [
      ['Copilot legacy section', sectionState(join(options.project, '.github', 'copilot-instructions.md'), LEGACY_START, LEGACY_END)],
      ['Gemini legacy section', sectionState(join(options.project, 'GEMINI.md'), LEGACY_START, LEGACY_END)],
      ['Aider legacy section', sectionState(join(options.project, 'CONVENTIONS.md'), LEGACY_START, LEGACY_END)],
    ];
    for (const [label, state] of legacyChecks) {
      if (state === 'corrupt' || state === 'managed') { issues += 1; console.log(`${state.toUpperCase()} ${label}`); }
    }
    const aiderConfigState = sectionState(join(options.project, '.aider.conf.yml'), AIDER_START, AIDER_END);
    if (aiderConfigState === 'corrupt') { issues += 1; console.log('CORRUPT Aider config'); }
    const config = join(options.project, '.aider.conf.yml');
    if (existsSync(join(options.project, 'AICODEREVIEW.md')) && (!existsSync(config) || !readText(config).includes('AICODEREVIEW.md'))) {
      issues += 1;
      console.log('STALE Aider catalog is not referenced by .aider.conf.yml');
    }
  }
  if (issues) { console.log(`Health check found ${issues} issue(s).`); return 1; }
  console.log('All installed integrations are healthy.');
  return 0;
}

function detectedAgents(root: string, project?: string): Agent[] {
  const allSkills = skills(root);
  const detected: Agent[] = [];
  const anyManagedDir = (base: string): boolean => allSkills.some((skill) => isManagedDir(join(base, skill.name)));
  const anyManagedFile = (paths: string[]): boolean => paths.some((path) => isManagedFile(path));
  if (anyManagedDir(nativeBase('claude'))) detected.push('claude');
  if (anyManagedDir(nativeBase('codex'))) detected.push('codex');
  if (!project) return detected;
  if (anyManagedFile(allSkills.map((s) => join(project, '.cursor', 'rules', `${s.name}.mdc`)))) detected.push('cursor');
  if (anyManagedDir(join(project, '.github', 'skills')) || sectionState(join(project, '.github', 'copilot-instructions.md'), LEGACY_START, LEGACY_END) === 'managed') detected.push('copilot');
  if (anyManagedDir(join(project, '.gemini', 'skills')) || sectionState(join(project, 'GEMINI.md'), LEGACY_START, LEGACY_END) === 'managed') detected.push('gemini');
  if (anyManagedDir(join(project, '.opencode', 'skills'))) detected.push('opencode');
  if (anyManagedDir(join(project, '.aicodereview', 'skills')) || validManagedMarker(markerForFile(join(project, 'AICODEREVIEW.md'))) || sectionState(join(project, 'CONVENTIONS.md'), LEGACY_START, LEGACY_END) === 'managed') detected.push('aider');
  return detected;
}

function updateInstalled(root: string, options: CliOptions): void {
  if (options.project && (!existsSync(options.project) || !statSync(options.project).isDirectory())) fail(`Project directory does not exist: ${options.project}`);
  const detected = detectedAgents(root, options.project);
  if (!detected.length) { console.log('No managed installations detected.'); return; }
  console.log(`Detected agents: ${detected.join(', ')}`);
  for (const agent of detected) install(root, { ...options, agent, force: true });
  console.log('Managed installations refreshed from the current AICodeReview package.');
  console.log('To update the CLI package itself, use your package manager, for example: npm install -g aicodereview@latest');
}

export function main(argv = process.argv.slice(2)): number {
  try {
    if (!argv.length) { console.log(usage()); return 0; }
    const root = repositoryRoot();
    const { command, options } = parseArgs(argv);
    if (command === 'install') install(root, options);
    else if (command === 'uninstall') uninstall(root, options);
    else if (command === 'list') listInstalled(root, options);
    else if (command === 'health') return health(root, options);
    else if (command === 'update') updateInstalled(root, options);
    else if (command === 'validate') console.log(`Validated ${validateRepository(root).length} canonical skills.`);
    else if (command === 'generate') syncMetadata(root, options.write);
    else if (command === 'help') console.log(usage());
    else fail(`Unknown command: ${command}`);
    return 0;
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
}

if (require.main === module) process.exitCode = main();
