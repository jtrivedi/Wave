//
//  AnimatableData.swift
//
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import Decomposed
import simd

/**
 A protocol that describes an animatable value type.
 
 A double array  (``AnimatableVector``) conforms to `VectorArithmetic` and can be used as animatable data.
 
 Example:
 ```swift
 public struct SomeStruct {
    let value1: CGFloat
    let value2: CGFloat
 }
 
 extension SomeStruct: AnimatableData {
    public var animatableData: AnimatableVector {
        [value1, value2]
    }
 
    public init(_ animatableData: AnimatableVector) {
        self.value1 = animatableData[0]
        self.value1 = animatableData[1]
    }
 
    public static var zero: Self = SomeStruct(value1: 0, value2: 0)
 }
 ```
 */
public protocol AnimatableData: Equatable, Comparable {
    /// The type defining the data to animate.
    associatedtype AnimatableData: VectorArithmetic = Self
    /// The data to animate.
    var animatableData: AnimatableData { get }
    /// Initializes with the specified data.
    init(_ animatableData: AnimatableData)
    /// Scaled integral representation of the value.
    var scaledIntegral: Self { get }
    static var zero: Self { get }
}

public extension AnimatableData {
    var scaledIntegral: Self {
        self
    }
}

extension AnimatableData where Self.AnimatableData: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.animatableData < rhs.animatableData
    }
}

extension AnimatableData where Self.AnimatableData == Self {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension Float: AnimatableData { }
 
extension Double: AnimatableData {
    public var animatableData: Self {
        self
    }
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGFloat: AnimatableData {
    public var animatableData: Self {
        self
    }
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGPoint: AnimatableData {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        [x, y]
    }
    
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(x: animatableData.first, y: animatableData.second)
    }
}

extension CGSize: AnimatableData {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        [width, height]
    }
    
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(width: animatableData.first, height: animatableData.second)
    }
}

extension CGRect: AnimatableData {
    public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
        [self.origin.animatableData, self.size.animatableData]
    }
    
    public init(_ animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData>) {
        self.init(origin: CGPoint(animatableData.first), size: CGSize(animatableData.second))
    }
}

extension CATransform3D: AnimatableData {
    public init(_ animatableData: AnimatableVector) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }
    
    public var animatableData: AnimatableVector {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension AnimatableData where Self: WaveColor {
    public init(_ animatableData: AnimatableVector) {
        self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
    }
}

extension WaveColor: AnimatableData {
    public var animatableData: AnimatableVector {
                let rgba = self.rgbaComponents
        return [rgba.r, rgba.g, rgba.b, rgba.a]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension AnimatableData where Self: CGColor {
    public init(_ animatableData: AnimatableVector) {
        self = WaveColor(animatableData).cgColor as! Self
      //  self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
    }
}

extension CGColor: AnimatableData {
    public var animatableData: AnimatableVector {
        let rgba = self.waveColor?.rgbaComponents ?? .init(r: 0, g: 0, b: 0, a: 0)
        return [rgba.r, rgba.g, rgba.b, rgba.a]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    internal var waveColor: WaveColor? {
        return WaveColor(cgColor: self)
    }
}

extension Array: AnimatableData, Comparable where Self.Element == Double { }

extension CGAffineTransform: AnimatableData {
    @inlinable public init(_ animatableData: AnimatableVector) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }
    
    /// `SIMD8` representation of the value.
    public var animatableData: AnimatableVector {
        return [a, b, c, d, tx, ty, 0, 0]
    }
    
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension CGQuaternion: AnimatableData {
    public init(_ animatableData: AnimatableVector) {
        self.init(simd_quatd(ix: animatableData[0], iy: animatableData[0], iz: animatableData[0], r: animatableData[0]))
    }
    
    public var animatableData: AnimatableVector {
        [self.axis.x, self.axis.y, self.axis.z, self.angle]
    }
    
    public static var zero: CGQuaternion {
        CGQuaternion(.zero)
    }
}

extension NSDirectionalEdgeInsets: AnimatableData {
    public static var zero: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.init(top: animatableData[0], leading: animatableData[1], bottom: animatableData[2], trailing: animatableData[3])
    }
    
    public var animatableData: AnimatableVector {
        [top, bottom, leading, trailing]
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
extension SwiftUI.Spring {
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V : AnimatableData {
        var val = value.animatableData
        var vel = velocity.animatableData
        let tar = target.animatableData
                
        self.update(value: &val, velocity: &vel, target: tar, deltaTime: deltaTime)
        
        value = V(val)
        velocity = V(vel)
    }
}



