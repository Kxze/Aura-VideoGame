shader_type spatial;

render_mode blend_mix, cull_disabled, unshaded;

uniform sampler2D albedo_tex : source_color;
uniform sampler2D mask_tex   : source_color;

void fragment() {
    // textura base
    vec4 albedo = texture(albedo_tex, UV);

    // máscara
    float mask_value = texture(mask_tex, UV).r;

    // invertimos: negro visible, blanco transparente
    float alpha = 1.0 - mask_value;

    ALBEDO = albedo.rgb;
    ALPHA  = albedo.a * alpha;
}


