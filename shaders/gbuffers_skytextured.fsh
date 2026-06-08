#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(gtexture, texcoord) * glcolor;

    if (color.a < alphaTestRef) {
        discard;
    }

    // Horizon factor
    float horizon = pow(1.0 - texcoord.y, 2.0);

    // Warm sonlight
    vec3 warmSun = vec3(1.35, 1.18, 0.85);

    // Co0ler sky
    vec3 coolSky = vec3(0.92, 0.97, 1.08);

    vec3 tint = mix(coolSky, warmSun, horizon);

    color.rgb *= tint;

    //cloud brightening
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    if (brightness > 0.7) {
        color.rgb *= vec3(1.05, 1.03, 1.00);
    }
    //contrast
    color.rgb = (color.rgb - 0.5) * 1.03 + 0.5;
}