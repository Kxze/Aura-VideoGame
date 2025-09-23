shader_type canvas_item;

uniform vec2 shadow_offset = vec2(3.0, 3.0); // desplazamiento de la sombra
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.6); // color y opacidad
uniform float blur_radius = 3.0; // radio del blur

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    // UV desplazado para la sombra
    vec2 shadow_uv = UV + (shadow_offset / TEXTURE_PIXEL_SIZE);
    vec4 shadow_accum = vec4(0.0);
    float samples = 0.0;

    // Muestreo en un área alrededor del píxel para suavizar
    for (float x = -blur_radius; x <= blur_radius; x++) {
        for (float y = -blur_radius; y <= blur_radius; y++) {
            shadow_accum += texture(TEXTURE, shadow_uv + vec2(x, y) / TEXTURE_PIXEL_SIZE);
            samples += 1.0;
        }
    }

    // Promedio y color de sombra
    shadow_accum /= samples;
    shadow_accum *= shadow_color;

    // Combinar sombra y texto
    COLOR = mix(shadow_accum, base, base.a);
}
