# Aervalon Visual Pipeline V2

This branch is the clean break from the Polygon2D prototype.

## Rules
- No environment art generated at runtime.
- Ground: TileMapLayer / raster tiles.
- Buildings and props: Sprite2D scenes with foot pivots.
- Player/NPC/enemies: AnimatedSprite2D, initially 4 directions.
- Dynamic world objects share a Y-sorted container.
- Building roofs/foreground pieces are separate from bases.
- Gameplay scripts remain independent from art.

## First playable art slice
Eryndor square: hero + NPC + wolf + tree + house + road/grass/water.
The slice is not expanded until perspective, scale and occlusion match the approved Aervalon art direction.
