//
//  CALayerAnimatablePropertyTests.swift
//  
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
@testable import Wave

final class CALayerAnimatablePropertyTests: XCTestCase {

    // MARK: - Affine Transformations

    func testAffineScale() {
        let view = UIView()

        let initialValue = CGPoint(x: 1.0, y: 1.0)
        let targetValue = CGPoint(x: 0.5, y: 0.75)

        view.transform = CGAffineTransform(scaleX: initialValue.x, y: initialValue.y)

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.scale = targetValue
        }

        XCTAssertEqual(view.transform.a, initialValue.x)
        XCTAssertEqual(view.transform.d, initialValue.y)

        XCTAssertEqual(view.animator.scale, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.transform.a, targetValue.x)
            XCTAssertEqual(view.transform.d, targetValue.y)

            XCTAssertEqual(view.animator.scale, targetValue)
        }
    }

    func testAffineTranslation() {
        let view = UIView()

        let initialValue = CGPoint(x: 10, y: 20)
        let targetValue = CGPoint(x: -5, y: 25)

        view.transform = CGAffineTransform(translationX: initialValue.x, y: initialValue.y)

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.translation = targetValue
        }

        XCTAssertEqual(view.transform.tx, initialValue.x)
        XCTAssertEqual(view.transform.ty, initialValue.y)

        XCTAssertEqual(view.animator.translation, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.transform.tx, targetValue.x)
            XCTAssertEqual(view.transform.ty, targetValue.y)

            XCTAssertEqual(view.animator.translation, targetValue)
        }
    }

    // MARK: - Corner Radius

    func testCornerRadius() {
        let view = UIView()

        let initialValue = 10.0
        let targetValue = 20.0
        view.layer.cornerRadius = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.cornerRadius = targetValue
        }

        XCTAssertEqual(view.layer.cornerRadius, initialValue)
        XCTAssertEqual(view.layer.animator.cornerRadius, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.layer.cornerRadius, targetValue)
            XCTAssertEqual(view.layer.animator.cornerRadius, targetValue)
        }
    }

    func testBorderWidth() {
        let view = UIView()

        let initialValue = 10.0
        let targetValue = 20.0
        view.layer.borderWidth = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.borderWidth = targetValue
        }

        XCTAssertEqual(view.layer.borderWidth, initialValue)
        XCTAssertEqual(view.layer.animator.borderWidth, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.layer.borderWidth, targetValue)
            XCTAssertEqual(view.layer.animator.borderWidth, targetValue)
        }
    }

    func testBorderColor() {
        let view = UIView()

        let initialValue = UIColor.red
        let targetValue = UIColor.blue

        view.layer.borderColor = initialValue.cgColor

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.borderColor = targetValue.cgColor
        }

        XCTAssertEqual(view.layer.borderColor, initialValue.cgColor)
        XCTAssertEqual(view.layer.animator.borderColor, targetValue.cgColor)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.layer.borderColor, targetValue.cgColor)
            XCTAssertEqual(view.layer.animator.borderColor, targetValue.cgColor)
        }
    }

    // MARK: - Shadows

    func testShadowOpacity() {
        let view = UIView()

        let initialValue: Float = 0.0
        let targetValue: Float = 0.4

        view.layer.shadowOpacity = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.shadowOpacity = CGFloat(targetValue)
        }

        XCTAssertEqual(view.layer.shadowOpacity, initialValue)
        XCTAssertEqual(Float(view.layer.animator.shadowOpacity), targetValue)

        wait(for: Spring.defaultAnimated) {
            XCTAssertEqual(view.layer.shadowOpacity, targetValue)
            XCTAssertEqual(Float(view.layer.animator.shadowOpacity), targetValue)
        }
    }

    func testShadowOffset() {
        let view = UIView()

        let initialValue: CGSize = CGSize(width: 0, height: 5)
        let targetValue: CGSize = CGSize(width: 10, height: 15)

        view.layer.shadowOffset = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.shadowOffset = targetValue
        }

        XCTAssertEqual(view.layer.shadowOffset, initialValue)
        XCTAssertEqual(view.layer.animator.shadowOffset, targetValue)

        wait(for: Spring.defaultAnimated) {
            XCTAssertEqual(view.layer.shadowOffset, targetValue)
            XCTAssertEqual(view.layer.animator.shadowOffset, targetValue)
        }
    }

    func testShadowRadius() {
        let view = UIView()

        let initialValue: CGFloat = 0.0
        let targetValue: CGFloat = 8.0

        view.layer.shadowRadius = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.layer.animator.shadowRadius = targetValue
        }

        XCTAssertEqual(view.layer.shadowRadius, initialValue)
        XCTAssertEqual(view.layer.animator.shadowRadius, targetValue)

        wait(for: Spring.defaultAnimated) {
            XCTAssertEqual(view.layer.shadowRadius, targetValue)
            XCTAssertEqual(view.layer.animator.shadowRadius, targetValue)
        }
    }

}
