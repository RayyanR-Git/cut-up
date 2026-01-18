shader_type sky;

uniform vec3 top_color     = vec3(0.02, 0.04, 0.10);
uniform vec3 horizon_color = vec3(1.00, 0.45, 0.20);
uniform vec3 ground_color  = vec3(0.02, 0.01, 0.02);

uniform sampler2D sky_texture : source_color, filter_linear_mipmap;
uniform float texture_mix : hint_range(0.0, 1.0) = 0.5;
uniform float rotation_speed : hint_range(0.0, 0.1) = 0.001;

void sky() {
    // Gradient (unchanged)
    float y = EYEDIR.y;
    float t = y * 2.0;
    float sky_mix = clamp(t * 0.5 + 0.5, 0.0, 1.0);
    vec3 sky_grad = mix(horizon_color, top_color, sky_mix);
    float ground_mix = smoothstep(0.0, -0.3, y);
    vec3 final_gradient = mix(sky_grad, ground_color, ground_mix);

    // Oscillate between -90° and +90° (back and forth)
    vec2 tex_uv = SKY_COORDS;
    float oscillation = sin(TIME * rotation_speed); // -1 to +1
    float rotation = oscillation * 3.14159 * 0.5;   // -90° to +90°
    tex_uv.x = fract(tex_uv.x + rotation / (2.0 * 3.14159)); // wrap seamlessly

    vec3 tex_color = texture(sky_texture, tex_uv).rgb;
    vec3 final_color = mix(final_gradient, tex_color, texture_mix);

    COLOR = final_color;
}
