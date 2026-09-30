shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 c = texture(TEXTURE, UV) * tint;
	// The approved atlas crop contains a sliver of the neighbouring barrel.
	// Only mask the empty lower corners; canopy, roots and foot pivot stay intact.
	if (UV.y > 0.72 && (UV.x < 0.02 || UV.x > 0.95)) { c.a = 0.0; }
	COLOR = c;
}
