#!/bin/sh
# Build self-contained release artefacts for The Violence (Windows x86_64 and/or
# Linux x86_64) with embedded .pck packs, verify every embedded file's MD5, and
# write/verify release/SHA256SUMS.txt.
#
# Because official github.com release downloads may be unreachable in restricted
# build environments, this script compiles the required Godot editor and release
# export templates directly from the Godot source tarball on codeload.github.com.
#
# Usage:
#   tools/build_release.sh                         # build Windows + Linux + SHA256SUMS.txt
#   tools/build_release.sh --target=windows        # build release/TheViolence.exe only
#   tools/build_release.sh --target=linux          # build release/TheViolence.x86_64 only
#   tools/build_release.sh --godot-tag=4.4.1-stable
#   tools/build_release.sh --write-sums            # write release/SHA256SUMS.txt for existing binaries
#   tools/build_release.sh --verify-sums           # verify release/SHA256SUMS.txt
#   tools/build_release.sh --help
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${WORK:-$ROOT/.build}
GODOT_TAG=${GODOT_TAG:-4.7.2-stable}
JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}
TARGET=${TARGET:-all}
MODE="build"

WIN_PRESET=${WIN_PRESET:-Windows Desktop}
WIN_OUT=${OUT:-$ROOT/release/TheViolence.exe}
LIN_PRESET=${LIN_PRESET:-Linux}
LIN_OUT=${LIN_OUT:-$ROOT/release/TheViolence.x86_64}
SUMS_FILE=${SUMS_FILE:-$ROOT/release/SHA256SUMS.txt}

usage() {
    cat <<'EOF'
Usage: tools/build_release.sh [options]

Build and verify self-contained Windows (release/TheViolence.exe) and Linux
(release/TheViolence.x86_64) release binaries, plus release/SHA256SUMS.txt.

Options:
  --target=windows|linux|all   Which platform(s) to build (default: all)
  --godot-tag=TAG              Godot source tag to compile (default: 4.7.2-stable)
  --write-sums                 Generate release/SHA256SUMS.txt for existing binaries in release/
  --verify-sums                Verify release/SHA256SUMS.txt against release/ binaries
  --help, -h                   Show this help message and exit

Environment overrides:
  JOBS=N                       Parallel SCons jobs
  GODOT_TAG=4.4.1-stable       Engine tag override
  OUT=/path/to/TheViolence.exe Custom Windows output path
  LIN_OUT=/path/to/bin.x86_64  Custom Linux output path
EOF
}

for arg in "$@"; do
    case "$arg" in
        --target=windows|--target=linux|--target=all)
            TARGET=${arg#--target=}
            ;;
        --godot-tag=*)
            GODOT_TAG=${arg#--godot-tag=}
            ;;
        --write-sums)
            MODE="write-sums"
            ;;
        --verify-sums)
            MODE="verify-sums"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "build_release.sh: unknown option '$arg' (try --help)" >&2
            exit 2
            ;;
    esac
done

write_sums() {
    mkdir -p "$(dirname "$SUMS_FILE")"
    python3 - "$ROOT/release" "$SUMS_FILE" <<'PY'
import hashlib, pathlib, sys

rel_dir = pathlib.Path(sys.argv[1])
sums_path = pathlib.Path(sys.argv[2])
candidates = sorted(
    p for p in rel_dir.iterdir()
    if p.is_file() and p.name not in ("README.md", sums_path.name) and not p.name.startswith(".")
)
if not candidates:
    print(f"write_sums: no release artefacts found in {rel_dir}", file=sys.stderr)
    raise SystemExit(1)

lines = []
for p in candidates:
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {p.name}\n")
sums_path.write_text("".join(lines), encoding="utf-8")
print(f"wrote {len(lines)} checksum(s) to {sums_path}:")
for ln in lines:
    print("  " + ln.strip())
PY
}

