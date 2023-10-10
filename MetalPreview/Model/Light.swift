//
//  Light.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation
import simd

protocol Lightable: AnyObject {
    var color: simd_float3 { get set }
}

class DirectionalLight: Lightable {
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
    
    var shaderInput: DLightParameters {
        DLightParameters(direction: self.direction, color: self.color)
    }
}

class SpotLight: Lightable {
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
    
    var shaderInput: SLightParameters {
        SLightParameters(position: self.position, direction: self.direction, color: self.color, angle: self.angle)
    }
}

class PointLight: Lightable {
    var position: simd_float3
    var color: simd_float3
    
    init(position: simd_float3, color: simd_float3) {
        self.position = position
        self.color = color
    }
    
    var shaderInput: PLightParameters {
        PLightParameters(position: self.position, color: self.color)
    }
}

