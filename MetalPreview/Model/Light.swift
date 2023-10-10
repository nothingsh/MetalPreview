//
//  Light.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation
import simd

class DirectionalLight {
    var color: simd_float3
    var eulers: simd_float3
    
    init(eulers: simd_float3, color: simd_float3) {
        self.color = color
        self.eulers = eulers
    }
    
    var direction: simd_float3 {
        return [
            cos(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            sin(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            cos(self.eulers[1] * .pi / 180.0)
        ]
    }
}

class SpotLight {
    var position: simd_float3
    var eulers: simd_float3
    var color: simd_float3
    var angle: Float
    
    init(position: simd_float3, eulers: simd_float3, color: simd_float3) {
        self.position = position
        self.eulers = eulers
        self.color = color
        self.angle = 0
    }
    
    var direction: simd_float3 {
        return [
            cos(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            sin(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            cos(self.eulers[1] * .pi / 180.0)
        ]
    }
}

class PointLight {
    var position: simd_float3
    var color: simd_float3
    
    init(position: simd_float3, color: simd_float3) {
        self.position = position
        self.color = color
    }
}

