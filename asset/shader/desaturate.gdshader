shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
	vec4 texel = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = mix(vec3(dot(texel.rgb, vec3(0.299, 0.587, 0.114))), texel.rgb, saturation);
	COLOR.a = texel.a;
}
