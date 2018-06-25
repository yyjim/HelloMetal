//
//  CVPixelBuffer+Ext.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/25.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Metal
import Foundation

extension CVPixelBuffer {

    func convertToMTLTexture(with textureCache: CVMetalTextureCache) -> MTLTexture? {
        var texture: MTLTexture?
        let width  = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        let format = MTLPixelFormat.bgra8Unorm
        var outTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               textureCache, self, nil,
                                                               format,
                                                               width,
                                                               height,
                                                               0,
                                                               &outTexture)
        if(status == kCVReturnSuccess) {
            texture = CVMetalTextureGetTexture(outTexture!)
        }
        return texture
    }
    
}
