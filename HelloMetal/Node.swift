//
//  Node.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/21.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation
import simd
import Metal
import QuartzCore

class Node {

    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer

    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0

    var time = CFTimeInterval(0.0)

    var matrix: Matrix4 {
        let t = Matrix4()
        t.translate(positionX, y: positionY, z: positionZ)
        t.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        t.scale(scale, y: scale, z: scale)
        return t
    }

    init(name: String, vertices: [Vertex], device: MTLDevice) {
        var vertexData = [float4]()
        for vertex in vertices {
            vertexData += vertex.buffer
        }

        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!

        self.name = name
        self.device = device
        vertexCount = vertices.count
    }


    func render(commandQueue: MTLCommandQueue,
                pipelineState: MTLRenderPipelineState,
                drawable: CAMetalDrawable,
                parentModelViewMatrix: Matrix4,
                projectionMatrix: Matrix4,
                clearColor: MTLClearColor?)
    {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor ?? MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        // uniform data for shader
        let nodeModelMatrix = matrix
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2,
                                              options: [])!
        let bufferPointer = uniformBuffer.contents()
        // Copy your matrix data into the buffer.
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())

        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        // Draw
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: vertexCount,
                                     instanceCount: vertexCount / 3)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func updateWithDelta(delta: CFTimeInterval) {
        time += delta
    }
}
