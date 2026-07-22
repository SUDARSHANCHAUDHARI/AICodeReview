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
import { homedir } from 'node:os';
import { dirname, join, resolve } from 'node:path';

const SOURCE = 'SUDARSHANCHAUDHARI/AICodeReview';
const DIR_MARKER = '.aicodereview-managed';
const FILE_MARKER_SUFFIX = '.aicodereview-managed';
const LEGACY_START = '# >>> AICodeReview START <<<';
const LEGACY_END = '# >>> AICodeReview END <<<';
const AIDER_START = '# >>> AICodeReview Aider read START <<<';
const AIDER_END = '# <<< AICodeReview Aider read END <<<';
const OBSOLETE = ['cursor.mdc', 'copilot.md', 'gemini.md', 'aider.md'];
const AGENTS = ['global', 'claude', 'codex', 'cursor', 'copilot', 'gemini', 'opencode', 'aider', 'all'] as const;

type Agent = (typeof AGENTS)[number];
type SectionState = 'absent' | 'unmanaged' | 'managed' | 'corrupt';

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
  aicodereview validate
  aicodereview generate [--check | --write]

Backward compatible:
  aicodereview --agent claude
  aicodereview --agent all --project /path/to/project

Agents:
  global, claude, codex, cursor, copilot, gemini, opencode, aider, all

