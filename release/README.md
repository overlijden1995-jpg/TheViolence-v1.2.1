# release/

`TheViolence.exe` is the single-file Windows prototype build. The current
compact build is under GitHub's 100 MB per-file limit, but binaries remain
ignored to keep them out of source history. Distribute it as a GitHub Release
asset instead.

Rebuild with:

```sh
JOBS=2 tools/build_windows_exe.sh
```

See `../RELEASE.md` for contents, verification, and the current checksum.
