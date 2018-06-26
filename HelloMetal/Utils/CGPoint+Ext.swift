//
//  CGPoint+Ext.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/26.
//  Copyright © 2018 yyjim. All rights reserved.
//

import Foundation

extension CGPoint
{
    func scale(sx: CGFloat, sy: CGFloat) -> CGPoint {
        return CGPoint(x: x * sx, y: y * sy)
    }

    mutating func translate(dx: CGFloat, dy: CGFloat) {
        x += dx
        y += dy
    }

    func rotate(by degrees: CGFloat, around pivot: CGPoint) -> CGPoint {
        /*  Manually calcuate the point
            let dx = self.x - pivot.x
            let dy = self.y - pivot.y
            let radius  = sqrt(dx * dx + dy * dy)
            let azimuth = atan2(dy, dx) // in radians
            let newAzimuth = azimuth + degrees * (CGFloat.pi / 180.0) // convert it to radians
            let x = pivot.x + radius * cos(newAzimuth)
            let y = pivot.y + radius * sin(newAzimuth)
            return CGPoint(x: x, y: y)
        */
        let angle = degrees * (CGFloat.pi / 180.0)
        let transform = CGAffineTransform(translationX: pivot.x, y: pivot.y)
                        .rotated(by: angle)
                        .translatedBy(x: -pivot.x, y: -pivot.y)
        
        return self.applying(transform)
    }
}

