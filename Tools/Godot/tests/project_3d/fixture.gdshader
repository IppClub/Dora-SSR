shader_type spatial;
render_mode unshaded;
// View-space normal variation makes real 3D faces visible without relying on
// a platform-specific light/shadow setting. Green stays within the pixel oracle.
void fragment() {
    ALBEDO = vec3(0.0, 0.6 + 0.4 * abs(NORMAL.z), 0.0);
}