verify_sums() {
    python3 - "$ROOT/release" "$SUMS_FILE" <<'PY'
import hashlib, pathlib, sys

rel_dir = pathlib.Path(sys.argv[1])
sums_path = pathlib.Path(sys.argv[2])
if not sums_path.is_file():
    print(f"verify_sums: missing {sums_path}", file=sys.stderr)
    raise SystemExit(1)

lines = [ln.strip() for ln in sums_path.read_text(encoding="utf-8").splitlines() if ln.strip() and not ln.startswith("#")]
if not lines:
    print(f"verify_sums: {sums_path} is empty", file=sys.stderr)
    raise SystemExit(1)

errors = 0
for ln in lines:
    parts = ln.split()
    if len(parts) < 2:
        print(f"verify_sums: malformed line: {ln}", file=sys.stderr)
        errors += 1
        continue
    expected, name = parts[0], parts[-1].lstrip("*")
    target = rel_dir / name
    if not target.is_file():
        print(f"  MISSING  {name}", file=sys.stderr)
        errors += 1
        continue
    actual = hashlib.sha256(target.read_bytes()).hexdigest()
    if actual.lower() != expected.lower():
        print(f"  FAILED   {name} (expected {expected}, got {actual})", file=sys.stderr)
        errors += 1
    else:
        print(f"  OK       {name} ({actual})")

if errors:
    raise SystemExit(1)
print(f"verify_sums: all {len(lines)} artefact(s) verified.")
PY
}

if [ "$MODE" = "write-sums" ]; then
    write_sums
    exit 0
fi

if [ "$MODE" = "verify-sums" ]; then
    verify_sums
    exit 0
fi

say() { printf '\n=== %s\n' "$*"; }

# ------------------------------------------------- 0. pre-flight repo checks
say "pre-flight verification (version sync + asset generators + static GDScript check)"
python3 "$ROOT/tools/sync_version.py" --check
python3 "$ROOT/tools/make_placeholders.py" --verify
python3 "$ROOT/tools/make_sounds.py" --verify
python3 "$ROOT/tools/gd47_check.py"

SRC=$WORK/godot-$GODOT_TAG
PREFIX=$WORK/mingw
VENV=$WORK/venv

mkdir -p "$WORK" "$ROOT/release"

# ---------------------------------------------------------------- 1. toolchain
say "toolchain (python venv: scons + zig)"
if [ ! -x "$VENV/bin/scons" ]; then
    python3 -m venv "$VENV"
fi
"$VENV/bin/pip" install --quiet --disable-pip-version-check "scons==4.8.1" "ziglang==0.13.0"
SCONS=$VENV/bin/scons
ZIGEXE=$(ls "$VENV"/lib/python3*/site-packages/ziglang/zig | head -1)
"$ZIGEXE" version

# ------------------------------------------------------------- 2. engine source
say "engine source ($GODOT_TAG)"
if [ ! -f "$SRC/SConstruct" ]; then
    mkdir -p "$SRC"
    curl -sSL -o "$WORK/godot-$GODOT_TAG.tar.gz" \
        "https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/$GODOT_TAG"
    tar xzf "$WORK/godot-$GODOT_TAG.tar.gz" -C "$SRC" --strip-components=1
fi

cp "$ROOT/icon.ico" "$SRC/platform/windows/godot.ico"
"$ROOT/tools/patch_rc.py" "$SRC/platform/windows/godot_res.rc"
"$ROOT/tools/patch_rc.py" --win-libs "$SRC/platform/windows/detect.py"

# --------------------------------------------------- 3. zig -> mingw-w64 shims
mkdir -p "$PREFIX/bin" "$PREFIX/stub"
printf '#!/bin/sh\ncase " $* " in *" --version "*) echo 1.8.1; exit 0;; esac\nexit 1\n' \
    > "$PREFIX/stub/pkg-config"
chmod +x "$PREFIX/stub/pkg-config"

