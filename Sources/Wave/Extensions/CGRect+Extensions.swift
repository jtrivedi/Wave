//
//  CGRect+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

extension CGRect {

    /**
     Returns a rect whose `origin` and `size` are rounded to the nearest pixel boundary,
     taking into account the device's display scale.
     */
    public var scaledIntegral: CGRect {
        CGRect(
            x: origin.x.scaledIntegral,
            y: origin.y.scaledIntegral,
            width: size.width.scaledIntegral,
            height: size.height.scaledIntegral
        )
    }

    /**
     Creates a `CGRect` of a given size, centered at a given point.
     - parameter point: The desired center point of the new rect.
     - parameter size: The desired size of the new rect.
     - parameter integralized: Whether the components of the rect should be integralized, such that it falls on pixel boundaries. See ``scaledIntegral`` for more information.
     */
    init(aroundPoint point: CGPoint, size: CGSize, integralized: Bool = false) {
        let unintegralizedRect = CGRect(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0, width: size.width, height: size.height)
        let result = integralized ? unintegralizedRect.scaledIntegral : unintegralizedRect
        self.init(x: result.origin.x, y: result.origin.y, width: result.size.width, height: result.size.height)
    }

    /**
     The center point of the rect.
     */
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            origin.x = newValue.x - size.width / 2.0
            origin.y = newValue.y - size.height / 2.0
        }
    }

}
