//
//  Renderer.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/22.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation

protocol Renderer {

    func begin()
    func end()
    
    func plot(of vertices: [Vertex], transform: Matrix4, image: UIImage)
    func plot(of vertices: [Vertex], transform: Matrix4, texture: MTLTexture)
}

protocol Drawable {
    func draw(into renderer: Renderer)
}

class Polygon : Drawable {

    let device: MTLDevice
    var pixelBuffer: CVPixelBuffer?

    private lazy var textureCache: CVMetalTextureCache = {
        // Initialize the cache to convert the pixel buffer into a Metal texture.
        var textureCache: CVMetalTextureCache?
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache) == kCVReturnSuccess else {
            fatalError("Unable to allocate texture cache.")
        }
        return textureCache!
    }()

    var vertices: [Vertex]!
    var transform: Matrix4 {
        let t = Matrix4()
        t.translate(positionX, y: positionY, z: positionZ)
        t.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        t.scale(scale, y: scale, z: scale)
        return t

    }

    var frame: CGRect {
        didSet {
            updateVertices()
        }
    }

    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 10.0
    var scale: Float     = 1.0

    init(frame: CGRect, device: MTLDevice) {
        self.device = device
        self.frame = frame
        updateVertices()
    }

    func draw(into renderer: Renderer) {
        guard let texture = self.pixelBuffer?.convertToMTLTexture(with: textureCache) else {
            return
        }
        renderer.plot(of: vertices, transform: transform, texture: texture)
    }

    private func updateVertices() {
        let viewportSize = UIScreen.main.bounds.size
        let vs = frame.vertices
        vertices = vs.map { (position, texCoord) in
            let pivot = CGPoint(x: frame.midX, y: frame.midY)
            var p = position.rotate(by: 45, around: pivot)
            p = p.scale(sx: 1 / (viewportSize.width / 2), sy: 1 / (viewportSize.height / 2))
            p = p.scale(sx: 1, sy: -1)
            p.translate(dx: -1, dy: 1)
            let (x, y) = (Float(p.x), Float(p.y))
            let (u, v) = (Float(texCoord.x), Float(texCoord.y))
            return Vertex(x: x, y: y, z:  0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u: u, v: v)
        }

    }
}
