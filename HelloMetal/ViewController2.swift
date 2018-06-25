//
//  ViewController2.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/22.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation
import AVFoundation

class ViewController2: UIViewController {
    private var renderer: HMRenderer!
    private var timer: CADisplayLink!
    private var polygon: Polygon!
    private var drawables = [Drawable]()
    private let player = AVPlayer()

    private let videoURL = Bundle.main.url(forResource: "jason", withExtension: "mp4")!

    lazy var playerItemVideoOutput: AVPlayerItemVideoOutput = {
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        return AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        renderer = HMRenderer(size: view.frame.size)
        let polygon1 = Polygon(frame: CGRect(x: 0, y: 0, width: 100, height: 200),
                               device: renderer.device)
        let polygon2 = Polygon(frame: CGRect(x: 100, y: 200, width: 100, height: 100),
                               device: renderer.device)
        drawables.append(polygon1)
        drawables.append(polygon2)

        timer = CADisplayLink(target: self, selector: #selector(ViewController2.newFrame(sender:)))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)

        view.layer.addSublayer(renderer.metalLayer)

        // Create an av asset for the given url.
        let playerItem = AVPlayerItem(asset: AVURLAsset(url: videoURL))
        playerItem.add(playerItemVideoOutput)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    @objc func newFrame(sender: CADisplayLink) {
        autoreleasepool {
            var currentTime = CMTime.invalid
            let nextVSync = sender.timestamp + sender.duration
            currentTime = playerItemVideoOutput.itemTime(forHostTime: nextVSync)

            if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime),
                let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                drawables.forEach({ (d) in
                    if let d = d as? Polygon {
                        d.pixelBuffer = pixelBuffer
                    }
                })
            }

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
