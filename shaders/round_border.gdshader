
shader_type canvas_item;

uniform float top_left_radius : hint_range(0.0, 1.0, 0.005) = 0.05;
uniform float top_right_radius : hint_range(0.0, 1.0, 0.005) = 0.05;
uniform float bottom_left_radius : hint_range(0.0, 1.0, 0.005) = 0.05;
uniform float bottom_right_radius : hint_range(0.0, 1.0, 0.005) = 0.05;

uniform float antialiasing : hint_range(0.0, 4.0, 0.1) = 1.0;


float rounded_box(vec2 p, vec2 half_size, vec4 radii) {
    // Select the radius belonging to the current corner.
    float radius;

    if (p.x < 0.0) {
        radius = p.y < 0.0 ? radii.x : radii.w;
    } else {
        radius = p.y < 0.0 ? radii.y : radii.z;
    }

    vec2 q = abs(p) - half_size + radius;

    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}


void fragment() {
    vec4 color = texture(TEXTURE, UV) * COLOR;

    // Screen-space pixel dimensions of the control.
    vec2 pixel_size = fwidth(UV);

    vec2 p = (UV - vec2(0.5)) / pixel_size;
    vec2 half_size = vec2(0.5) / pixel_size;

    // Convert radius fractions into pixel dimensions.
    float max_radius = min(half_size.x, half_size.y);

    vec4 radii = vec4(top_left_radius, top_right_radius, bottom_right_radius, bottom_left_radius) * max_radius;

    // Prevent adjacent radii from overlapping.
    float scale = 1.0;

    scale = min(scale, (half_size.x * 2.0) / max(radii.x + radii.y, 0.0001));
    scale = min(scale, (half_size.x * 2.0) / max(radii.w + radii.z, 0.0001));
    scale = min(scale, (half_size.y * 2.0) / max(radii.x + radii.w, 0.0001));
    scale = min(scale, (half_size.y * 2.0) / max(radii.y + radii.z, 0.0001));

    radii *= min(scale, 1.0);

    // Calculate rounded rectangle.
    float distance = rounded_box(p, half_size, radii);

    // Antialias edges.
    float aa = max(fwidth(distance) * antialiasing, 0.0001);
    float mask = 1.0 - smoothstep(-aa, aa, distance);

    color.a *= mask;

    COLOR = color;
}
