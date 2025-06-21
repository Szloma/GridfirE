shader_type canvas_item;

uniform float pan_amplitude = 0.05; // how far it pans left/right
uniform float pan_speed = 1.0;      // how fast it pans

void fragment() {
    float offset_x = sin(TIME * pan_speed) * pan_amplitude;
    vec2 uv = UV + vec2(offset_x, 0.0);
    COLOR = texture(TEXTURE, uv);
}