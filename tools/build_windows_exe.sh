#!/bin/sh
# Compatible wrapper around tools/build_release.sh for building the single-file
# Windows release executable (release/TheViolence.exe).
#
# Usage:
#   tools/build_windows_exe.sh
#   JOBS=8 GODOT_TAG=4.4.1-stable tools/build_windows_exe.sh
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
exec "$ROOT/tools/build_release.sh" --target=windows "$@"
