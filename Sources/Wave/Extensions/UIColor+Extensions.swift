//
//  UIColor+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

extension UIColor {

    /**
     Returns a `UIColor` by interpolating between two other `UIColor`s.
     - Parameter fromColor: The `UIColor` to interpolate from
     - Parameter toColor:   The `UIColor` to interpolate to (e.g. when fully interpolated)
     - Parameter progress:  The interpolation progess; must be a `CGFloat` from 0 to 1
     - Returns: The interpolated `UIColor` for the given progress point
     */
    public static func interpolate(from fromColor: UIColor, to toColor: UIColor, with progress: CGFloat) -> UIColor {
        let progress = clipUnit(value: progress)
        let fromComponents = fromColor.components
        let toComponents = toColor.components

        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// The RGBA components associated with a `UIColor` instance.
    private var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components!
        if components.count == 2 {
            return (r: components[0], g: components[0], b: components[0], a: components[1])
        } else {
            return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }
}
