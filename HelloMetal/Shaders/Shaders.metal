//
//  Shaders.metal
//  HelloMetal
//
//  Created by yyjim on 2018/6/20.
//  Copyright © 2018 yyjim. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float4 position;
    packed_float4 color;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(const device VertexIn *vertices [[buffer(0)]],
                             const device Uniforms& uniforms [[buffer(1)]],
                             uint vid [[vertex_id]])
{
    float4x4 mv_Matrix   = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;

    VertexIn vertexIn = vertices[vid];

    VertexOut vertexOut;
//    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position);
    vertexOut.position = float4(vertexIn.position);
    vertexOut.color = vertexIn.color;
    vertexOut.texCoord = vertexIn.texCoord;
    return vertexOut;
}

fragment float4 fragment_main(VertexOut interpolated [[stage_in]],
                              texture2d<float>  tex2D     [[ texture(0) ]],
                              sampler           sampler2D [[ sampler(0) ]])
{
    float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
    return color;
}

//fragment float4 fragment_main(VertexOut inVertex [[stage_in]]) {
//    return inVertex.color;
//}

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
