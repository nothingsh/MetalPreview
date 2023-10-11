//
//  Object.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import MetalKit

/// A 3d object with mesh and material
public class Object {
    // position, rotation and scale
    public var transform: Transform
    // 3d obj mesh
    public var mtkMesh: MTKMesh!
    
    // obj meterial
    public var mtlTexture: MTLTexture!
    public var mtlSamplerState: MTLSamplerState!
    
    public init(transform: Transform, mesh: URL, texture: URL) {
        self.transform = transform
        
        self.loadMesh(with: mesh)
        self.loadMaterial(with: texture)
    }
    
    private func loadMesh(with url: URL) {
        guard let allocator = OBJLoader.shared?.meshBufferAllocator else {
            fatalError("Can't get mesh loader")
        }
        
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(Object.sharedVertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (meshDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (meshDescriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        let asset = MDLAsset(url: url, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        
        let modelIOMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        do {
            self.mtkMesh = try MTKMesh(mesh: modelIOMesh, device: allocator.device)
        } catch {
            fatalError("Can't load mesh")
        }
    }
    
    private func loadMaterial(with url: URL) {
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: true
        ]
        
        guard let loader = OBJLoader.shared?.textureLoader else {
            fatalError("Can't get material loader")
        }
        
        do {
            self.mtlTexture = try loader.newTexture(URL: url, options: options)
        } catch {
            fatalError("Can't load material from \(url.absoluteString)")
        }
        
        guard let sampler = OBJLoader.shared?.samplerState else {
            fatalError("Can't get material sampler")
        }
        self.mtlSamplerState = sampler
    }
    
    public static var sharedVertexDescriptor: MTLVertexDescriptor = {
        let vertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        
        // vertex position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD4<Float>>.stride
        // texture coordinate
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        // normal
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = offset
        vertexDescriptor.attributes[2].bufferIndex = 0
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        return vertexDescriptor
    }()
}
