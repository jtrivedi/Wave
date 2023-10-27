//
//  NSBezierPath+Extension.swift
//  Wave-Sample-macOS
//
//  Created by Florian Zand on 27.10.23.
//

#if os(macOS)
import AppKit

public extension NSBezierPath {

    convenience init(roundedRect rect: NSRect, byRoundingCorners corners: NSRectCorner, cornerRadius radius: CGFloat) {
        
        self.init()
        
        let radius = radius.clamped(to: 0...(min(rect.width, rect.height) / 2))
        
        let topLeft = NSPoint(x: rect.minX, y: rect.minY)
        let topRight = NSPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY)
        self.move(to: topLeft.offset(xValue: 0, yValue: radius))
        self.appendArc(from: topLeft, to: topRight, radius: corners.contains(.topLeft) ? radius : 0)
        self.appendArc(from: topRight, to: bottomRight, radius: corners.contains(.topRight) ? radius : 0)
        self.appendArc(from: bottomRight, to: bottomLeft, radius: corners.contains(.bottomRight) ? radius : 0)
        self.appendArc(from: bottomLeft, to: topLeft, radius: corners.contains(.bottomLeft) ? radius : 0)
        self.close()
    }
    

    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for index in 0 ..< elementCount {
            let type = element(at: index, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo:
                path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo:
                path.addCurve(
                    to: CGPoint(x: points[2].x, y: points[2].y),
                    control1: CGPoint(x: points[0].x, y: points[0].y),
                    control2: CGPoint(x: points[1].x, y: points[1].y)
                )
            case .closePath:
                path.closeSubpath()
            default:
                break
            }
        }
        return path
    }
}


public struct NSRectCorner: OptionSet, Sendable {
    public let rawValue: UInt
    /// The top-left corner of the rectangle.
    public static let topLeft = NSRectCorner(rawValue: 1 << 0)
    /// The top-right corner of the rectangle.
    public static let topRight = NSRectCorner(rawValue: 1 << 1)
    /// The bottom-left corner of the rectangle.
    public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    /// The bottom-right corner of the rectangle.
    public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
    /// All corners of the rectangle.
    public static var allCorners: NSRectCorner {
        return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    /// Creates a structure that represents the corners of a rectangle.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

#endif
