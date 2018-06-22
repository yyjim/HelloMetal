//
//  Node.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/21.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation
import simd
import MetalKit
import Metal
import QuartzCore

class Node {

    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer

    var bufferProvider: BufferProvider

    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0

    var time = CFTimeInterval(0.0)

    var texture: MTLTexture?

    lazy var samplerState: MTLSamplerState? = {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = Float.greatestFiniteMagnitude
        return device.makeSamplerState(descriptor: sampler)
    }()

    var matrix: Matrix4 {
        let t = Matrix4()
        t.translate(positionX, y: positionY, z: positionZ)
        t.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        t.scale(scale, y: scale, z: scale)
        return t
    }

    init(name: String, vertices: [Vertex], device: MTLDevice, texture: MTLTexture? = nil) {
        var vertexData = [Float]()
        for vertex in vertices {
            vertexData += vertex.buffer
        }

        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!

        self.name = name
        self.device = device
        self.texture = texture
        vertexCount = vertices.count

        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3,
                                             sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
    }

    func render(with renderEncoder: MTLRenderCommandEncoder,
                pipelineState: MTLRenderPipelineState,
                parentModelViewMatrix: Matrix4,
                projectionMatrix: Matrix4) -> (() -> Void)
    {
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)

        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        // uniform data for shader
        let nodeModelMatrix = matrix
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix,
                                                              modelViewMatrix: nodeModelMatrix)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        renderEncoder.setFragmentTexture(texture, index: 0)
        if let samplerState = samplerState {
            renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        }

        // Draw
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: vertexCount,
                                     instanceCount: vertexCount / 3)
        return {
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
    }

    func updateWithDelta(delta: CFTimeInterval) {
        time += delta
    }
}
