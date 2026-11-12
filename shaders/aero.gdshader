
shader_type canvas_item;
render_mode blend_mix;

uniform vec2 panel_size = vec2(400.0, 200.0);

uniform vec4 glass_color : source_color = vec4(0.15, 0.75, 0.95, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.85, 1.0, 1.0, 1.0);
uniform vec4 border_color : source_color = vec4(0.85, 1.0, 1.0, 1.0);

uniform float opacity : hint_range(0.0, 1.0) = 0.85;
uniform float border_width : hint_range(0.0, 10.0) = 2.0;

// Corner radii: TL, TR, BR, BL
uniform float corner_top_left : hint_range(0.0, 100.0) = 6.0;
uniform float corner_top_right : hint_range(0.0, 100.0) = 6.0;
uniform float corner_bottom_right : hint_range(0.0, 100.0) = 6.0;
uniform float corner_bottom_left : hint_range(0.0, 100.0) = 6.0;

// Glass effects
uniform float gloss : hint_range(0.0, 2.0) = 1.0;
uniform float reflection : hint_range(0.0, 2.0) = 1.0;
uniform float gradient_strength : hint_range(0.0, 2.0) = 1.0;

uniform float highlight_position : hint_range(0.0, 1.0) = 0.18;
uniform float highlight_size : hint_range(0.0, 1.0) = 0.65;

// Main white shine
uniform float shine_position : hint_range(0.0, 1.0) = 0.035;
uniform float shine_thickness : hint_range(0.001, 0.2) = 0.025;
uniform float shine_strength : hint_range(0.0, 2.0) = 0.65;


// Match Godot StyleBoxFlat radius scaling.
vec4 normalize_radii(vec4 radii, vec2 size) {
    float scale = 1.0;

    float top = radii.x + radii.y;
    float bottom = radii.w + radii.z;
    float left = radii.x + radii.w;
    float right = radii.y + radii.z;

    if (top > 0.0) {
        scale = min(scale, size.x / top);
    }

    if (bottom > 0.0) {
        scale = min(scale, size.x / bottom);
    }

    if (left > 0.0) {
        scale = min(scale, size.y / left);
    }

    if (right > 0.0) {
        scale = min(scale, size.y / right);
    }

    return radii * min(scale, 1.0);
}


// Rounded rectangle with independently adjustable corners.
float rounded_box(vec2 p, vec2 half_size, vec4 radii) {
    float radius;

    if (p.x < 0.0 && p.y < 0.0) {
        radius = radii.x;
    } else if (p.x > 0.0 && p.y < 0.0) {
        radius = radii.y;
    } else if (p.x > 0.0 && p.y > 0.0) {
        radius = radii.z;
    } else {
        radius = radii.w;
    }

    if (radius <= 0.0) {
        vec2 q = abs(p) - half_size;
        return max(q.x, q.y);
    }

    vec2 q = abs(p) - half_size + radius;

    return length(max(q, vec2(0.0)))
        + min(max(q.x, q.y), 0.0)
        - radius;
}


void fragment() {
    vec2 half_size = panel_size * 0.5;
    vec2 p = (UV - 0.5) * panel_size;

    // Corner radii
    vec4 radii = vec4(
        corner_top_left,
        corner_top_right,
        corner_bottom_right,
        corner_bottom_left
    );

    // Scale radii proportionally to fit the panel.
    radii = normalize_radii(radii, panel_size);

    // Rounded rectangle mask
    float dist = rounded_box(p, half_size, radii);

    float aa = max(fwidth(dist), 0.5);

    float mask = 1.0 - smoothstep(-aa, aa, dist);

    if (mask <= 0.001) {
        discard;
    }

    // Border edge
    float inner_edge = smoothstep(
        border_width,
        border_width + 2.0,
        -dist
    );

    float y = UV.y;

    // Base glass gradient
    vec3 top_color = glass_color.rgb * 1.3;
    vec3 bottom_color = glass_color.rgb * 0.55;

    vec3 base_color = mix(
        top_color,
        bottom_color,
        smoothstep(0.0, 1.0, y)
    );

    // Soft vertical gloss
    float vertical_gloss = exp(
        -pow((y - highlight_position) / 0.13, 2.0)
    );

    // Upper reflection
    float upper_reflection = 1.0 - smoothstep(
        0.0,
        0.45,
        abs(y - 0.08)
    );

    // Adjustable white shine
    float shine = exp(
        -pow(
            (y - shine_position) / shine_thickness,
            2.0
        )
    );

    // Broad reflection
    float broad_reflection = exp(
        -pow(
            (y - 0.20) / max(highlight_size, 0.01),
            2.0
        ) * 5.0
    );

    // Center glow
    float center_glow = exp(
        -pow(
            length(
                (UV - vec2(0.28, 0.10)) * vec2(1.0, 1.8)
            ) / 0.55,
            2.0
        )
    );

    // Apply reflections
    base_color += highlight_color.rgb * vertical_gloss * 0.16 * gloss;
    base_color += highlight_color.rgb * upper_reflection * 0.10 * reflection;
    base_color += highlight_color.rgb * shine * shine_strength * gloss;
    base_color += highlight_color.rgb * broad_reflection * 0.13 * reflection;
    base_color += highlight_color.rgb * center_glow * 0.10 * reflection;

    // Border highlight
    float rim = 1.0 - smoothstep(
        0.0,
        border_width + 3.0,
        -dist
    );

    base_color = mix(
        base_color,
        border_color.rgb,
        rim * 0.55
    );

    // Bottom glass gradient
    float bottom_rim = smoothstep(0.0, 0.12, y) *
        (1.0 - smoothstep(0.85, 1.0, y));

    base_color += glass_color.rgb * bottom_rim * 0.08 * gradient_strength;

    // Final opacity
    float alpha = opacity * (0.78 + vertical_gloss * 0.12);

    alpha = mix(alpha, opacity, inner_edge);

    COLOR = vec4(base_color, alpha * mask);
}
