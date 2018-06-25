//
//  HMRenderer.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/22.
//  Copyright © 2018 yyjim. All rights reserved.
//

import UIKit
import MetalKit
import simd
import Metal

class HMRenderer: Renderer {

    var size: CGSize

    var projectionMatrix = Matrix4()
    var worldModelMatrix = Matrix4()

    var device: MTLDevice! = MTLCreateSystemDefaultDevice()

    private let bufferProvider: BufferProvider

    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!

    private var currentDrawable: CAMetalDrawable?
    private var currentCommandBuffer: MTLCommandBuffer?
    private var currentRenderEncoder: MTLRenderCommandEncoder?

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

    lazy var metalLayer: CAMetalLayer = {
        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = CGRect(x: 0, y:0, width: size.width, height: size.height)
        //metalLayer.frame = view.layer.frame
        return metalLayer
    }()

    init(size: CGSize) {
        self.size = size
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 20,
                                             sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
//        worldModelMatrix.translate(0.0, y: 0.0, z: -10)
//        worldModelMatrix.rotateAroundX(0, y: 0.0, z: 0)
        setup()
    }

    private func setup() {
        commandQueue = device.makeCommandQueue()

        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexProgram   = defaultLibrary.makeFunction(name: "vertex_main")
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_main")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }

    private func makeRenderComponents(with drawable: CAMetalDrawable) -> (MTLCommandBuffer?, MTLRenderCommandEncoder?) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return (nil, nil)
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction  = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0,
                                                                            green: 104.0/255.0,
                                                                            blue: 5.0/255.0, alpha: 1.0)
        return (commandBuffer, commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor))
    }

    // MARK: Drawing

    func begin() {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        let components = makeRenderComponents(with: drawable)
        guard let commandBuffer = components.0, let renderEncoder = components.1 else { return }

        currentDrawable = drawable
        currentCommandBuffer = commandBuffer
        currentRenderEncoder = renderEncoder
    }

    func end() {
        guard let currentDrawable = currentDrawable else {
            return
        }
        currentRenderEncoder?.endEncoding()
        currentCommandBuffer?.present(currentDrawable)
        currentCommandBuffer?.commit()
    }

    func plot(of vertices: [Vertex], transform: Matrix4, texture: MTLTexture) {
        guard let renderEncoder = currentRenderEncoder else {
            return
        }

        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        currentCommandBuffer?.addCompletedHandler { _ in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }

        let vertexCount = vertices.count
        var vertexData = [Float]()
        for vertex in vertices {
            vertexData += vertex.buffer
        }

        let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!

        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        // uniform data for shader
        let nodeModelMatrix = transform
        nodeModelMatrix.multiplyLeft(worldModelMatrix)
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
    }

    func plot(of vertices: [Vertex], transform: Matrix4, image: UIImage) {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try! textureLoader.newTexture(cgImage: image.cgImage!, options: nil)
        plot(of: vertices, transform: transform, texture: texture)
    }

}

