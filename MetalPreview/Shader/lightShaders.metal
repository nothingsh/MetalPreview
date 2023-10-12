//
//  lightShaders.metal
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

#include <metal_stdlib>
using namespace metal;

#include "shaderHeader.h"

struct VertexData {
    // vertex position
    float4 position [[attribute(0)]];
    // texture coordinate
    float2 uv [[attribute(1)]];
    float3 normal [[attribute(2)]];
};

struct RasterizedData {
    float4 position [[position]];
    float2 textureCoordinate;
    float3 cameraPosition;
    float3 normal;
    float3 fragmentPosition;
};

float3 applyDirectionalLight(float3 normal, DLightParameters light, float3 baseColor, float3 fragCam);
float3 applySpotLight(float3 position, float3 normal, SLightParameters light, float3 baseColor, float3 fragCam);
float3 applyPointLight(float3 position, float3 normal, PLightParameters light, float3 baseColor, float3 fragCam);
    
vertex RasterizedData vertexShader(
    const VertexData vertexData [[stage_in]],
    constant matrix_float4x4 &transform [[buffer(1)]],
    constant CameraParameters &camera [[buffer(2)]]) {
        matrix_float3x3 diminished_model;
        diminished_model[0][0] = transform[0][0];
        diminished_model[0][1] = transform[0][1];
        diminished_model[0][2] = transform[0][2];
        diminished_model[1][0] = transform[1][0];
        diminished_model[1][1] = transform[1][1];
        diminished_model[1][2] = transform[1][2];
        diminished_model[2][0] = transform[2][0];
        diminished_model[2][1] = transform[2][1];
        diminished_model[2][2] = transform[2][2];
        
        RasterizedData out;
        out.position = camera.projection * camera.view * transform * vertexData.position;
        out.textureCoordinate = vertexData.uv;
        out.cameraPosition = float3(transform * float4(camera.position, 1.0));
        out.normal = diminished_model * vertexData.normal;
        out.fragmentPosition = float3(transform * vertexData.position);
        
        return out;
}

fragment float4 fragmentShader(
    RasterizedData input [[stage_in]],
    texture2d<float> texture [[texture(0)]],
    sampler sampler [[sampler(0)]],
    constant DLightParameters *directionLights [[buffer(0)]],
    constant SLightParameters *spotlights [[buffer(1)]],
    constant PLightParameters *pointLights [[buffer(2)]],
    constant LightCount &counts [[buffer(3)]]) {
    float3 baseColor = float3(texture.sample(sampler, input.textureCoordinate));
    float alpha = texture.sample(sampler, input.textureCoordinate).a;
    
    float3 fragCam = normalize(input.cameraPosition - input.fragmentPosition);
    
    // ambient
    float3 color = 0.2 * baseColor;
    
    // direction
    for(uint i = 0; i < counts.direction; i++) {
        if (directionLights[i].visiable) {
            color += applyDirectionalLight(input.normal, directionLights[i], baseColor, fragCam);
        }
    }
    
    // spotlight
    for(uint i = 0; i < counts.spot; i++) {
        if (spotlights[i].visiable) {
            color += applySpotLight(input.fragmentPosition, input.normal, spotlights[i], baseColor, fragCam);
        }
    }
    // point
    for (uint i = 0; i < counts.point; ++i) {
        if (pointLights[i].visiable) {
            color += applyPointLight(input.fragmentPosition, input.normal, pointLights[i], baseColor, fragCam);
        }
    }
    
    return float4(color, alpha);
}

float3 applyDirectionalLight(float3 normal, DLightParameters light, float3 baseColor, float3 fragCam) {
    float3 result = float3(0.0);
    
    float3 halfVec = normalize(-light.direction + fragCam);
    
    // diffuse
    float lightAmount = max(0.0, dot(normal, -light.direction));
    result += lightAmount * baseColor * light.color;
    
    // specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}

float3 applySpotLight(float3 position, float3 normal, SLightParameters light, float3 baseColor, float3 fragCam) {
    float3 result = float3(0.0);
    
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // diffuse
    float lightAmount = max(0.0, dot(normal, fragLight)) * pow(max(0.0, dot(fragLight, light.direction)),16);
    result += lightAmount * baseColor * light.color;
    
    // specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64) * pow(max(0.0, dot(fragLight, light.direction)),16);
    result += lightAmount * baseColor * light.color;
    
    return result;
}

float3 applyPointLight(float3 position, float3 normal, PLightParameters light, float3 baseColor, float3 fragCam) {
    float3 result = float3(0.0);
    
    // directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // diffuse
    float lightAmount = max(0.0, dot(normal, fragLight));
    result += lightAmount * baseColor * light.color;
    
    // specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}
