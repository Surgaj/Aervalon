# Valen clothing animation variants

Generated with the built-in image-generation tool, using the existing approved
`assets/aervalon/v2/hero.png` as the edit target. Originals remain unchanged.
RGBA sheets retain generated transparency. Runtime divides each sheet into
8 columns × 4 rows and normalizes displayed character size.

## valen_linen.png — prompt

Edit target: the supplied 2048x1024 RPG sprite sheet. Production game asset, not illustration. Make a SIMPLE STARTER CLOTHING variant of the same young male Valen hero: plain beige linen tunic, simple brown trousers and worn boots, short brown hair. Remove ALL armor plates, shoulder armor, cape and ornaments. Keep the simple narrow sword for the existing animations. Critical: preserve EXACT 8 columns x 4 rows grid, each cell 256x256, EXACT same 32 poses and directions, same feet pivots, same character size, same painterly detailed top-down game sprite style. Rows down/left/right/up, columns idle,walk1,walk2,walk3,attack windup,attack strike,hit,lying dead. Each frame entirely within its own cell. No grid lines, no labels, no terrain. Genuine transparent alpha background. Do not change the sheet layout. Return the complete sheet, landscape 2:1.

## valen_leather.png — prompt

Edit target: supplied game sprite animation sheet. Produce the LEATHER ARMOR equipped variant. Same brown-haired male hero now wears a clearly distinct dark brown reinforced leather cuirass, leather shoulder guards, bracers and reinforced boots over linen. No cape, no metal plate armor. Preserve EXACT 8 columns by 4 rows, exact character poses, size, feet pivots and alignment of all 32 frames. Rows face down/left/right/up. Columns idle/walk1/walk2/walk3/attack windup/attack strike/hit/death. Keep sword and face unchanged. Keep detailed painterly top-down RPG style. Landscape 2:1 canvas, genuine transparent alpha outside sprites, no colored edge fringe, no text, no gridlines. This is a production animation sprite sheet.

## Current scope

Complete outfit sheet variants, not independent armor layers per body slot yet.
Iron armor reuses the original hero sheet. Weapon shape is still baked into the
animations; individual weapon visuals and modular head/hand/boot layers remain
future work. Do not claim that this release already supports those systems.
