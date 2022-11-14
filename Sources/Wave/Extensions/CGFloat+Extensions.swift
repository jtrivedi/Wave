//
//  CGFloat+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension CGFloat {

    /**
     Returns a float value that is rounded to the nearest pixel boundary,
     taking into account the device's display scale.
     */
    public var scaledIntegral: CGFloat {
#if os(iOS)
        let scale = UIScreen.main.scale
#elseif os(macOS)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
#endif
        return floor(self * scale) / scale
    }

    var degreesToRadians: CGFloat {
        self * .pi / 180
    }

    var radiansToDegrees: CGFloat {
        self * 180 / .pi
    }

}