if [ "$TARGET" = "windows" ] || [ "$TARGET" = "all" ]; then
    say "mingw-w64 shims (zig cc/c++, zig ar, zig rc)"
    for name in gcc g++ clang clang++ ar windres; do
        target_bin=$PREFIX/bin/x86_64-w64-mingw32-$name
        case $name in
            gcc|clang) exec_line="$ZIGEXE cc -target x86_64-windows-gnu \"\$@\"" ;;
            g++|clang++) exec_line="$ZIGEXE c++ -target x86_64-windows-gnu \"\$@\"" ;;
            ar) exec_line="$ZIGEXE ar \"\$@\"" ;;
            windres) exec_line="$ZIGEXE rc \$RCARGS \"\$RCINPUT\"" ;;
        esac
        {
            echo '#!/bin/sh'
            echo "export ZIG_GLOBAL_CACHE_DIR=\"\${ZIG_GLOBAL_CACHE_DIR:-$WORK/zig-cache}\""
            echo "export ZIG_LOCAL_CACHE_DIR=\"\${ZIG_LOCAL_CACHE_DIR:-$WORK/zig-local}\""
            case $name in
                gcc|g++)
                    echo 'for a in "$@"; do'
                    echo '  if [ "$a" = "--version" ]; then echo "gcc (GCC) 14.2.0"; exit 0; fi'
                    echo 'done'
                    ;;
                windres)
                    cat <<'INNER'
RCARGS=""; RCINPUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --target=*) shift;;
    --include-dir=*) RCARGS="$RCARGS /i ${1#--include-dir=}"; shift;;
    --include-dir) RCARGS="$RCARGS /i $2"; shift 2;;
    -I) RCARGS="$RCARGS /i $2"; shift 2;;
    -I*) RCARGS="$RCARGS /i ${1#-I}"; shift;;
    -D) RCARGS="$RCARGS /d $2"; shift 2;;
    -D*) RCARGS="$RCARGS /d ${1#-D}"; shift;;
    -i) RCINPUT="$2"; shift 2;;
    -o) RCARGS="$RCARGS /fo $2"; shift 2;;
    --output=*) RCARGS="$RCARGS /fo ${1#--output=}"; shift;;
    -*) shift;;
    *) RCINPUT="$1"; shift;;
  esac
done
INNER
                    ;;
            esac
            echo "$exec_line"
        } > "$target_bin"
        chmod +x "$target_bin"
    done
    ln -sf x86_64-w64-mingw32-gcc "$PREFIX/bin/gcc"
    ln -sf x86_64-w64-mingw32-g++ "$PREFIX/bin/g++"
    ln -sf x86_64-w64-mingw32-ar "$PREFIX/bin/ar"
    ln -sf x86_64-w64-mingw32-ar "$PREFIX/bin/x86_64-w64-mingw32-gcc-ar"
    ln -sf x86_64-w64-mingw32-ar "$PREFIX/bin/gcc-ar"
    ln -sf x86_64-w64-mingw32-windres "$PREFIX/bin/windres"
    printf '#!/bin/sh\nexit 0\n' > "$PREFIX/bin/x86_64-w64-mingw32-ranlib"
    printf '#!/bin/sh\nexit 0\n' > "$PREFIX/bin/x86_64-w64-mingw32-gcc-ranlib"
    chmod +x "$PREFIX/bin/x86_64-w64-mingw32-"*ranlib
fi

# --------------------------------------------------------- 4. headless editor
say "editor build (linuxbsd, headless, $JOBS jobs)"
if [ ! -x "$SRC/bin/godot.linuxbsd.editor.x86_64" ]; then
    ( cd "$SRC" && env PATH="$PREFIX/stub:$VENV/bin:$PATH" "$SCONS" \
        platform=linuxbsd target=editor tools=yes accesskit=no \
        x11=no wayland=no alsa=no pulseaudio=no dbus=no speechd=no fontconfig=no udev=no \
        vulkan=no d3d12=no lto=none use_static_cpp=yes -j"$JOBS" )
