shader_type spatial;
#include "res://Shaders/fresnel.gdshaderinc"

uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float fresnel_power : hint_range(0.1, 10.0) = 1.0;
uniform sampler2D color_gradiant : source_color;
uniform float _emission : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	// Fresnel
	float f = fresnel(fresnel_power, NORMAL, VIEW);

	// Color del gradiente según opacity
	vec3 color = texture(color_gradiant, vec2(opacity, 0.0)).rgb;

	// Asignar valores de salida
	ALBEDO = color;
	ALPHA = opacity * f; // aplicar tanto el valor de opacity como el fresnel
	EMISSION = color * _emission;
}

