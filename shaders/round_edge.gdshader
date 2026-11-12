
shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform vec4 visible_rect = vec4(0.0, 0.0, 400.0, 200.0);
uniform float corner_radius : hint_range(0.0, 100.0) = 20.0;
uniform float antialiasing : hint_range(0.0, 4.0) = 1.0;

void fragment() {
    vec2 rect_position = visible_rect.xy;
    vec2 rect_size = visible_rect.zw;
    vec2 half_size = rect_size * 0.5;

    vec2 p = FRAGCOORD.xy - rect_position - half_size;

    float radius = clamp(
        corner_radius,
        0.0,
        min(half_size.x, half_size.y)
    );

    vec2 q = abs(p) - half_size + radius;

    float dist = length(max(q, vec2(0.0)))
        + min(max(q.x, q.y), 0.0)
        - radius;

    float aa = max(fwidth(dist) * antialiasing, 0.001);

    float mask = 1.0 - smoothstep(-aa, aa, dist);

    COLOR.a *= mask;
}
