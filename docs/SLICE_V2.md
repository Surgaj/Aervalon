# Eryndor playable V2

Godot 4.5.1, Compatibility renderer, single-threaded Web export.

The active world is composed of separate raster props, tiled terrain textures, animated actors and a lightweight water UV shader. Ground and bridge render below a shared Y-sorted world. Trunks and buildings have independent physics footprints. Authored diagonal river-bank collision leaves a traversable bridge deck.

Play: WASD/arrows or touch joystick; Space/sword to attack; E/Falar to interact. Talk to Mara, cross the bridge, defeat three wolves and return to Mara. Attack range and facing are evaluated at the animation strike moment, with world-geometry line-of-sight. Wolves patrol, chase, telegraph attacks and return. Borin works; other villagers and a hen wander. Explore south of the forest for a chest.

Verification: `godot --headless --path . --editor --import`; `godot --headless --path . --script tests/slice_test.gd`; `godot --headless --path . --export-release Web build/web/index.html`.

Scope limits: the slice is session-based (refresh resets progress); no MMO networking, inventory/equipment progression or profession economy yet. UI does not show fictional mana. No complete day/night system. Art animation is an initial generated raster pass and needs further directional cleanup, notably attack pose consistency. World region expansion and lore changes are deferred.

Builds retain immutable `build-RUN-SHA` folders. No old HTML/PCK/WASM combinations are reused. The branch has a deployment gate that runs import and gameplay regression checks before export.
