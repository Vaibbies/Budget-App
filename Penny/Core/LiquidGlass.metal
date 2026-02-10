#include <SwiftUI/SwiftUI.h>
using namespace metal;

half4 liquidGlass(float2 position,
                  SwiftUI::Layer layer,
                  float2 size,
                  float time,
                  float2 light) {
    float2 uv = position / max(size, float2(1.0, 1.0));
    float2 centered = uv - 0.5;

    float wave = sin((centered.x * 4.0 + time * 0.35) * 6.2831) * 0.0016;
    float2 swirl = float2(centered.y, -centered.x) * 0.008;
    float2 refractOffset = (swirl + float2(wave, -wave)) * size;

    half4 base = layer.sample(position + refractOffset);

    float2 lp = light;
    float dist = length(uv - lp);
    float spec = pow(clamp(1.0 - dist * 1.45, 0.0, 1.0), 2.1);

    float3 viewDir = normalize(float3(centered, 0.85));
    float fresnel = pow(1.0 - viewDir.z, 2.2);

    half3 highlight = half3(1.0) * half(spec * 0.18 + fresnel * 0.06);

    float bandCenter = 0.20 + 0.05 * sin(time * 0.18);
    float reflectBand = smoothstep(0.16, 0.0, abs(uv.y - bandCenter));
    half3 reflection = half3(1.0) * half(reflectBand * 0.08);

    return half4(base.rgb + highlight + reflection, base.a);
}
