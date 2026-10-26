# Cutscene Licensing Note (`cinematics/`)

## Summary (Roadmap 1.36 / 2.03)

The 4 opening cutscene films (`assets/cutscenes/c1..c4_*.ogv`) and 14 short
interstitials (`assets/cutscenes/shorts/s01..s14_*.ogv`) are rendered offline by
the Remotion project in `cinematics/` (`remotion@4.0.537`).

1. **No runtime dependency:** `cinematics/` is excluded from the Godot project
   and export packs via `cinematics/.gdignore`. Only the rendered Ogg Theora
   (`.ogv`) video files are included in the game.
2. **Remotion License eligibility:** Under the Remotion License
   (https://www.remotion.dev/license), individuals and companies/teams of **3 or
   fewer people** may use Remotion free of charge, including for commercial and
   non-commercial video creation, and may distribute the rendered `.ogv` video
   outputs inside the game without royalty.
3. **If team size exceeds 3 people in the future:** A Remotion Company License
   is required before rendering new cutscenes for a commercial release.
4. **Fonts (`@fontsource/courier-prime`, `@fontsource/open-sans`, `@fontsource/oswald`):**
   Licensed under the **SIL Open Font License 1.1 (OFL-1.1)**, which permits
   unrestricted use in rendered raster/video outputs.
5. **Audio in cutscenes (`cinematics/public/sfx/*.wav`):** Synthesised in-repo
   by `tools/make_sounds.py` (no third-party audio samples).
