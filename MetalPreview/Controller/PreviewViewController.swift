//
//  PreviewViewController.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/11/23.
//

import MetalKit

#if os(macOS)
import AppKit

public typealias ViewController = NSViewController
#else
import UIKit

public typealias ViewController = UIViewController
#endif

public class PreviewViewController: ViewController {
    var mtkView: MTKView!
    var mtlDevice: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    
    public var scene: Scene
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.scene = Scene()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        self.mtlDevice = device
        OBJLoader.setupSharedOBJLoader(with: device)
    }
    
    public required init?(coder: NSCoder) {
        self.scene = Scene()
        super.init(coder: coder)
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        self.mtlDevice = device
        OBJLoader.setupSharedOBJLoader(with: device)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mtkView = MTKView(frame: self.view.frame, device: self.mtlDevice)
        self.view = self.mtkView
        self.mtkView.depthStencilPixelFormat = .depth32Float
        self.mtkView.delegate = self
        self.commandQueue = self.mtlDevice.makeCommandQueue()
        
        self.renderPipelineState = self.pipelineBuilder(vertexFunc: "vertexShader", fragFunc: "fragmentShader")
        self.depthStencilState = self.depthStencilBuilder()
        
        let cameraAspect = (self.mtkView.bounds.width == 0) ? 1 : self.mtkView.bounds.height / self.mtkView.bounds.width
        self.scene.camera.aspect = Float(cameraAspect)
    }
    
    private func pipelineBuilder(vertexFunc: String, fragFunc: String) -> MTLRenderPipelineState {
        let bundle = Bundle(for: type(of: self))
        guard let library: MTLLibrary = try? self.mtlDevice.makeDefaultLibrary(bundle: bundle) else {
            fatalError()
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: vertexFunc)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fragFunc)
        pipelineDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.vertexDescriptor = Object.sharedVertexDescriptor
        pipelineDescriptor.depthAttachmentPixelFormat = self.mtkView.depthStencilPixelFormat
        
        do {
            return try self.mtlDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func depthStencilBuilder() -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let state = self.mtlDevice.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError()
        }
        return state
    }
}

extension PreviewViewController: MTKViewDelegate {
    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(self.renderPipelineState)
        renderEncoder.setDepthStencilState(self.depthStencilState)
        self.setupShaderInput(renderEncoder: renderEncoder)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    private func setupShaderInput(renderEncoder: MTLRenderCommandEncoder) {
        // camera inputs
        var cameraInput = self.scene.camera.shaderInput
        renderEncoder.setVertexBytes(&cameraInput, length: MemoryLayout<CameraParameters>.stride, index: 2)
        
        // light inputs
        let directionalLights = self.scene.lights.filter { $0 is DirectionalLight }
        var dlInputs: [DLightParameters] = []
        if directionalLights.isEmpty {
            dlInputs = [DLightParameters(direction: .zero, color: .zero, visiable: false)]
        } else {
            dlInputs = directionalLights.map { ($0 as! DirectionalLight).shaderInput }
        }
        renderEncoder.setFragmentBytes(&dlInputs, length: MemoryLayout<DLightParameters>.stride * dlInputs.count, index: 0)
        
        let spotLights = self.scene.lights.filter { $0 is SpotLight }
        var slInputs: [SLightParameters] = []
        if spotLights.isEmpty {
            slInputs = [SLightParameters(position: .zero, direction: .zero, color: .zero, angle: 0, visiable: false)]
        } else {
            slInputs = spotLights.map { ($0 as! SpotLight).shaderInput }
        }
        renderEncoder.setFragmentBytes(&slInputs, length: MemoryLayout<SLightParameters>.stride * slInputs.count, index: 1)
        
        let pointLights = self.scene.lights.filter { $0 is PointLight }
        var plInputs: [PLightParameters] = []
        if pointLights.isEmpty {
            plInputs = [PLightParameters(position: .zero, color: .zero, visiable: false)]
        } else {
            plInputs = pointLights.map { ($0 as! PointLight).shaderInput }
        }
        renderEncoder.setFragmentBytes(&plInputs, length: MemoryLayout<PLightParameters>.stride * plInputs.count, index: 2)
        
        var lightCount = LightCount(direction: uint(dlInputs.count), spot: uint(slInputs.count), point: uint(plInputs.count))
        renderEncoder.setFragmentBytes(&lightCount, length: MemoryLayout<LightCount>.stride, index: 3)
        
        // Object inputs
        for object in self.scene.objects {
            renderEncoder.setVertexBuffer(object.mtkMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            renderEncoder.setFragmentTexture(object.mtlTexture, index: 0)
            renderEncoder.setFragmentSamplerState(object.mtlSamplerState, index: 0)
            var transform = object.transform.shaderInput
            renderEncoder.setVertexBytes(&transform, length: MemoryLayout<matrix_float4x4>.stride, index: 1)
            
            // Draw
            for submesh in object.mtkMesh.submeshes {
                renderEncoder.drawIndexedPrimitives(
                    type: .triangle, indexCount: submesh.indexCount,
                    indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset
                )
            }
        }
    }
}
