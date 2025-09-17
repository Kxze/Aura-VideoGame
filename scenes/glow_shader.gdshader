shader_type canvas_item;

uniform bool active = false;
uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.3, 1.0);
uniform float glow_strength = 0.8; // Intensidad
uniform float speed = 2.0; // Velocidad del pulso

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    if (active) {
        // Pulso con seno
        float pulse = (sin(TIME * speed) + 1.0) * 0.5;

        // Glow difuminado multiplicado al alfa del sprite/texto
        float glow = smoothstep(0.0, 1.0, base.a) * pulse * glow_strength;

        COLOR = mix(base, glow_color, glow);
    } else {
        COLOR = base;
    }
}