Requirements:
  Node.js 18 or later. Bash and Python are not required for these commands.`;
}

function fail(message: string): never {
  throw new Error(message);
}

function parseArgs(argv: string[]): { command: string; options: CliOptions } {
  const args = [...argv];
  let command = 'install';
  if (args[0] && !args[0].startsWith('-')) command = args.shift()!;

  const options: CliOptions = {
    agent: 'global',
    dryRun: false,
    force: false,
    write: false,
  };

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
    } else if (arg === '--dry-run') {
      options.dryRun = true;
    } else if (arg === '--force') {
      options.force = true;
    } else if (arg === '--write') {
      options.write = true;
    } else if (arg === '--check') {
      options.write = false;
    } else if (arg === '--help' || arg === '-h') {
      console.log(usage());
      process.exit(0);
    } else {
      fail(`Unknown option: ${arg}`);
    }
  }

  return { command, options };
}

function readText(path: string): string {
  return readFileSync(path, 'utf8');
}

function atomicWrite(path: string, content: string): void {
  mkdirSync(dirname(path), { recursive: true });
  const nonce = `${process.pid}-${Math.random().toString(16).slice(2)}`;
  const temp = `${path}.aicodereview-tmp-${nonce}`;
  const previous = `${path}.aicodereview-old-${nonce}`;
  writeFileSync(temp, content, 'utf8');

  let movedPrevious = false;
  try {
    if (existsSync(path)) {
      rmSync(previous, { force: true });
      renameSync(path, previous);
      movedPrevious = true;
    }
    renameSync(temp, path);
    if (movedPrevious) rmSync(previous, { force: true });
  } catch (error) {
    rmSync(temp, { force: true });
    if (existsSync(path)) rmSync(path, { force: true });
    if (movedPrevious && existsSync(previous)) renameSync(previous, path);
    throw error;
  }
}

function skills(root: string): SkillData[] {
  const skillsRoot = join(root, 'skills');
  if (!existsSync(skillsRoot)) fail(`Missing skills directory: ${skillsRoot}`);

  const names = readdirSync(skillsRoot)
    .filter((name) => statSync(join(skillsRoot, name)).isDirectory())
    .sort();
  if (!names.length) fail('No skills found');

  return names.map((name) => parseSkill(root, name));
}

function parseSkill(root: string, name: string): SkillData {
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name)) fail(`Invalid skill name: ${name}`);
  const path = join(root, 'skills', name, 'SKILL.md');
  if (!existsSync(path)) fail(`Missing ${path}`);
  const lines = readText(path).split(/\r?\n/);
  if (lines[0] !== '---') fail(`${path} must start with YAML frontmatter`);
  const end = lines.indexOf('---', 1);
  if (end < 0) fail(`${path} has no closing frontmatter fence`);

  const metadata: Record<string, string> = {};
  for (const line of lines.slice(1, end)) {
    const index = line.indexOf(':');
    if (index > 0) metadata[line.slice(0, index).trim()] = line.slice(index + 1).trim().replace(/^['"]|['"]$/g, '');
  }

  if (metadata.name !== name) fail(`${path} name must match directory ${name}`);
  if (!metadata.description) fail(`${path} has an empty description`);
  if (metadata.description.length > 1024) fail(`${path} description exceeds 1,024 characters`);

  const body = lines.slice(end + 1).join('\n').trim();
  if (!body) fail(`${path} has an empty body`);
  return { name, description: metadata.description, body, path: dirname(path) };
}

function displayName(name: string): string {
  return DISPLAY_OVERRIDES[name] || name.split('-').map((part) => part[0].toUpperCase() + part.slice(1)).join(' ');
}

function renderOpenAi(skill: SkillData): string {
  const display = displayName(skill.name);
  const short = `Run the ${display} workflow`;
  if (short.length < 25 || short.length > 64) fail(`${skill.name}: invalid generated short description length`);
  const prompt = `Use $${skill.name} to apply this workflow to the current repository.`;
  return [
    'interface:',
    `  display_name: ${JSON.stringify(display)}`,
    `  short_description: ${JSON.stringify(short)}`,
    `  default_prompt: ${JSON.stringify(prompt)}`,
    '',
  ].join('\n');
}

function renderCursor(skill: SkillData): string {
  return [
    '---',
    `description: ${JSON.stringify(skill.description)}`,
    'globs: []',
    'alwaysApply: false',
    '---',
    '',
    skill.body,
    '',
  ].join('\n');
}

function renderAiderCatalog(allSkills: SkillData[]): string {
  const lines = [
    '# AICodeReview',
    '',
    'Compact workflow catalog generated from canonical `SKILL.md` files.',
    '',
    '## Activate a workflow',
    '',
    'Load only the workflow needed for the current task:',
    '',
    '`/read .aicodereview/skills/<skill-name>/SKILL.md`',
    '',
    'Example:',
    '',
    '`/read .aicodereview/skills/code-review/SKILL.md`',
    '',
    'Then ask Aider to use that workflow by name.',
    '',
    '## Shared rules',
    '',
    '- Inspect repository state and relevant files before making claims.',
    '- Keep review and audit workflows read-only unless the user explicitly requests changes.',
    '- Preserve secrets, signing material, private data, and user-owned configuration.',
    '',
    '## Available workflows',
  ];
  for (const skill of allSkills) lines.push(`- \`${skill.name}\`: ${skill.description}`);
  return `${lines.join('\n')}\n`;
}

