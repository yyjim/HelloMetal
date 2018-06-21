//
//  Shaders.metal
//  HelloMetal
//
//  Created by yyjim on 2018/6/20.
//  Copyright © 2018 yyjim. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex Vertex vertex_main(const device Vertex *vertices [[buffer(0)]],
                          const device Uniforms& uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;

    Vertex vout = vertices[vid];
    vout.position = proj_Matrix * mv_Matrix * float4(vout.position);
    return vout;
}

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}

//vertex float4 basic_vertex(const device float4 * vertex_array [[ buffer(0) ]],
//                           unsigned int vid [[ vertex_id ]])
//{
//    return vertex_array[vid];
//}
//
//
//fragment half4 basic_fragment() {
//    return half4(1.0);
//}
