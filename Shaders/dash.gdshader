shader_type spatial;
render_mode blend_mix, cull_disabled, depth_prepass_alpha;

uniform sampler2D albedo_texture : source_color;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float mix_color : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    
    // descartar píxeles invisibles
    if (tex.a < 0.01) {
        discard;
    }

    vec3 mixed = mix(tex.rgb, tint, mix_color);

    ALBEDO = mixed;
    ALPHA  = tex.a * opacity;
}


