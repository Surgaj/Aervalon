# Aervalon V2 asset provenance

These raster assets were generated specifically for this project using OpenAI's built-in image generation tool on 2026-09-24. No third-party game asset pack, extracted commercial game art, or externally licensed art was used. User-supplied official concept references are retained in `docs/references/` and are not used as gameplay backgrounds.

The generated environment atlas contains eight isolated props. Character sheets contain directional adventurer poses, wolf locomotion/attack/death poses, and villagers. The terrain atlas contains grass, cobblestone, water and dirt material swatches. `tools/prepare_assets.sh` records mechanical chroma-key extraction, measured atlas crops and resizing. The prepared PNGs are self-contained runtime assets; regeneration is not required to build.

Prompt constraints: original painted medieval fantasy, elevated 3/4 camera, blue cloak/roof palette, detailed timber and stone, isolated magenta backdrop for sprites, no text or commercial game characters. Four directional hero rows with idle, walk, attack, hit and death poses; two directional wolf rows. Generated poses have limited frame continuity and remain a first production pass, not final hand-cleaned animation. Trees/house footprints and rendering pivots are authored independently of artwork.
