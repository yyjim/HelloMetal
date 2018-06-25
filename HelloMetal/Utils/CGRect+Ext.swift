//
//  CGRect+Ext.swift
//  HelloMetal
//
//  Created by yyjim on 2018/6/25.
//  Copyright © 2018 yyjim. All rights reserved.
//

import UIKit
import Foundation

extension CGRect {

    init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        self.init(x: topLeft.x,
                  y: topLeft.y,
                  width: bottomRight.x - bottomRight.x ,
                  height: bottomRight.y - topRight.y)
    }

    var vertices: [(CGPoint, CGPoint)] {
        let A = (CGPoint(x: minX, y: minY), CGPoint(x: 0, y: 0))
        let B = (CGPoint(x: minX, y: maxY), CGPoint(x: 0, y: 1))
        let C = (CGPoint(x: maxX, y: maxY), CGPoint(x: 1, y: 1))
        let D = (CGPoint(x: maxX, y: minY), CGPoint(x: 1, y: 0))
        /* A  D
           B  C */
        let vertices: [(CGPoint, CGPoint)] = [A,B,C,
                                              A,C,D,]
        return vertices
    }

}

extension CGPoint
{
    func scale(sx: CGFloat, sy: CGFloat) -> CGPoint {
        return CGPoint(x: x * sx, y: y * sy)
    }

    mutating func translate(dx: CGFloat, dy: CGFloat) {
        x += dx
        y += dy
    }
}
