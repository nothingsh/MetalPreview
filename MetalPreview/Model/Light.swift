//
//  Light.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation
import simd

public protocol Lightable: AnyObject {
    var color: simd_float3 { get set }
}

public class DirectionalLight: Lightable {
    public var color: simd_float3
    public var eulers: simd_float3
    
    public init(eulers: simd_float3, color: simd_float3) {
        self.color = color
        self.eulers = eulers
    }
    
    public var direction: simd_float3 {
        return [
            cos(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            sin(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            cos(self.eulers[1] * .pi / 180.0)
        ]
    }
    
    public var shaderInput: DLightParameters {
        DLightParameters(direction: self.direction, color: self.color)
    }
}

public class SpotLight: Lightable {
    public var position: simd_float3
    public var eulers: simd_float3
    public var color: simd_float3
    public var angle: Float
    
    public init(position: simd_float3, eulers: simd_float3, color: simd_float3) {
        self.position = position
        self.eulers = eulers
        self.color = color
        self.angle = 0
    }
    
    public var direction: simd_float3 {
        return [
            cos(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            sin(self.eulers[2] * .pi / 180.0) * sin(self.eulers[1] * .pi / 180.0),
            cos(self.eulers[1] * .pi / 180.0)
        ]
    }
    
    public var shaderInput: SLightParameters {
        SLightParameters(position: self.position, direction: self.direction, color: self.color, angle: self.angle)
    }
}

public class PointLight: Lightable {
    public var position: simd_float3
    public var color: simd_float3
    
    public init(position: simd_float3, color: simd_float3) {
        self.position = position
        self.color = color
    }
    
    public var shaderInput: PLightParameters {
        PLightParameters(position: self.position, color: self.color)
    }
}

