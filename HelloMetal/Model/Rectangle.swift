//
//  Rectangle.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/21.
//  Copyright © 2018 yyjim. All rights reserved.
//

import simd
import MetalKit
import Metal

class Rectangle: Node {

    init (device: MTLDevice) {
        let A = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u: 0, v: 0)
        let B = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u: 0, v: 1)
        let C = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u: 1, v: 1)
        let D = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, u: 1, v: 0)
        let vertices = [
            A,B,C,
            A,C,D,
        ]

        let cgImage = UIImage(named: "test")!.cgImage!
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try! textureLoader.newTexture(cgImage: cgImage, options: nil)
//        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
//        texture.loadTexture(device: device, commandQ: commandQ, flip: true)
        super.init(name: "Rectangle", vertices: vertices, device: device, texture: texture)
    }

    override func updateWithDelta(delta: CFTimeInterval) {
        super.updateWithDelta(delta: delta)

        let secsPerMove: Float = 6.0
        rotationZ = sinf( Float(time) * 2.0 * Float.pi / secsPerMove)
    }
}
