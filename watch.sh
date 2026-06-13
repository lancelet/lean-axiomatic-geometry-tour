#!/usr/bin/env bash
#
# Live preview. Rebuilds the site whenever a .lean or figures/*.tex file changes,
# and auto-reloads it in the browser (which it opens on startup).
#
# Run from inside the Nix dev shell (it provides lake, lualatex, watchexec, devd):
#
#     ./watch.sh
#
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

export OUT="_out/html-multi"
PORT="${PORT:-8000}"

# Regenerate the site *reliably*. Two gremlins to work around:
#   1. Lake's incremental cache occasionally "replays" a stale `Main` (the module
#      that carries the CSS), so edits silently don't reach _out and the browser
#      reloads to the old page. Deleting Main.olean forces a fresh compile. Main
#      transitively imports every chapter, so it rebuilds on any edit anyway —
#      this just guarantees the rebuild actually happens.
#   2. Site generation intermittently segfaults (flaky SubVerso) — so we retry.
# After a successful build we touch every emitted .html so devd sees one clean
# change *after* the build completes (rather than racing mid-write).
rebuild() {
  rm -f .lake/build/lib/lean/Main.olean
  for _ in 1 2 3; do
    if lake exe generate-site; then
      find "$OUT" -name '*.html' -exec touch {} +
      return 0
    fi
  done
  echo "  (build failed — fix the error and save again)"
  return 1
}
export -f rebuild

echo "▸ initial build…"
rebuild || true

# Serve $OUT with livereload. `--livewatch` watches the served tree, so each
# regeneration triggers a reload. We bind explicitly to 127.0.0.1 and open the
# browser ourselves: devd's own `--open` targets `devd.io`, which needs external DNS.
devd --livewatch --address 127.0.0.1 --port "$PORT" "$OUT" &
DEVD=$!
trap 'kill "$DEVD" 2>/dev/null || true' EXIT INT TERM

# Open the browser at localhost once the server is up.
( sleep 1; xdg-open "http://localhost:$PORT/" >/dev/null 2>&1 || true ) &

echo "▸ http://localhost:$PORT  —  watching *.lean and figures/*.tex (Ctrl-C to stop)"
# `--on-busy-update=queue` finishes the current build before starting the next;
# watchexec honours .gitignore, so .lake/_out/.figbuild are not watched.
watchexec --postpone --exts lean,tex --debounce 200ms --on-busy-update=queue \
  -- bash -c rebuild
