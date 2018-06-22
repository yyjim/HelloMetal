//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/22.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Metal

class BufferProvider {

    let inflightBuffersCount: Int
    private var uniformsBuffers = [MTLBuffer]()
    private var avaliableBufferIndex: Int = 0

    lazy var avaliableResourcesSemaphore: DispatchSemaphore = {
        return DispatchSemaphore(value: inflightBuffersCount)
    }()

    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()

        for _ in 0..<inflightBuffersCount {
            guard let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: []) else {
                continue
            }
            uniformsBuffers.append(uniformsBuffer)
        }
    }

    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
        let buffer = uniformsBuffers[avaliableBufferIndex]

        let bufferPointer = buffer.contents()

        memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size*Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())

        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount {
            avaliableBufferIndex = 0
        }
        return buffer
    }
}
