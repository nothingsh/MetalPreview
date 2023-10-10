//
//  MetalPreview.h
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

#import <Foundation/Foundation.h>

//! Project version number for MetalPreview.
FOUNDATION_EXPORT double MetalPreviewVersionNumber;

//! Project version string for MetalPreview.
FOUNDATION_EXPORT const unsigned char MetalPreviewVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MetalPreview/PublicHeader.h>

#include <simd/simd.h>

// Camera Shader Input

struct CameraParameters {
    // camera position
    simd_float3 position;
    // camera view
    matrix_float4x4 view;
    // camera projection
    matrix_float4x4 projection;
};

// Light Shader Input

// directional light
struct DLightParameters {
    simd_float3 direction;
    simd_float3 color;
};

// spot light
struct SLightParameters {
    simd_float3 position;
    simd_float3 direction;
    simd_float3 color;
    float angle;
};

// point light
struct PLightParameters {
    simd_float3 position;
    simd_float3 color;
};
