texcoord = vaUV0;

gl_Position =
    projectionmatrix *
    modelviewmatrix *
    vec4(vaPosition + chunkoffset, 1.0);