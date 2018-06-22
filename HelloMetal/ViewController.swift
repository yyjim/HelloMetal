//
//  ViewController.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/20.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Metal
import UIKit
import simd

class ViewController: UIViewController {

    struct Vertex {
        var position: float4
        var color: float4
    }

    var device: MTLDevice! = MTLCreateSystemDefaultDevice()

    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var nodes = [Node]()

    var timer: CADisplayLink!

    var lastFrameTimestamp = CFTimeInterval(0.0)

    var projectionMatrix = Matrix4()
    var modelTransformationMatrix = Matrix4()

    lazy var metalLayer: CAMetalLayer = {
        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        return metalLayer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let aspectRatio = Float(view.bounds.size.width / view.bounds.size.height)
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0),
                                                            aspectRatio: aspectRatio,
                                                            nearZ: 0.01,
                                                            farZ: 100.0)

        nodes.append(Rectangle(device: device))
        nodes.append(Rectangle(device: device))
        nodes.append(Rectangle(device: device))
        nodes.append(Rectangle(device: device))
        nodes.append(Triangle(device: device))

        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexProgram   = defaultLibrary.makeFunction(name: "vertex_main")
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_main")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }

    func makeRenderComponents(with drawable: CAMetalDrawable) -> (MTLCommandBuffer?, MTLRenderCommandEncoder?) {
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

    func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        let components = makeRenderComponents(with: drawable)
        guard let commandBuffer = components.0, let renderEncoder = components.1 else { return }

        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(0, y: 0.0, z: 0.0)

        for node in nodes {
            node.render(with: renderEncoder,
                        pipelineState: pipelineState,
                        parentModelViewMatrix: worldModelMatrix,
                        projectionMatrix: projectionMatrix)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    @objc func newFrame(displayLink: CADisplayLink) {
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }

        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp

        gameloop(timeSinceLastUpdate: elapsed)
    }

    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        for node in nodes {
            node.updateWithDelta(delta: timeSinceLastUpdate)
        }
        autoreleasepool {
            self.render()
        }
    }
}

