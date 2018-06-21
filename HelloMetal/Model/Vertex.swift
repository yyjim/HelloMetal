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

    var texCoord: float2 {
        return float2(u,v)
    }

    var x,y,z,w: Float // position data
    var r,g,b,a: Float // color data
    var u,v    : Float // u, v

    var buffer: [Float] {
        return [x,y,z,w,r,g,b,a,u,v]
    }

    init(x: Float, y: Float, z: Float, w: Float = 1, r: Float, g: Float, b: Float, a: Float, u: Float = 0, v: Float = 0) {
        (self.x, self.y, self.z, self.w) = (x, y, z, w)
        (self.r, self.g, self.b, self.a) = (r, g, b, a)
        (self.u, self.v) = (u, v)
    }

    init(position: float4, color: float4, texCoords: float2 = float2(0)) {
        self.init(x: position.x, y: position.y, z: position.z, w: position.w,
                  r: color.x, g: color.y, b: color.z, a: color.w,
                  u: texCoords.x, v: texCoords.y)
    }

    mutating func scale(v: Float) {
        x *= v
        y *= v
        z *= v
    }
}
