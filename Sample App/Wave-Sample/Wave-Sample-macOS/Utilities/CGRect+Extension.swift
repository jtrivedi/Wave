//
//  CGRect+Extension.swift
//  Wave-Sample-macOS
//
//  Created by Florian Zand on 27.10.23.
//

import Foundation

extension CGRect {
    /// The horizontal center of the rectangle.
    var centerX: CGFloat {
        get { return midX }
        set { origin.x = newValue - width * 0.5 }
    }

    /// The vertical center of the rectangle.
    var centerY: CGFloat {
        get { return midY }
        set { origin.y = newValue - height * 0.5 }
    }
    
    /// The center point of the rectangle.
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }
    
    /// The left edge of the rectangle.
    var left: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// The right edge of the rectangle.
    var right: CGFloat {
        get {return origin.x + width}
        set {origin.x = newValue - width}
    }

    #if canImport(UIKit)
    /// The top edge of the rectangle.
    var top: CGFloat {
        get {return y}
        set {y = newValue}
    }
    /// The bottom edge of the rectangle.
    var bottom: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    #else
    /// The top edge of the rectangle.
    var top: CGFloat {
        get {return origin.y + height}
        set {origin.y = newValue - height}
    }
    /// The bottom edge of the rectangle.
    var bottom: CGFloat {
        get {return origin.y}
        set {origin.y = newValue}
    }
    #endif

    /// The top-left point of the rectangle.
    var topLeft: CGPoint {
        get {return CGPoint(x: left, y: top)}
        set {left = newValue.x; top = newValue.y}
    }
    
    /// The top-center point of the rectangle.
    var topCenter: CGPoint {
        get {return CGPoint(x: centerX, y: top)}
        set {centerX = newValue.x; top = newValue.y}
    }

    /// The top-right point of the rectangle.
    var topRight: CGPoint {
        get {return CGPoint(x: right, y: top)}
        set {right = newValue.x; top = newValue.y}
    }
    
    /// The center-left point of the rectangle.
    var centerLeft: CGPoint {
        get {return CGPoint(x: left, y: centerY)}
        set {left = newValue.x; centerY = newValue.y}
    }
    
    /// The center-right point of the rectangle.
    var centerRight: CGPoint {
        get {return CGPoint(x: right, y: centerY)}
        set {right = newValue.x; centerY = newValue.y}
    }
    
    /// The bottom-left point of the rectangle.
    var bottomLeft: CGPoint {
        get {return CGPoint(x: left, y: bottom)}
        set {left = newValue.x; bottom = newValue.y}
    }
    
    /// The bottom-center point of the rectangle.
    var bottomCenter: CGPoint {
        get {return CGPoint(x: centerX, y: bottom)}
        set {centerX = newValue.x; bottom = newValue.y}
    }
    
    /// The bottom-right point of the rectangle.
    var bottomRight: CGPoint {
        get {return CGPoint(x: right, y: bottom)}
        set {right = newValue.x; bottom = newValue.y}
    }
}
