shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform sampler2D sprite_texture : source_color, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_cutoff = 0.08;
uniform float glow_strength = 1.25;
uniform float edge_softness = 0.08;

void fragment() {
	vec4 tex = texture(sprite_texture, UV);
	float raw_alpha = tex.a * tint.a;
	if (raw_alpha < alpha_cutoff) {
		discard;
	}

	float alpha = smoothstep(alpha_cutoff, alpha_cutoff + edge_softness, raw_alpha);
	vec3 color = tex.rgb * tint.rgb * glow_strength * alpha;
	ALBEDO = color;
	EMISSION = color;
	ALPHA = alpha;
}
