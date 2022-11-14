//
//  SpringInterpolatable.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

public protocol SpringInterpolatable: Equatable {
    associatedtype ValueType: SpringInterpolatable
    associatedtype VelocityType: VelocityProviding

    var scaledIntegral: Self { get }

    static func updateValue(spring: Spring, value: ValueType, target: ValueType, velocity: VelocityType, dt: TimeInterval) -> (value: ValueType, velocity: VelocityType)
}

public protocol VelocityProviding {
    static var zero: Self { get }
}

extension CGFloat: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGFloat
    public typealias VelocityType = CGFloat

    public static func updateValue(spring: Spring, value: CGFloat, target: CGFloat, velocity: CGFloat, dt: TimeInterval) -> (value: CGFloat, velocity: CGFloat) {
        precondition(spring.response > 0, "Shouldn't be calculating spring physics with a frequency response of zero.")

        let displacement = value - target
        let springForce = (-spring.stiffness * displacement)
        let dampingForce = (spring.dampingCoefficient * velocity)
        let force = springForce - dampingForce
        let acceleration = force / spring.mass

        let newVelocity = (velocity + (acceleration * dt))
        let newValue = (value + (newVelocity * dt))

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGSize: SpringInterpolatable, VelocityProviding {

    public typealias ValueType = CGSize
    public typealias VelocityType = CGSize

    public static func updateValue(spring: Spring, value: CGSize, target: CGSize, velocity: CGSize, dt: TimeInterval) -> (value: CGSize, velocity: CGSize) {
        let (newValueX, newVelocityX) = CGFloat.updateValue(spring: spring, value: value.width, target: target.width, velocity: velocity.width, dt: dt)
        let (newValueY, newVelocityY) = CGFloat.updateValue(spring: spring, value: value.height, target: target.height, velocity: velocity.height, dt: dt)

        let newValue = CGSize(width: newValueX, height: newValueY)
        let newVelocity = CGSize(width: newVelocityX, height: newVelocityY)

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGPoint: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGPoint
    public typealias VelocityType = CGPoint

    public static func updateValue(spring: Spring, value: CGPoint, target: CGPoint, velocity: CGPoint, dt: TimeInterval) -> (value: CGPoint, velocity: CGPoint) {

        let (newValueX, newVelocityX) = CGFloat.updateValue(spring: spring, value: value.x, target: target.x, velocity: velocity.x, dt: dt)
        let (newValueY, newVelocityY) = CGFloat.updateValue(spring: spring, value: value.y, target: target.y, velocity: velocity.y, dt: dt)

        let newValue = CGPoint(x: newValueX, y: newValueY)
        let newVelocity = CGPoint(x: newVelocityX, y: newVelocityY)

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGRect: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGRect
    public typealias VelocityType = CGRect

    public static func updateValue(spring: Spring, value: CGRect, target: CGRect, velocity: CGRect, dt: TimeInterval) -> (value: CGRect, velocity: CGRect) {
        let (origin, originVelocity) = CGPoint.updateValue(spring: spring, value: value.origin, target: target.origin, velocity: velocity.origin, dt: dt)
        let (size, sizeVelocity) = CGSize.updateValue(spring: spring, value: value.size, target: target.size, velocity: velocity.size, dt: dt)

        let newValue = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        let newVelocity = CGRect(x: originVelocity.x, y: originVelocity.y, width: sizeVelocity.width, height: sizeVelocity.height)

        return (value: newValue, velocity: newVelocity)
    }
}

extension RGBAComponents: SpringInterpolatable, VelocityProviding {

    typealias ValueType = RGBAComponents
    typealias VelocityType = RGBAComponents

    static func updateValue(spring: Spring, value: RGBAComponents, target: RGBAComponents, velocity: RGBAComponents, dt: TimeInterval) -> (value: RGBAComponents, velocity: RGBAComponents) {
        let (newR, newVelocityR) = CGFloat.updateValue(spring: spring, value: value.r, target: target.r, velocity: velocity.r, dt: dt)
        let (newG, newVelocityG) = CGFloat.updateValue(spring: spring, value: value.g, target: target.g, velocity: velocity.g, dt: dt)
        let (newB, newVelocityB) = CGFloat.updateValue(spring: spring, value: value.b, target: target.b, velocity: velocity.b, dt: dt)
        let (newA, newVelocityA) = CGFloat.updateValue(spring: spring, value: value.a, target: target.a, velocity: velocity.a, dt: dt)

        let newValue = RGBAComponents(r: newR, g: newG, b: newB, a: newA)
        let newVelocity = RGBAComponents(r: newVelocityR, g: newVelocityG, b: newVelocityB, a: newVelocityA)

        return (value: newValue, newVelocity)
    }

    var scaledIntegral: RGBAComponents {
        self
    }

    static var zero: RGBAComponents {
        RGBAComponents(r: 0, g: 0, b: 0, a: 0)
    }

}
