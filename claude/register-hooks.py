#!/usr/bin/env python3
"""Register the tmux pane-registry hook in ~/.claude/settings.json.

settings.json is not tracked in this repo -- it holds machine-specific and
private values (API key helpers, internal endpoints), so setup.sh merges the
hook entries in rather than symlinking a checked-in file over it.

Idempotent: a hook whose command already mentions claude-pane-registry.py is
left alone, so re-running setup.sh never duplicates entries. Refuses to touch
a settings.json it cannot parse, so a hand-edit typo is never silently eaten.
"""

import json
import os
import sys

HOOK_SCRIPT = "claude-pane-registry.py"
EVENTS = ("SessionStart", "SessionEnd")


def settings_path():
    return os.path.join(os.path.expanduser("~"), ".claude", "settings.json")


def load(path):
    """Returns (data, ok). ok is False when the file exists but is unusable."""
    if not os.path.exists(path):
        return {}, True
    try:
        with open(path) as handle:
            text = handle.read()
    except OSError as exc:
        print("register-hooks: cannot read %s: %s" % (path, exc), file=sys.stderr)
        return {}, False

    if not text.strip():
        return {}, True

    try:
        data = json.loads(text)
    except ValueError as exc:
        print("register-hooks: %s is not valid JSON (%s);" % (path, exc), file=sys.stderr)
        print("register-hooks: refusing to overwrite it. Fix it and re-run.", file=sys.stderr)
        return {}, False

    if not isinstance(data, dict):
        print("register-hooks: %s is not a JSON object; skipping." % path, file=sys.stderr)
        return {}, False
    return data, True


def already_registered(groups):
    """True when any hook in any group already runs our script."""
    for group in groups:
        if not isinstance(group, dict):
            continue
        for hook in group.get("hooks", []):
            if isinstance(hook, dict) and HOOK_SCRIPT in str(hook.get("command", "")):
                return True
    return False


def main():
    path = settings_path()
    data, ok = load(path)
    if not ok:
        return 1

    command = "python3 %s" % os.path.join(
        os.path.expanduser("~"), ".claude", "hooks", HOOK_SCRIPT
    )
    entry = {"hooks": [{"type": "command", "command": command, "async": True}]}

    hooks = data.setdefault("hooks", {})
    if not isinstance(hooks, dict):
        print("register-hooks: settings.json 'hooks' is not an object; skipping.", file=sys.stderr)
        return 1

    changed = False
    for event in EVENTS:
        groups = hooks.setdefault(event, [])
        if not isinstance(groups, list):
            print("register-hooks: 'hooks.%s' is not a list; skipping." % event, file=sys.stderr)
            return 1
        if already_registered(groups):
            continue
        groups.append(json.loads(json.dumps(entry)))
        changed = True

    if not changed:
        print("Claude pane-registry hook already registered.")
        return 0

    os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)
    tmp = path + ".tmp"
    try:
        with open(tmp, "w") as handle:
            json.dump(data, handle, indent=2)
            handle.write("\n")
        os.replace(tmp, path)
    except OSError as exc:
        print("register-hooks: failed to write %s: %s" % (path, exc), file=sys.stderr)
        try:
            os.remove(tmp)
        except OSError:
            pass
        return 1

    print("Registered Claude pane-registry hook in %s" % path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
