#!/usr/bin/env python3
"""Generate AICodeReview artifacts from canonical SKILL.md files."""

import argparse
import json
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
OBSOLETE = ("cursor.mdc", "copilot.md", "gemini.md", "aider.md")
SKILL_NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
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
    fd, temp = tempfile.mkstemp(prefix=".{0}.".format(path.name), dir=str(path.parent), text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(content)
        os.replace(temp, str(path))
    except Exception:
        try:
            os.unlink(temp)
        except FileNotFoundError:
            pass
        raise


def skill_names(root: Path) -> List[str]:
    skills_root = root / "skills"
    if not skills_root.is_dir():
        raise ArtifactError("missing skills directory: {0}".format(skills_root))

    names = sorted(path.name for path in skills_root.iterdir() if path.is_dir())
    if not names:
        raise ArtifactError("no skill directories found")
    return names


def parse_skill(root: Path, name: str) -> Tuple[str, str]:
    if not SKILL_NAME_PATTERN.fullmatch(name):
        raise ArtifactError("invalid skill directory name: {0}".format(name))

    path = root / "skills" / name / "SKILL.md"
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError as exc:
        raise ArtifactError("missing {0}".format(path)) from exc

    if not lines or lines[0] != "---":
        raise ArtifactError("{0} must start with YAML frontmatter".format(path))
    try:
        end = lines.index("---", 1)
    except ValueError as exc:
        raise ArtifactError("{0} has no closing frontmatter fence".format(path)) from exc

    frontmatter: Dict[str, str] = {}
    for line in lines[1:end]:
        key, separator, value = line.partition(":")
        if separator:
            frontmatter[key.strip()] = value.strip().strip("\"'")

    if frontmatter.get("name") != name:
        raise ArtifactError("{0} name must match directory {1}".format(path, name))

    description = frontmatter.get("description", "")
    if not description:
        raise ArtifactError("{0} has an empty description".format(path))
    if len(description) > 1024:
        raise ArtifactError("{0} description exceeds 1,024 characters".format(path))

    body = "\n".join(lines[end + 1 :]).strip()
    if not body:
        raise ArtifactError("{0} has an empty body".format(path))
    return description, body


def display_name(name: str) -> str:
    return DISPLAY_OVERRIDES.get(name, " ".join(part.capitalize() for part in name.split("-")))


def interface_values(name: str) -> Tuple[str, str, str]:
    display = display_name(name)
    short = "Run the {0} workflow".format(display)
    prompt = "Use ${0} to apply this workflow to the current repository.".format(name)
    if not 25 <= len(short) <= 64:
        raise ArtifactError("{0}: generated short description has invalid length".format(name))
    return display, short, prompt


def render_openai(name: str) -> str:
    display, short, prompt = interface_values(name)
    return (
        "interface:\n"
        "  display_name: {0}\n".format(json.dumps(display, ensure_ascii=False))
        + "  short_description: {0}\n".format(json.dumps(short, ensure_ascii=False))
        + "  default_prompt: {0}\n".format(json.dumps(prompt, ensure_ascii=False))
    )


def render_cursor(root: Path, name: str) -> str:
    description, body = parse_skill(root, name)
    return (
        "---\n"
        "description: {0}\n".format(json.dumps(description, ensure_ascii=False))
        + "globs: []\n"
        + "alwaysApply: false\n"
        + "---\n\n"
        + "{0}\n".format(body.rstrip())
    )


def strip_h1(body: str) -> str:
    lines = body.splitlines()
    if lines and lines[0].startswith("# "):
        lines = lines[1:]
        while lines and not lines[0].strip():
            lines = lines[1:]
    return "\n".join(lines).strip()


def render_aider(root: Path, names: List[str]) -> str:
    parts = [
        "# AICodeReview",
        "",
        "Generated from canonical `SKILL.md` files. This file is managed by AICodeReview.",
        "",
        "Apply only the workflow requested by the user. Review and audit workflows remain read-only unless the user explicitly asks for changes.",
    ]
    for name in names:
        description, body = parse_skill(root, name)
        parts.extend(["", "## {0}".format(display_name(name)), "", description, "", strip_h1(body)])
    return "\n".join(parts).rstrip() + "\n"


def validate(root: Path, reject_obsolete: bool = True) -> List[str]:
    names = skill_names(root)
    for name in names:
        parse_skill(root, name)
        interface_values(name)
        if reject_obsolete:
            for filename in OBSOLETE:
                path = root / "skills" / name / "agents" / filename
                if path.exists():
                    raise ArtifactError("obsolete generated adapter remains: {0}".format(path.relative_to(root)))
    return names


def sync_openai(root: Path, write: bool) -> int:
    names = validate(root, reject_obsolete=False)
    stale: List[Path] = []
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
            print("STALE: {0}".format(path.relative_to(root)), file=sys.stderr)
        return 1

    action = "Updated" if write else "Verified"
    print("{0} OpenAI metadata for {1} skills.".format(action, len(names)))
    return 0


def write_output(content: str, output: Optional[str]) -> None:
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
            print("Validated {0} canonical skills.".format(len(names)))
            return 0
        if args.command == "render-cursor":
            if args.skill not in names:
                raise ArtifactError("unknown skill: {0}".format(args.skill))
            write_output(render_cursor(root, args.skill), args.output)
            return 0
        if args.command == "render-aider":
            write_output(render_aider(root, names), args.output)
            return 0
        raise ArtifactError("unsupported command: {0}".format(args.command))
    except ArtifactError as exc:
        print("ERROR: {0}".format(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
