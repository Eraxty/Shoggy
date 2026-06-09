#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform float far;

in vec2 texcoord;

const float FOG_DENSITY = 2.5;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    float depth = texture(depthtex0, texcoord).r;

    if (depth >= 1.0) {
        return;
    }

    vec3 ndcPos = vec3(texcoord, depth) * 2.0 - 1.0;
    vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);

    float dist = length(viewPos) / far;

    // smoother exponential fog
    float fogFactor = 1.0 - exp(-FOG_DENSITY * dist * dist);

    float heightFog = clamp((20.0 - viewPos.y) / 20.0, 0.0, 1.0);
    fogFactor += heightFog * 0.15;

    // keep nearby terrain crisp
    fogFactor = smoothstep(0.15, 1.0, fogFactor);

    vec3 fogTint = pow(fogColor, vec3(2.2));

    color.rgb = mix(color.rgb, fogTint, clamp(fogFactor, 0.0, 1.0));
}