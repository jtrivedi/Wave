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
    var rgbaComponents: RGBAComponents {
        RGBAComponents(color: self)
    }
    
    internal var isVisible: Bool {
        self.alphaComponent != 0.0
    }
}

#if os(iOS) || os(tvOS)
public extension WaveColor {
    /**
     The red component as CGFloat between 0.0 to 1.0.
     */
    var redComponent: CGFloat {
      return rgbaComponents.r
    }

    /**
     The green component as CGFloat between 0.0 to 1.0.
     */
    var greenComponent: CGFloat {
      return rgbaComponents.g
    }

    /**
     The blue component as CGFloat between 0.0 to 1.0.
     */
    var blueComponent: CGFloat {
      return rgbaComponents.b
    }

    /**
     The alpha component as CGFloat between 0.0 to 1.0.
     */
    var alphaComponent: CGFloat {
      return rgbaComponents.a
    }
}

public extension CGColor {
    /// The clear color in the Generic gray color space.
    static var clear: CGColor {
        return UIColor.clear.cgColor
    }
}
#endif