function validateRepository(root: string): SkillData[] {
  const allSkills = skills(root);
  for (const skill of allSkills) {
    const agentsDir = join(skill.path, 'agents');
    for (const obsolete of OBSOLETE) {
      if (existsSync(join(agentsDir, obsolete))) fail(`Obsolete adapter remains: ${skill.name}/agents/${obsolete}`);
    }
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

function isManagedDir(path: string): boolean {
  const marker = join(path, DIR_MARKER);
  return existsSync(marker) && readText(marker).includes(`source=${SOURCE}`);
}

function isManagedFile(path: string): boolean {
  const marker = markerForFile(path);
  return existsSync(marker) && readText(marker).includes(`source=${SOURCE}`);
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
  const hasDestination = existsSync(path);
  const hasMarker = existsSync(marker);
  if ((hasDestination || hasMarker) && !isManagedFile(path) && !force) {
    fail(`${path} or its ownership marker exists and is not managed by AICodeReview. Use --force to back it up.`);
  }
}

function installDirectory(source: string, destination: string, skill: string, force: boolean, dryRun: boolean): void {
  if (existsSync(destination) && !force) {
    console.log(`Skipping ${skill}; already present (use --force to update)`);
    return;
  }
  if (dryRun) {
    console.log(`${existsSync(destination) ? 'Would update' : 'Would install'} ${skill} -> ${destination}`);
    return;
  }

  mkdirSync(dirname(destination), { recursive: true });
  const temp = `${destination}.aicodereview-tmp-${process.pid}-${Math.random().toString(16).slice(2)}`;
  rmSync(temp, { recursive: true, force: true });
  cpSync(source, temp, { recursive: true });
  writeFileSync(join(temp, DIR_MARKER), `source=${SOURCE}\nskill=${skill}\n`, 'utf8');

  let previous = '';
  let keepPrevious = false;
  if (existsSync(destination)) {
    if (isManagedDir(destination)) previous = `${destination}.aicodereview-old-${process.pid}`;
    else {
      previous = backupPath(destination);
      keepPrevious = true;
    }
    rmSync(previous, { recursive: true, force: true });
    renameSync(destination, previous);
  }

  try {
    renameSync(temp, destination);
  } catch (error) {
    rmSync(temp, { recursive: true, force: true });
    if (previous && existsSync(previous)) renameSync(previous, destination);
    throw error;
  }

  if (previous && !keepPrevious) rmSync(previous, { recursive: true, force: true });
  if (keepPrevious) console.log(`Backed up unmanaged destination -> ${previous}`);
  console.log(`Installed ${skill} -> ${destination}`);
}

function installFile(content: string, destination: string, item: string, force: boolean, dryRun: boolean): void {
  const destinationMarker = markerForFile(destination);
  if ((existsSync(destination) || existsSync(destinationMarker)) && !force) {
    console.log(`Skipping ${item}; already present (use --force to update)`);
    return;
  }
  if (dryRun) {
    console.log(`${existsSync(destination) || existsSync(destinationMarker) ? 'Would update' : 'Would install'} ${item} -> ${destination}`);
    return;
  }

  mkdirSync(dirname(destination), { recursive: true });
  const nonce = `${process.pid}-${Math.random().toString(16).slice(2)}`;
  const temp = `${destination}.aicodereview-tmp-${nonce}`;
  const tempMarker = markerForFile(temp);
  writeFileSync(temp, content, 'utf8');
  writeFileSync(tempMarker, `source=${SOURCE}\nitem=${item}\n`, 'utf8');

  let previous = '';
  let previousMarker = '';
  let keepPrevious = false;
  let keepPreviousMarker = false;

  if (existsSync(destination)) {
    if (isManagedFile(destination)) {
      previous = `${destination}.aicodereview-old-${nonce}`;
      previousMarker = `${destinationMarker}.old-${nonce}`;
    } else {
      previous = backupPath(destination);
      keepPrevious = true;
    }
    rmSync(previous, { force: true });
    renameSync(destination, previous);
  }

  if (existsSync(destinationMarker)) {
    if (isManagedFile(destination)) {
      if (!previousMarker) previousMarker = `${destinationMarker}.old-${nonce}`;
    } else {
      previousMarker = backupPath(destinationMarker);
      keepPreviousMarker = true;
    }
    rmSync(previousMarker, { force: true });
    renameSync(destinationMarker, previousMarker);
  }

  let installedDestination = false;
  let installedMarker = false;
  try {
    renameSync(temp, destination);
    installedDestination = true;
    renameSync(tempMarker, destinationMarker);
    installedMarker = true;
  } catch (error) {
    if (installedMarker && existsSync(destinationMarker)) rmSync(destinationMarker, { force: true });
    if (installedDestination && existsSync(destination)) rmSync(destination, { force: true });
    rmSync(temp, { force: true });
    rmSync(tempMarker, { force: true });
    if (previous && existsSync(previous)) renameSync(previous, destination);
    if (previousMarker && existsSync(previousMarker)) renameSync(previousMarker, destinationMarker);
    throw error;
  }

  if (previous && !keepPrevious) rmSync(previous, { force: true });
  if (previousMarker && !keepPreviousMarker) rmSync(previousMarker, { force: true });
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
  if (dryRun) {
    console.log(`Would remove managed section from ${path}`);
    return;
  }

  const text = readText(path);
  const startIndex = text.indexOf(start);
  const endIndex = text.indexOf(end, startIndex) + end.length;
  const before = text.slice(0, startIndex);
  const after = text.slice(endIndex);
  const result = before.endsWith('\n') && after.startsWith('\n')
    ? `${before}${after.slice(1)}`
    : `${before}${after}`;

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

  if (/^read\s*:/m.test(cleaned)) {
    if (state === 'managed') removeSection(path, AIDER_START, AIDER_END, dryRun);
    if (!cleaned.includes('AICODEREVIEW.md')) console.log('Aider has a user-managed read setting; add AICODEREVIEW.md to it manually.');
    return;
  }

  const block = `${AIDER_START}\nread:\n  - AICODEREVIEW.md\n${AIDER_END}\n`;
  if (dryRun) {
    console.log(`Would configure Aider catalog in ${path}`);
    return;
  }
  const output = current.trim() ? `${current.trimEnd()}\n\n${block}` : block;
  atomicWrite(path, output);
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
  if (agent === 'claude') return join(process.env.CLAUDE_HOME || join(homePath(), '.claude'), 'skills');
  return join(process.env.CODEX_HOME || join(homePath(), '.codex'), 'skills');
}

function installNative(root: string, allSkills: SkillData[], base: string, options: CliOptions): void {
  for (const skill of allSkills) preflightDir(join(base, skill.name), options.force);
  for (const skill of allSkills) installDirectory(skill.path, join(base, skill.name), skill.name, options.force, options.dryRun);
}

function installProjectNative(root: string, allSkills: SkillData[], base: string, legacy: string | undefined, options: CliOptions): void {
  if (legacy && sectionState(legacy, LEGACY_START, LEGACY_END) === 'corrupt') fail(`Invalid AICodeReview markers in ${legacy}`);
  installNative(root, allSkills, base, options);
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

function installAider(root: string, allSkills: SkillData[], project: string, options: CliOptions): void {
  preflightAider(allSkills, project, options);
  installNative(root, allSkills, join(project, '.aicodereview', 'skills'), options);
  installFile(renderAiderCatalog(allSkills), join(project, 'AICODEREVIEW.md'), 'aider-catalog', options.force, options.dryRun);
  removeSection(join(project, 'CONVENTIONS.md'), LEGACY_START, LEGACY_END, options.dryRun);
  configureAider(project, options.dryRun);
}

function install(root: string, options: CliOptions): void {
  const allSkills = validateRepository(root);
  const projectAgents: Agent[] = ['cursor', 'copilot', 'gemini', 'opencode', 'aider', 'all'];
  const project = projectAgents.includes(options.agent) ? requireProject(options) : options.project;

  if (options.agent === 'all') {
    const p = project!;
    for (const skill of allSkills) {
      preflightDir(join(nativeBase('claude'), skill.name), options.force);
      preflightDir(join(nativeBase('codex'), skill.name), options.force);
      preflightDir(join(p, '.github', 'skills', skill.name), options.force);
      preflightDir(join(p, '.gemini', 'skills', skill.name), options.force);
      preflightDir(join(p, '.opencode', 'skills', skill.name), options.force);
    }
    preflightCursor(allSkills, p, options.force);
    preflightAider(allSkills, p, options);
    for (const legacy of [join(p, '.github', 'copilot-instructions.md'), join(p, 'GEMINI.md')]) {
      if (sectionState(legacy, LEGACY_START, LEGACY_END) === 'corrupt') fail(`Invalid AICodeReview markers in ${legacy}`);
    }
  }

  if (options.agent === 'global' || options.agent === 'all') {
    installNative(root, allSkills, nativeBase('codex'), options);
    installNative(root, allSkills, nativeBase('claude'), options);
  } else if (options.agent === 'codex') installNative(root, allSkills, nativeBase('codex'), options);
  else if (options.agent === 'claude') installNative(root, allSkills, nativeBase('claude'), options);

  if (!project) return;
  if (options.agent === 'cursor' || options.agent === 'all') installCursor(allSkills, project, options);
  if (options.agent === 'copilot' || options.agent === 'all') installProjectNative(root, allSkills, join(project, '.github', 'skills'), join(project, '.github', 'copilot-instructions.md'), options);
  if (options.agent === 'gemini' || options.agent === 'all') installProjectNative(root, allSkills, join(project, '.gemini', 'skills'), join(project, 'GEMINI.md'), options);
  if (options.agent === 'opencode' || options.agent === 'all') installProjectNative(root, allSkills, join(project, '.opencode', 'skills'), undefined, options);
  if (options.agent === 'aider' || options.agent === 'all') installAider(root, allSkills, project, options);
}

function removeDirectory(path: string, dryRun: boolean): void {
  if (!existsSync(path) || !isManagedDir(path)) return;
  if (dryRun) console.log(`Would remove ${path}`);
  else rmSync(path, { recursive: true, force: true });
}

function removeFile(path: string, dryRun: boolean): void {
  const marker = markerForFile(path);
  const managed = isManagedFile(path);
  if (!managed) return;

  if (dryRun) {
    console.log(`Would remove ${existsSync(path) ? `${path} and ` : ''}${marker}`);
    return;
  }

  rmSync(path, { force: true });
  rmSync(marker, { force: true });
}

function uninstallNative(allSkills: SkillData[], base: string, dryRun: boolean): void {
  for (const skill of allSkills) removeDirectory(join(base, skill.name), dryRun);
}

function uninstall(root: string, options: CliOptions): void {
  const allSkills = skills(root);
  const projectAgents: Agent[] = ['cursor', 'copilot', 'gemini', 'opencode', 'aider', 'all'];
  const project = projectAgents.includes(options.agent) ? requireProject(options) : options.project;

  if (options.agent === 'global' || options.agent === 'all') {
    uninstallNative(allSkills, nativeBase('codex'), options.dryRun);
    uninstallNative(allSkills, nativeBase('claude'), options.dryRun);
  } else if (options.agent === 'codex') uninstallNative(allSkills, nativeBase('codex'), options.dryRun);
  else if (options.agent === 'claude') uninstallNative(allSkills, nativeBase('claude'), options.dryRun);

  if (!project) return;
  if (options.agent === 'cursor' || options.agent === 'all') {
    for (const skill of allSkills) removeFile(join(project, '.cursor', 'rules', `${skill.name}.mdc`), options.dryRun);
  }
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
    if (!options.dryRun) {
      for (const path of [join(project, '.aicodereview', 'skills'), join(project, '.aicodereview')]) {
        try { rmdirSync(path); } catch { /* preserve non-empty user directories */ }
      }
    }
  }
}

export function main(argv = process.argv.slice(2)): number {
  try {
    if (!argv.length) {
      console.log(usage());
      return 0;
    }
    const root = repositoryRoot();
    const { command, options } = parseArgs(argv);
    if (command === 'install') install(root, options);
    else if (command === 'uninstall') uninstall(root, options);
    else if (command === 'validate') {
      const allSkills = validateRepository(root);
      console.log(`Validated ${allSkills.length} canonical skills.`);
    } else if (command === 'generate') syncMetadata(root, options.write);
    else if (command === 'help') console.log(usage());
    else fail(`Unknown command: ${command}`);
    return 0;
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
}

if (require.main === module) process.exitCode = main();
