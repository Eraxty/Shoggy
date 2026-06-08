#version 330 compatibility

in vec3 vaPosition;
in vec2 vaUV0;

uniform vec3 chunkoffset;
uniform mat4 modelviewmatrix;
uniform mat4 projectionmatrix;
uniform vec3 cameraPos;
uniform mat4 gbuffermodelviewinverse;

out vec2 texcoord;

void main() {
    texcoord = vaUV0;
    vec3 worldspacecvertexposition =cameraPos + (gbuffermodelviewinverse * modelviewmatrix * vec4(vaPosition + chunkoffset, 1)).xyz;
    float distancefromcamera = distance(worldspacecvertexposition, cameraPos);
	gl_Position = projectionmatrix * modelviewmatrix * vec4(vaPosition + chunkoffset - .01 * distancefromcamera,1);
}