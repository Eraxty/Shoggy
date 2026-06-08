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

    // Color grading
    vec3 blueShadow  = vec3(0.85, 0.92, 1.15);
    vec3 yellowLight = vec3(1.20, 1.10, 0.90);

    vec3 grade = mix(blueShadow, yellowLight, lum);

    c.rgb = mix(c.rgb, c.rgb * grade, 0.35);

    // Warm horizon, cool sky
    float gradient = texcoord.y;

    vec3 tint = mix(
        vec3(1.04, 1.02, 0.96),
        vec3(0.98, 1.00, 1.04),
        gradient
    );

    c.rgb *= tint;

    // Subtle warm glow
    float glow = smoothstep(0.75, 1.0, lum);
    c.rgb += glow * vec3(1.0, 0.92, 0.75) * 0.04;

    // Bright highlights
    float brightness = max(c.r, max(c.g, c.b));

    if (brightness > 0.85) {
        c.rgb += brightness * vec3(0.015, 0.012, 0.008);
    }

    // Gentle moon / bright object boost
    if (brightness > 0.9) {
        float moonGlow = smoothstep(0.9, 1.0, brightness);
        c.rgb += moonGlow * vec3(0.04, 0.06, 0.12);
    }

    // Night atmosphere
    float nightMood = 1.0 - lum;
    c.rgb += vec3(0.01, 0.02, 0.05) * nightMood;

    // Contrast
    c.rgb = (c.rgb - 0.5) * 1.08 + 0.5;

    c.rgb = clamp(c.rgb, 0.0, 1.0);

    color = c;
}