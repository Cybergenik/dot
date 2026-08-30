#!/usr/bin/env python3
"""Record which Claude session belongs to which tmux pane.

SessionStart writes a small record keyed by tmux pane id; SessionEnd removes it.
The registry is the source of truth for `claude-tmux-save-sessions`, which turns
these pane ids into resurrect coordinates at save time.

Pane ids are stable while the tmux server lives but are reassigned across a
restart, so nothing here is trusted after a reboot -- the save hook re-resolves
coordinates fresh each time.
"""

import json
import os
import re
import sys
import time

TMUX_PANE_RE = re.compile(r"^%\d+$")


def state_dir():
    base = os.environ.get("XDG_STATE_HOME") or os.path.join(
        os.path.expanduser("~"), ".local", "state"
    )
    path = os.path.join(base, "claude-tmux-resume", "live")
    os.makedirs(path, mode=0o700, exist_ok=True)
    return path


def main():
    pane_id = os.environ.get("TMUX_PANE", "").strip()
    if not os.environ.get("TMUX") or TMUX_PANE_RE.match(pane_id) is None:
        return 0

    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except (json.JSONDecodeError, IOError):
        return 0

    event = data.get("hook_event_name", "")
    record = os.path.join(state_dir(), pane_id.lstrip("%") + ".json")

    if event == "SessionEnd":
        try:
            os.remove(record)
        except OSError:
            pass
        return 0

    session_id = data.get("session_id") or ""
    if not session_id:
        return 0

    payload = {
        "session_id": session_id,
        "transcript_path": data.get("transcript_path", ""),
        "cwd": data.get("cwd", ""),
        "pane_id": pane_id,
        "updated": time.time(),
    }

    tmp = record + ".tmp"
    try:
        with open(tmp, "w") as handle:
            json.dump(payload, handle)
        os.replace(tmp, record)
    except OSError:
        try:
            os.remove(tmp)
        except OSError:
            pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
