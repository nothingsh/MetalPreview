//
//  Scene.swift
//  MetalPreview
//
//  Created by Wynn Zhang on 10/10/23.
//

import Foundation

public class Scene {
    public private(set) var camera: Camera
    public private(set) var objects: [Object]
    
    // Lights
    private(set) var lights: [Lightable]
    
    public init() {
        self.camera = Camera(transform: .origin)
        self.objects = []
        self.lights = []
    }
    
    public func addObject(transform: Transform = .origin, meshURL: URL, textureURL: URL) {
        let object = Object(transform: transform, mesh: meshURL, texture: textureURL)
        self.objects.append(object)
    }
    
    public func removeObject(object: Object) {
        guard let index = self.objects.firstIndex(where: { $0 === object }) else {
            return
        }
        
        self.objects.remove(at: index)
    }
    
    public func addLight(light: Lightable) {
        self.lights.append(light)
    }
    
    public func removeLight(light: Lightable) {
        guard let index = self.lights.firstIndex(where: { $0 === light }) else {
            return
        }
        
        self.lights.remove(at: index)
    }
}
