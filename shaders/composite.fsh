#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec2 uv = texcoord * 2.0 - 1.0;

    // Subtle screen curvature
    uv.x *= 1.0 + uv.y * uv.y * 0.01;
    uv.y *= 1.0 + uv.x * uv.x * 0.01;

    uv = uv * 0.5 + 0.5;

    vec4 c = texture(colortex0, uv);

    // Luminance
    float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    lum = pow(lum, 1.2);

    //color grading
    vec3 blueShadow  = vec3(0.75, 0.85, 1.30);
    vec3 yellowLight = vec3(1.35, 1.20, 0.85);

    vec3 grade = mix(blueShadow, yellowLight, lum);

    c.rgb = mix(c.rgb, c.rgb * grade, 0.45);

    // Warm horizon 
    float gradient = texcoord.y;

    vec3 tint = mix(
        vec3(1.06, 1.03, 0.95),
        vec3(0.97, 1.00, 1.04),
        gradient
    );

    c.rgb *= tint;

    // Bright area glow
    float glow = smoothstep(0.75, 1.0, lum);
    c.rgb += glow * vec3(1.0, 0.92, 0.75) * 0.08;

    // blomish
    float brightness = max(c.r, max(c.g, c.b));

    if (brightness > 0.8) {
        c.rgb += brightness * vec3(0.04, 0.035, 0.025);
    }

    // Contrast
    c.rgb = (c.rgb - 0.5) * 1.09 + 0.5;

    c.rgb = clamp(c.rgb, 0.0, 1.0);

    color = c;
    float moonBrightness = max(c.r, max(c.g, c.b));

    if (moonBrightness > 0.8) {
        float glow = (moonBrightness - 0.8) / 0.2;
        c.rgb += glow * vec3(0.15, 0.20, 0.35);
        }
}