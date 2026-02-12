shader_type canvas_item;

uniform sampler2D noise_img : repeat_enable;
uniform float speed = 0.1;

void fragment() {
    // We move the UVs over time to animate the noise
    vec2 moving_uv = UV + TIME * speed;
    vec4 noise_color = texture(noise_img, moving_uv);
    
    // Example: Use noise to drive transparency
    COLOR = vec4(1.0, 1.0, 1.0, noise_color.r);
}