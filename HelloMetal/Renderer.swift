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
}

protocol Drawable {
    func draw(into renderer: Renderer)
}

struct Polygon : Drawable {

    let vertices: [Vertex]
    var transform: Matrix4 {
        let t = Matrix4()
        t.translate(positionX, y: positionY, z: positionZ)
        t.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        t.scale(scale, y: scale, z: scale)
        return t

    }

    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0

    init() {
        let A = Vertex(x: -1.0, y:  1.7786666666666666, z:  0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u: 0, v: 0)
        let B = Vertex(x: -1.0, y: -1.7786666666666666, z:  0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u: 0, v: 1)
        let C = Vertex(x:  1.0, y: -1.7786666666666666, z:  0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u: 1, v: 1)
        let D = Vertex(x:  1.0, y:  1.7786666666666666, z:  0.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, u: 1, v: 0)
        let vertices = [
            A,B,C,
            A,C,D,
            ]
        self.vertices = vertices
    }

    func draw(into renderer: Renderer) {
        let image = UIImage(named: "test")!
        renderer.plot(of: vertices, transform: transform, image: image)
    }
}
