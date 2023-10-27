//
//  VectorArithmetic+.swift
//
//
//  Created by Florian Zand on 20.10.23.
//

import SwiftUI
import Accelerate
import Foundation

/// A double array (that can be used as animatable data to conform ``AnimatableData``.
public typealias AnimatableVector = Array<Double>

extension AnimatableVector: AdditiveArithmetic, VectorArithmetic {
    public static var zero: Self = [0.0]
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        vDSP.add(lhs, rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.add(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        vDSP.subtract(lhs, rhs)
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.subtract(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }


    public mutating func scale(by rhs: Double) {
        self = vDSP.multiply(rhs, self)
    }

    public var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(self, self))
    }
}

extension AnimatableVector {
    public static func * (lhs: Self, rhs: Self) -> Self {
        vDSP.multiply(lhs, rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.multiply(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }
    
    public static func / (lhs: Self, rhs: Self) -> Self {
        vDSP.divide(lhs, rhs)
    }
    
    public static func /= (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.divide(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }
}

extension AnimatablePair: ExpressibleByArrayLiteral where First == Second {
    public init(arrayLiteral elements: First...) {
        self.init(elements[0], elements[1])
    }
}

extension AnimatablePair: Comparable where First: Comparable, First == Second {
    public static func < (lhs: AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) -> Bool {
        lhs.first < rhs.first && lhs.second < rhs.second
    }
}

extension VectorArithmetic {
    public static func * (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: rhs)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: rhs)
    }
    
    public static func / (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: 1.0 / rhs)
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: 1.0 / rhs)
    }
    
    public static prefix func - (lhs: Self) -> Self {
        lhs * -1
    }
}
