#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec4 c = texture(colortex0, texcoord);

    float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));

	lum = pow(lum, 1.2);

	vec3 blueShadow  = vec3(0.80, 0.92, 1.25);
	vec3 yellowLight = vec3(1.20, 1.10, 0.80);

	vec3 grade = mix(blueShadow, yellowLight, lum);

	c.rgb = mix(c.rgb, c.rgb * grade, 0.45);

    float gradient = texcoord.y;
    vec3 tint = mix(
    vec3(1.04, 1.02, 0.96), // warm
    vec3(0.96, 1.00, 1.06), // cool
	gradient
    );

    c.rgb *= tint;
    // contrast boost
    c.rgb = (c.rgb - 0.5) * 1.09 + 0.5;
	c.rgb = clamp(c.rgb, 0.0, 1.0);
    color = c;
}