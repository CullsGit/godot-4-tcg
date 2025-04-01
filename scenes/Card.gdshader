shader_type canvas_item;

uniform bool is_selected = false;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_strength = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (is_selected) {
        float dist = distance(UV, vec2(0.5));
        float glow = smoothstep(0.5, 0.25, dist);
        COLOR = tex + glow * glow_strength * glow_color;
    } else {
        COLOR = tex;
    }
}
