//
//  Transform.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import simd

class Transform {
    var position: simd_float3
    var eulers: simd_float3
    var scalers: simd_float3
    
    init(position: simd_float3, eulers: simd_float3) {
        self.position = position
        self.eulers = eulers
        self.scalers = simd_float3(1, 1, 1)
    }
    
    var shaderInput: matrix_float4x4 {
        let rotation = Matrix44.create_from_rotation(eulers: self.eulers)
        return Matrix44.create_from_translation(translation: self.position) * rotation
    }
    
    static let origin = Transform(position: .zero, eulers: .zero)
}