fi
EDITOR=$SRC/bin/godot.linuxbsd.editor.x86_64
"$EDITOR" --headless --version

VER=$("$EDITOR" --headless --version | tr -d '\r' | sed 's/\.custom_build$//')
TPL_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$VER
mkdir -p "$TPL_DIR"
printf '%s\n' "$VER" > "$TPL_DIR/version.txt"

# ------------------------------------------------------ 5. release templates
if [ "$TARGET" = "windows" ] || [ "$TARGET" = "all" ]; then
    say "windows template build (cross-compiled with zig, $JOBS jobs)"
    if [ ! -f "$SRC/bin/godot.windows.template_release.x86_64.exe" ]; then
        ( cd "$SRC" && env PATH="$PREFIX/bin:$PREFIX/stub:$VENV/bin:$PATH" MINGW_PREFIX="$PREFIX" "$SCONS" \
            platform=windows target=template_release tools=no arch=x86_64 accesskit=no \
            vulkan=no d3d12=no opengl3=yes lto=none use_static_cpp=yes windows_subsystem=gui -j"$JOBS" )
    fi
    cp "$SRC/bin/godot.windows.template_release.x86_64.exe" "$TPL_DIR/windows_release_x86_64.exe"
fi

if [ "$TARGET" = "linux" ] || [ "$TARGET" = "all" ]; then
    say "linux template build (linuxbsd x86_64, $JOBS jobs)"
    if [ ! -f "$SRC/bin/godot.linuxbsd.template_release.x86_64" ]; then
        ( cd "$SRC" && env PATH="$PREFIX/stub:$VENV/bin:$PATH" "$SCONS" \
            platform=linuxbsd target=template_release tools=no arch=x86_64 accesskit=no \
            x11=no wayland=no alsa=no pulseaudio=no dbus=no speechd=no fontconfig=no udev=no \
            vulkan=no opengl3=yes lto=none use_static_cpp=yes -j"$JOBS" )
    fi
    cp "$SRC/bin/godot.linuxbsd.template_release.x86_64" "$TPL_DIR/linux_release.x86_64"
fi

# ------------------------------------------------------------- 6. export game
say "import project"
"$EDITOR" --headless --path "$ROOT" --import >/dev/null 2>&1 || true

verify_binary() {
    bin_path=$1
    ls -lh "$bin_path"
    size=$(wc -c < "$bin_path" | tr -d ' ')
    if [ "$size" -ge 100000000 ]; then
        echo "Error: $bin_path is $size bytes; GitHub's per-file limit is 100,000,000 bytes." >&2
        exit 1
    fi
    python3 "$ROOT/tools/inspect_pck.py" "$bin_path" --verify
}

if [ "$TARGET" = "windows" ] || [ "$TARGET" = "all" ]; then
    say "export: $WIN_PRESET -> $WIN_OUT"
    mkdir -p "$(dirname "$WIN_OUT")"
    rm -f "$WIN_OUT"
    "$EDITOR" --headless --path "$ROOT" --export-release "$WIN_PRESET" "$WIN_OUT"
    verify_binary "$WIN_OUT"
    python3 "$ROOT/tools/inspect_exe.py" "$WIN_OUT"
fi

if [ "$TARGET" = "linux" ] || [ "$TARGET" = "all" ]; then
    say "export: $LIN_PRESET -> $LIN_OUT"
    mkdir -p "$(dirname "$LIN_OUT")"
    rm -f "$LIN_OUT"
    "$EDITOR" --headless --path "$ROOT" --export-release "$LIN_PRESET" "$LIN_OUT"
    chmod +x "$LIN_OUT"
    verify_binary "$LIN_OUT"
fi

# ------------------------------------------------------------- 7. SHA256SUMS
say "checksum manifest ($SUMS_FILE)"
write_sums
verify_sums
printf '\nDone.\n'
