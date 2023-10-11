//
//  Camera.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation
import simd

/// Perspective Camera
public class Camera {
    public var transform: Transform
    /// camera view width:height ratio
    public var aspect: Float = 1
    /// camera visiable angle
    public var fovy: Float = 45
    /// minimum visiable point
    public var near: Float = 0.1
    /// maximum visiable point
    public var far: Float = 20
    
    /// the target always look at
    public var target: simd_float3?
    
    public init(transform: Transform) {
        self.transform = transform
    }
    
    private let globalUpVector = simd_float3(0, 0, 1)
    /// camera forward vector based on eulers
    private var forward: simd_float3 {
        let eulers = self.transform.eulers
        return [
            cos(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            sin(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            cos(eulers[1] * .pi / 180.0)
        ]
    }
    /// camera right vector based on eulers
    private var right: simd_float3 {
        simd.normalize(simd.cross(self.globalUpVector, self.forward))
    }
    /// camera up vector based on eulers
    private var up: simd_float3 {
        simd.normalize(simd.cross(self.forward, self.right))
    }
    
    public var shaderInput: CameraParameters {
        let lookatTarget = (self.target == nil) ? self.forward : self.target!
        let view = Matrix44.create_lookat(eye: self.transform.position, target: lookatTarget, up: self.up)
        let projection = Matrix44.create_perspective_projection(fovy: self.fovy, aspect: self.aspect, near: self.near, far: self.far)
        
        return CameraParameters(position: self.transform.position, view: view, projection: projection)
    }
}
