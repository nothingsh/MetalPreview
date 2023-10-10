//
//  OBJLoader.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation
import MetalKit

class OBJLoader {
    var meshBufferAllocator: MTKMeshBufferAllocator
    
    var textureLoader: MTKTextureLoader
    var samplerState: MTLSamplerState
    
    private init(gpuDevice: MTLDevice) {
        self.meshBufferAllocator = MTKMeshBufferAllocator(device: gpuDevice)
        self.textureLoader = MTKTextureLoader(device: gpuDevice)
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        guard let sampler = gpuDevice.makeSamplerState(descriptor: samplerDescriptor) else {
            fatalError("GPU can't make MTLSamplerState")
        }
        self.samplerState = sampler
    }
    
    static var shared: OBJLoader?
    private static let lock = NSLock()
    
    static func setupSharedOBJLoader(with gpuDevice: MTLDevice) {
        guard shared == nil else {
            return
        }
        
        lock.lock()
        shared = OBJLoader(gpuDevice: gpuDevice)
        lock.unlock()
    }
}
