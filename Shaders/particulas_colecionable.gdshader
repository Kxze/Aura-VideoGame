shader_type spatial;

render_mode blend_mix, cull_disabled, unshaded;

uniform sampler2D albedo_tex : source_color;
uniform sampler2D mask_tex   : source_color;

uniform vec3 emission_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 0.0;

void fragment() {
    // textura base
    vec4 albedo = texture(albedo_tex, UV);

    // máscara
    float mask_value = texture(mask_tex, UV).r;

    // invertimos: negro visible, blanco transparente
    float alpha = 1.0 - mask_value;

    ALBEDO = albedo.rgb;
    ALPHA  = albedo.a * alpha;

    // Emisión
    EMISSION = emission_color * emission_strength * alpha;
}
