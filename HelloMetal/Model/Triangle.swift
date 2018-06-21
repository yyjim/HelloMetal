//
//  Triangle.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/21.
//  Copyright © 2018 yyjim. All rights reserved.
//

import simd
import MetalKit
import Metal

class Triangle: Node {

    init (device: MTLDevice) {
        let vertices = [
            Vertex(position: float4( 0.0,  1.0, 0, 1), color: float4(1, 0, 0, 1)),
            Vertex(position: float4(-1.0, -1.0, 0, 1), color: float4(0, 1, 0, 1)),
            Vertex(position: float4( 1.0, -1.0, 0, 1), color: float4(0, 0, 1, 1))
        ]

        let cgImage = UIImage(named: "test")!.cgImage!
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try! textureLoader.newTexture(cgImage: cgImage, options: nil)

        super.init(name: "Triangle", vertices: vertices, device: device, texture: texture)
    }

}
