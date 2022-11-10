//
//  CGFloat+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

extension CGFloat {

    /**
     Returns a float value that is rounded to the nearest pixel boundary,
     taking into account the device's display scale.
     */
    public var scaledIntegral: CGFloat {
        let scale = UIScreen.main.scale
        return floor(self * scale) / scale
    }

    var degreesToRadians: CGFloat {
        self * .pi / 180
    }

    var radiansToDegrees: CGFloat {
        self * 180 / .pi
    }

}
