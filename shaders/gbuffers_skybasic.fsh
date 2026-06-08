#version 330 compatibility

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec4 glcolor;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	vec3 baseColor = mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));

	// Elevation factor: 0.0 at the horizon, 1.0 at the zenith
	float elevation = clamp(upDot, 0.0, 1.0);

	// Determine day/night transition factor using skyColor's luminance
	float skyLuma = dot(skyColor, vec3(0.299, 0.587, 0.114));
	float dayWeight = smoothstep(0.05, 0.25, skyLuma);

	// --- Daytime Tints ---
	vec3 dayHorizon = vec3(1.12, 1.05, 0.90); // Warm, golden horizon
	vec3 dayZenith  = vec3(0.96, 0.99, 1.04); // Soft, cool blue zenith

	// --- Nighttime Tints ---
	vec3 nightHorizon = vec3(0.85, 0.90, 1.10); // Subtle cool/indigo haze
	vec3 nightZenith  = vec3(0.50, 0.55, 0.65); // Navy zenith

	// Interpolate tints based on time of day
	vec3 horizonTint = mix(nightHorizon, dayHorizon, dayWeight);
	vec3 zenithTint  = mix(nightZenith, dayZenith, dayWeight);

	// Blend the final sky tint using elevation
	vec3 skyTint = mix(horizonTint, zenithTint, elevation);

	return baseColor * skyTint;
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
	} else {
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		color = vec4(calcSkyColor(normalize(pos)), 1.0);
	}
}
