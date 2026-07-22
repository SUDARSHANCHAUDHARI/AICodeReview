#!/usr/bin/env node

import { existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

interface ExpectedFinding { id: string; severity: string; required: boolean; }
interface Fixture { id: string; path: string; skill: string; prompt: string; expected: ExpectedFinding[]; forbidden?: string[]; }
interface Manifest { version: number; fixtures: Fixture[]; }
interface ResultFinding { id: string; severity?: string; }
interface FixtureResult { id: string; findings: ResultFinding[]; }
interface Results { fixtures: FixtureResult[]; }

function root(): string { return resolve(process.env.AICODEREVIEW_ROOT || join(__dirname, '..')); }
function fail(message: string): never { throw new Error(message); }
function manifest(): Manifest {
  const file = join(root(), 'evals', 'manifest.json');
  const data = JSON.parse(readFileSync(file, 'utf8')) as Manifest;
  if (data.version !== 1 || !Array.isArray(data.fixtures)) fail('Invalid evaluation manifest');
  const fixtureIds = new Set<string>();
  for (const fixture of data.fixtures) {
    if (!fixture.id || !fixture.path || !fixture.skill || !fixture.prompt) fail(`Invalid fixture: ${fixture.id || '(unknown)'}`);
    if (fixtureIds.has(fixture.id)) fail(`Duplicate fixture id: ${fixture.id}`);
    fixtureIds.add(fixture.id);
    if (!existsSync(join(root(), 'evals', fixture.path))) fail(`Missing fixture path: ${fixture.path}`);
    const ids = new Set<string>();
    for (const finding of fixture.expected) {
      if (ids.has(finding.id)) fail(`Duplicate expected finding ${finding.id} in ${fixture.id}`);
      ids.add(finding.id);
    }
  }
  return data;
}
function score(resultsPath: string): void {
  const plan = manifest();
  const results = JSON.parse(readFileSync(resolve(resultsPath), 'utf8')) as Results;
  const byFixture = new Map((results.fixtures || []).map((entry) => [entry.id, entry]));
  let tp = 0, fp = 0, fn = 0, severityMatches = 0, severityTotal = 0;
  for (const fixture of plan.fixtures) {
    const reported = byFixture.get(fixture.id)?.findings || [];
    const expected = new Map(fixture.expected.map((finding) => [finding.id, finding]));
    const seen = new Set<string>();
    for (const finding of reported) {
      const target = expected.get(finding.id);
      if (target) {
        if (!seen.has(finding.id)) {
          tp += 1;
          seen.add(finding.id);
          if (finding.severity) {
            severityTotal += 1;
            if (finding.severity === target.severity) severityMatches += 1;
          }
        }
      } else fp += 1;
    }
    for (const target of fixture.expected) if (target.required && !seen.has(target.id)) fn += 1;
  }
  const precision = tp + fp ? tp / (tp + fp) : 1;
  const recall = tp + fn ? tp / (tp + fn) : 1;
  const severityAccuracy = severityTotal ? severityMatches / severityTotal : 1;
  console.log(JSON.stringify({ truePositives: tp, falsePositives: fp, falseNegatives: fn, precision, recall, severityAccuracy }, null, 2));
}
export function main(argv = process.argv.slice(2)): number {
  try {
    if (!argv.length || argv.includes('--help')) {
      console.log('Usage: aicodereview eval --list | --validate | --results <results.json>');
      return 0;
    }
    if (argv[0] === '--list') {
      for (const fixture of manifest().fixtures) console.log(`${fixture.id.padEnd(24)} ${fixture.skill}  ${fixture.path}`);
    } else if (argv[0] === '--validate') {
      console.log(`Validated ${manifest().fixtures.length} evaluation fixtures.`);
    } else if (argv[0] === '--results') {
      if (!argv[1]) fail('--results requires a JSON file');
      score(argv[1]);
    } else fail(`Unknown eval option: ${argv[0]}`);
    return 0;
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
}
if (require.main === module) process.exitCode = main();
