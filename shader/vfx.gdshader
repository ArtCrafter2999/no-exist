shader_type canvas_item;

uniform bool noise = true;
uniform bool chromatic_abberation = true;

uniform float aberration_intensity: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform vec2 r_displacement = vec2(1.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-1.0, 0.0);

// Use only one screen texture uniform to avoid conflicts on WebGL
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;

// Standard random function - compatible with basically everything
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec4 final_color;
    
    if (chromatic_abberation) {
        // Manual calculation instead of fma()
        // Format: (multiplier * size) + offset
        vec2 r_uv = SCREEN_UV + (r_displacement * aberration_intensity * SCREEN_PIXEL_SIZE);
        vec2 g_uv = SCREEN_UV + (g_displacement * aberration_intensity * SCREEN_PIXEL_SIZE);
        vec2 b_uv = SCREEN_UV + (b_displacement * aberration_intensity * SCREEN_PIXEL_SIZE);
        
        float r = texture(screen_texture, r_uv).r;
        float g = texture(screen_texture, g_uv).g;
        float b = texture(screen_texture, b_uv).b;
        float a = texture(screen_texture, SCREEN_UV).a;
        final_color = vec4(r, g, b, a);
    } else {
        final_color = texture(screen_texture, SCREEN_UV);
    }

    if (noise) {
        // mod(TIME, 10.0) keeps the float numbers small so the "waves" don't return
        // We use a small number (10.0) because WebGL precision is often lower than desktop
        float time_cycle = mod(TIME, 10.0); 
        float random_noise = random(SCREEN_UV + time_cycle) * 2.0 - 1.0;
        final_color.rgb += random_noise * noise_intensity;
    }
    
    COLOR = final_color;
}