//
//  Vertex.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/21.
//  Copyright © 2018 yyjim. All rights reserved.
//

import simd
import Foundation

struct Vertex {

    var position: float4 {
        return float4(x, y, z, w)
    }

    var color: float4 {
        return float4(r, g, b, a)
    }

    var x,y,z,w: Float // position data
    var r,g,b,a: Float // color data

    var buffer: [float4] {
        return [position, color]
    }

    init(x: Float, y: Float, z: Float, w: Float = 1, r: Float, g: Float, b: Float, a: Float) {
        (self.x, self.y, self.z, self.w) = (x, y, z, w)
        (self.r, self.g, self.b, self.a) = (r, g, b, a)
    }

    init(position: float4, color: float4) {
        self.init(x: position.x, y: position.y, z: position.z, w: position.w,
                  r: color.x, g: color.y, b: color.z, a: color.w)
    }

    mutating func scale(v: Float) {
        x *= v
        y *= v
        z *= v
    }
}
