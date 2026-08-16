#!/usr/bin/env bash
# Layman — skill-only install.
#
# Symlinks skills/layman into ~/.claude/skills/. That gives you /layman and
# persistent levels, but NOT always-on: you invoke it per session.
#
# For always-on, install as a plugin instead so the SessionStart hook runs.
# See README.md — the two paths are alternatives, not steps.
#
# Idempotent. Anything already at the target that is not a symlink is moved
# aside rather than deleted; an unlinked directory may hold the only copy of an
# edit that never reached git.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS="$CLAUDE/skills"
TARGET="$SKILLS/layman"

mkdir -p "$SKILLS"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
    ATTIC="$CLAUDE/layman-prelink-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$ATTIC"
    mv "$TARGET" "$ATTIC/layman"
    echo "moved aside $TARGET -> $ATTIC/layman"
    echo "  ⚠ compare it against $SRC/skills/layman before deleting it"
fi

ln -sfn "$SRC/skills/layman" "$TARGET"
echo "linked $TARGET"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/layman"
mkdir -p "$CONFIG_DIR"

if [ ! -e "$CONFIG_DIR/levels" ]; then
    printf 'plainness=plain\ndensity=lite\n' > "$CONFIG_DIR/levels"
    echo "wrote defaults to $CONFIG_DIR/levels"
else
    echo "kept existing $CONFIG_DIR/levels"
fi

cat <<EOF

Installed. Start a session and type /layman to see your levels and change them.

Optional — teach it your vocabulary so it never explains terms you already use:
  \$EDITOR $CONFIG_DIR/known-vocabulary     (one term per line, # for comments)

This install does NOT make layman always-on. For that, install as a plugin so
the SessionStart hook runs — see README.md.
EOF
