#!/usr/bin/env python3
"""Generate AICodeReview artifacts from canonical SKILL.md files."""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OBSOLETE = ("cursor.mdc", "copilot.md", "gemini.md", "aider.md")
DISPLAY_OVERRIDES = {
    "api-design-review": "API Design Review",
    "ci-review": "CI Review",
    "graphql-review": "GraphQL Review",
    "ios-review": "iOS Review",
    "kmp-review": "Kotlin Multiplatform Review",
    "pr-summary": "Pull Request Summary",
    "react-native-review": "React Native Review",
    "tech-debt-audit": "Technical Debt Audit",
}


class ArtifactError(RuntimeError):
    pass


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent, text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(content)
        os.replace(temp, path)
    except Exception:
        try:
            os.unlink(temp)
        except FileNotFoundError:
            pass
        raise


def skill_names(root: Path) -> list[str]:
    names = sorted(path.name for path in (root / "skills").iterdir() if path.is_dir())
    if not names:
        raise ArtifactError("no skill directories found")
    return names


def parse_skill(root: Path, name: str) -> tuple[str, str]:
    path = root / "skills" / name / "SKILL.md"
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError as exc:
        raise ArtifactError(f"missing {path}") from exc

    if not lines or lines[0] != "---":
        raise ArtifactError(f"{path} must start with YAML frontmatter")
    try:
        end = lines.index("---", 1)
    except ValueError as exc:
        raise ArtifactError(f"{path} has no closing frontmatter fence") from exc

    frontmatter: dict[str, str] = {}
    for line in lines[1:end]:
        key, separator, value = line.partition(":")
        if separator:
            frontmatter[key.strip()] = value.strip().strip("\"'")
    if frontmatter.get("name") != name:
        raise ArtifactError(f"{path} name must match directory {name}")
    description = frontmatter.get("description", "")
    if not description:
        raise ArtifactError(f"{path} has an empty description")

    body = "\n".join(lines[end + 1 :]).strip()
    if not body:
        raise ArtifactError(f"{path} has an empty body")
    return description, body


def display_name(name: str) -> str:
    return DISPLAY_OVERRIDES.get(name, " ".join(part.capitalize() for part in name.split("-")))


def interface_values(name: str) -> tuple[str, str, str]:
    display = display_name(name)
    short = f"Run the {display} workflow"
    prompt = f"Use ${name} to apply this workflow to the current repository."
    if not 25 <= len(short) <= 64:
        raise ArtifactError(f"{name}: generated short description has invalid length")
    return display, short, prompt


def render_openai(name: str) -> str:
    display, short, prompt = interface_values(name)
    quote = lambda value: json.dumps(value, ensure_ascii=False)
    return (
        "interface:\n"
        f"  display_name: {quote(display)}\n"
        f"  short_description: {quote(short)}\n"
        f"  default_prompt: {quote(prompt)}\n"
    )


def render_cursor(root: Path, name: str) -> str:
    description, body = parse_skill(root, name)
    return (
        "---\n"
        f"description: {json.dumps(description, ensure_ascii=False)}\n"
        "globs: []\n"
        "alwaysApply: false\n"
        "---\n\n"
        f"{body.rstrip()}\n"
    )


def strip_h1(body: str) -> str:
    lines = body.splitlines()
    if lines and lines[0].startswith("# "):
        lines = lines[1:]
        while lines and not lines[0].strip():
            lines = lines[1:]
    return "\n".join(lines).strip()


def render_aider(root: Path, names: list[str]) -> str:
    parts = [
        "# AICodeReview",
        "",
        "Generated from canonical `SKILL.md` files. This file is managed by AICodeReview.",
        "",
        "Apply only the workflow requested by the user. Review and audit workflows remain read-only unless the user explicitly asks for changes.",
    ]
    for name in names:
        description, body = parse_skill(root, name)
        parts.extend(["", f"## {display_name(name)}", "", description, "", strip_h1(body)])
    return "\n".join(parts).rstrip() + "\n"


def validate(root: Path, reject_obsolete: bool = True) -> list[str]:
    names = skill_names(root)
    for name in names:
        parse_skill(root, name)
        interface_values(name)
        if reject_obsolete:
            for filename in OBSOLETE:
                path = root / "skills" / name / "agents" / filename
                if path.exists():
                    raise ArtifactError(f"obsolete generated adapter remains: {path.relative_to(root)}")
    return names


def sync_openai(root: Path, write: bool) -> int:
    names = validate(root, reject_obsolete=False)
    stale: list[Path] = []
    for name in names:
        target = root / "skills" / name / "agents" / "openai.yaml"
        expected = render_openai(name)
        actual = target.read_text(encoding="utf-8") if target.exists() else ""
        if actual != expected:
            stale.append(target)
            if write:
                atomic_write(target, expected)
    if stale and not write:
        for path in stale:
            print(f"STALE: {path.relative_to(root)}", file=sys.stderr)
        return 1
    print(f"{'Updated' if write else 'Verified'} OpenAI metadata for {len(names)} skills.")
    return 0


def write_output(content: str, output: str | None) -> None:
    if output:
        atomic_write(Path(output), content)
    else:
        sys.stdout.write(content)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    sub = parser.add_subparsers(dest="command", required=True)

    sync = sub.add_parser("sync-openai")
    mode = sync.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--write", action="store_true")

    sub.add_parser("validate")

    cursor = sub.add_parser("render-cursor")
    cursor.add_argument("--skill", required=True)
    cursor.add_argument("--output")

    aider = sub.add_parser("render-aider")
    aider.add_argument("--output")

    args = parser.parse_args()
    root = args.root.resolve()

    try:
        if args.command == "sync-openai":
            return sync_openai(root, args.write)
        names = validate(root)
        if args.command == "validate":
            print(f"Validated {len(names)} canonical skills.")
            return 0
        if args.command == "render-cursor":
            if args.skill not in names:
                raise ArtifactError(f"unknown skill: {args.skill}")
            write_output(render_cursor(root, args.skill), args.output)
            return 0
        if args.command == "render-aider":
            write_output(render_aider(root, names), args.output)
            return 0
        raise ArtifactError(f"unsupported command: {args.command}")
    except ArtifactError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
