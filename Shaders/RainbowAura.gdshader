shader_type spatial;

uniform float hue_shift_speed : hint_range(0.0, 5.0) = 1.0;
uniform float alpha_fade : hint_range(0.0,1.0) = 1.0;

// Función simple para hue shift
vec3 hue_shift(vec3 color, float shift) {
    float angle = shift * 6.2831853; // 2*PI
    float r = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
    float g = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
    float b = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
    return color; // Este ejemplo deja el color como base, puedes aplicar más fórmulas para rotar hue
}

void fragment() {
    vec3 col = ALBEDO;
    // Desplazar el hue usando tiempo
    col = hue_shift(col, TIME * hue_shift_speed);
    ALBEDO = col;
    ALPHA = alpha_fade;
}

