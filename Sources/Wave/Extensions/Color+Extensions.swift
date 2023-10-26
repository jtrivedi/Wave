//
//  UIColor+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import QuartzCore

#if os(iOS)
import UIKit

extension UIColor {
    convenience init(_cgColor: CGColor) {
        self.init(cgColor: _cgColor)
    }
}

#elseif os(macOS)
import AppKit
extension NSColor {
    convenience init(_cgColor: CGColor) {
        // To revisit: shouldn't force unwrap this.
        self.init(cgColor: _cgColor)!
    }
}
#endif

struct RGBAComponents: Equatable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat

    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(color: WaveColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(r: r, g: g, b: b, a: a)
    }

    var uiColor: WaveColor {
        WaveColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension WaveColor {

    /**
     Returns a `UIColor` by interpolating between two other `UIColor`s.
     - Parameter fromColor: The `UIColor` to interpolate from
     - Parameter toColor:   The `UIColor` to interpolate to (e.g. when fully interpolated)
     - Parameter progress:  The interpolation progess; must be a `CGFloat` from 0 to 1
     - Returns: The interpolated `UIColor` for the given progress point
     */
    public static func interpolate(from fromColor: WaveColor, to toColor: WaveColor, with progress: CGFloat) -> WaveColor {
        let progress = clipUnit(value: progress)
        let fromComponents = fromColor.rgbaComponents
        let toComponents = toColor.rgbaComponents

        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a

        return WaveColor(red: r, green: g, blue: b, alpha: a)
    }

    var rgbaComponents: RGBAComponents {
        RGBAComponents(color: self)
    }
    
    var isVisible: Bool {
        self.alphaComponent != 0.0
    }
}

#if os(iOS) || os(tvOS)
public extension WaveColor {
    /**
     The red component as CGFloat between 0.0 to 1.0.
     */
    var redComponent: CGFloat {
      return rgbaComponents().red
    }

    /**
     The green component as CGFloat between 0.0 to 1.0.
     */
    var greenComponent: CGFloat {
      return rgbaComponents().green
    }

    /**
     The blue component as CGFloat between 0.0 to 1.0.
     */
    var blueComponent: CGFloat {
      return rgbaComponents().blue
    }

    /**
     The alpha component as CGFloat between 0.0 to 1.0.
     */
    var alphaComponent: CGFloat {
      return rgbaComponents().alpha
    }
}
#endif
