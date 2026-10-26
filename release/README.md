# release/

Release binaries (`TheViolence.exe`, `TheViolence.x86_64`, and `SHA256SUMS.txt`)
are generated locally into this directory and kept git-ignored so large binaries
stay out of source history. Distribute them as GitHub Release / itch.io / Steam
assets instead.

Build and verify with:

```sh
JOBS=8 tools/build_release.sh                # Windows + Linux + SHA256SUMS.txt
JOBS=8 tools/build_release.sh --target=windows
JOBS=8 tools/build_release.sh --target=linux
tools/build_release.sh --verify-sums
```

See `../RELEASE.md` for packaging details and `../docs/SIGNING.md` for Windows
Authenticode code-signing and storefront upload instructions.
