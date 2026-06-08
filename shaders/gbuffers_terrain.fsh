#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	
	vec3 enhancedGlColor = pow(glcolor.rgb, vec3(1.35));

	color = texture(gtexture, texcoord);
	color.rgb *= enhancedGlColor;

	vec2 adjustedLmcoord = lmcoord;
	adjustedLmcoord.y = pow(lmcoord.y, 1.55);

	color *= texture(lightmap, adjustedLmcoord);

	if (color.a < alphaTestRef) {
		discard;
	}
}