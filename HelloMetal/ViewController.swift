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

    var objectToDraw: Node!
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

        objectToDraw = Cube(device: device)
//        objectToDraw.positionX = 0.0
//        objectToDraw.positionY =  0.0
//        objectToDraw.positionZ = -2.0
//        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45)
//        objectToDraw.scale = 0.5

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
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }

        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)

        objectToDraw.render(commandQueue: commandQueue,
                            pipelineState: pipelineState,
                            drawable: drawable,
                            parentModelViewMatrix: worldModelMatrix,
                            projectionMatrix: projectionMatrix,
                            clearColor: nil)
    }

    @objc func gameloop() {
      autoreleasepool {
        self.render()
        }
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
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        autoreleasepool {
            self.render()
        }
    }
}

