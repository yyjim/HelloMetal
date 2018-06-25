//
//  ViewController2.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/22.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation

class ViewController2: UIViewController {
    private var renderer: HMRenderer!
    private var timer: CADisplayLink!
    private var drawables = [Drawable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        renderer = HMRenderer(size: view.frame.size)
        drawables.append(Polygon())

        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)

        view.layer.addSublayer(renderer.metalLayer)
    }

    @objc func newFrame(displayLink: CADisplayLink) {
        autoreleasepool {
            renderer.begin()
            drawables.forEach({ (drawable) in
                drawable.draw(into: renderer)
            })
            renderer.end()
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let window = view.window {
            let scale = window.screen.nativeScale
            let layerSize = view.bounds.size

            view.contentScaleFactor = scale
            renderer.metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            renderer.metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)

            let aspectRatio = Float(view.bounds.size.width / view.bounds.size.height)
            renderer.projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 35),
                                                                         aspectRatio: aspectRatio,
                                                                         nearZ: 0.01,
                                                                         farZ: 100.0)
        }

    }
}
