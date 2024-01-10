//
//  UIViewAnimatablePropertyTests.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
@testable import Wave

#if os(iOS)
import UIKit

final class UIViewAnimatablePropertyTests: XCTestCase {

    func testFrame() {
        let view = UIView()

        let initialFrame = CGRect(x: 0, y: 0, width: 50, height: 100)
        let targetFrame = CGRect(x: 20, y: 40, width: 100, height: 200)

        view.frame = initialFrame

        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, initialFrame)

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.frame = targetFrame
        }

        // Frame
        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, targetFrame)

        // Bounds
        XCTAssertEqual(view.bounds, CGRect(origin: .zero, size: initialFrame.size))
        XCTAssertEqual(view.animator.bounds, CGRect(origin: .zero, size: targetFrame.size))

        // Bounds Size
        XCTAssertEqual(view.bounds.size, initialFrame.size)
        XCTAssertEqual(view.animator.bounds.size, targetFrame.size)

        // Frame Origin
        XCTAssertEqual(view.frame.origin, initialFrame.origin)
        XCTAssertEqual(view.animator.frame.origin, targetFrame.origin)

        // Frame Center
        XCTAssertEqual(view.center, initialFrame.center)
        XCTAssertEqual(view.animator.center, targetFrame.center)

        XCTAssertNotEqual(view.frame, view.animator.frame)
        XCTAssertNotEqual(view.bounds, view.animator.bounds)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.frame, view.animator.frame)
            XCTAssertEqual(view.bounds, view.animator.bounds)
        }
    }

    func testBoundsSize() {
        let view = UIView()

        let initialFrame = CGRect(x: 20, y: 40, width: 50, height: 100)
        let targetSize = CGSize(width: 100, height: 200)

        view.frame = initialFrame

        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, initialFrame)

        let referenceView = UIView(frame: initialFrame)
        referenceView.bounds.size = targetSize

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.bounds.size = targetSize
        }

        // Frame
        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, referenceView.frame)

        // Bounds
        XCTAssertEqual(view.bounds, CGRect(origin: .zero, size: initialFrame.size))
        XCTAssertEqual(view.animator.bounds, referenceView.bounds)

        // Center
        XCTAssertEqual(view.center, initialFrame.center)
        XCTAssertEqual(view.animator.center, referenceView.center)

        // Origin
        XCTAssertEqual(view.frame.origin, initialFrame.origin)
        XCTAssertEqual(view.animator.frame.origin, referenceView.frame.origin)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.frame, view.animator.frame)
            XCTAssertEqual(view.bounds, view.animator.bounds)
        }
    }

    func testNonAnimatedBoundsSize() {
        let v = UIView()

        let initialBoundsSize = CGSize(width: 50, height: 50)
        let targetFrameSize = CGSize(width: 25, height: 25)

        v.bounds.size = initialBoundsSize
        v.animator.scale = CGPoint(x: 0.5, y: 0.5)

        XCTAssertEqual(v.bounds.size, initialBoundsSize)
        XCTAssertEqual(v.frame.size, targetFrameSize)
    }

    func testCenter() {
        let view = UIView()

        let initialFrame = CGRect(x: 20, y: 40, width: 50, height: 100)
        let targetCenter = CGPoint(x: 100, y: 200)

        view.frame = initialFrame

        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, initialFrame)

        let referenceView = UIView(frame: initialFrame)
        referenceView.center = targetCenter

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.center = targetCenter
        }

        // Frame
        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, referenceView.frame)

        // Bounds
        XCTAssertEqual(view.bounds, CGRect(origin: .zero, size: initialFrame.size))
        XCTAssertEqual(view.animator.bounds, referenceView.bounds)

        // Center
        XCTAssertEqual(view.center, initialFrame.center)
        XCTAssertEqual(view.animator.center, referenceView.center)

        // Origin
        XCTAssertEqual(view.frame.origin, initialFrame.origin)
        XCTAssertEqual(view.animator.frame.origin, referenceView.frame.origin)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.frame, view.animator.frame)
            XCTAssertEqual(view.bounds, view.animator.bounds)
        }
    }

    func testFrameValuesWithoutAnimation() {
        let initialFrame = CGRect(x: 0, y: 0, width: 50, height: 100)

        let view = UIView()
        view.frame = initialFrame

        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, initialFrame)

        // Frame
        XCTAssertEqual(view.frame, initialFrame)
        XCTAssertEqual(view.animator.frame, initialFrame)

        // Bounds
        XCTAssertEqual(view.bounds, CGRect(origin: .zero, size: initialFrame.size))
        XCTAssertEqual(view.animator.bounds, CGRect(origin: .zero, size: initialFrame.size))

        // Bounds Size
        XCTAssertEqual(view.bounds.size, initialFrame.size)
        XCTAssertEqual(view.animator.bounds.size, initialFrame.size)

        // Frame Origin
        XCTAssertEqual(view.frame.origin, initialFrame.origin)
        XCTAssertEqual(view.animator.frame.origin, initialFrame.origin)

        // Frame Center
        XCTAssertEqual(view.center, initialFrame.center)
        XCTAssertEqual(view.animator.center, initialFrame.center)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.frame, view.animator.frame)
            XCTAssertEqual(view.bounds, view.animator.bounds)
        }
    }

    func testBackgroundColor() {
        let view = UIView()

        let initialValue = UIColor.red
        let targetValue = UIColor.blue

        view.backgroundColor = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.backgroundColor = targetValue
        }

        XCTAssertEqual(view.backgroundColor?.rgbaComponents, initialValue.rgbaComponents)
        XCTAssertEqual(view.animator.backgroundColor.rgbaComponents, targetValue.rgbaComponents)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.backgroundColor?.rgbaComponents, targetValue.rgbaComponents)
            XCTAssertEqual(view.animator.backgroundColor.rgbaComponents, targetValue.rgbaComponents)
        }
    }

    func testBackgroundColorClear() {
        let view = UIView()

        let initialValue = UIColor.clear
        let targetValue = UIColor.blue.withAlphaComponent(0.5)

        view.backgroundColor = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.backgroundColor = targetValue
        }

        XCTAssertEqual(view.backgroundColor?.rgbaComponents, initialValue.rgbaComponents)
        XCTAssertEqual(view.animator.backgroundColor.rgbaComponents, targetValue.rgbaComponents)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.backgroundColor?.rgbaComponents, targetValue.rgbaComponents)
            XCTAssertEqual(view.animator.backgroundColor.rgbaComponents, targetValue.rgbaComponents)
        }
    }

    func testAlpha() {
        let view = UIView()

        let initialValue = 1.0
        let targetValue = 0.5

        view.alpha = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.alpha = targetValue
        }

        XCTAssertEqual(view.alpha, initialValue)
        XCTAssertEqual(view.animator.alpha, targetValue)
        XCTAssertEqual(Double(view.layer.animator.opacity), targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.alpha, targetValue)
            XCTAssertEqual(view.animator.alpha, targetValue)
        }
    }

    func testNonAnimatedAlpha() {
        let view = UIView()

        let initialValue = 1.0
        let targetValue = 0.5

        view.alpha = initialValue

        Wave.animate(withSpring: .defaultNonAnimated) {
            view.animator.alpha = targetValue
        }

        XCTAssertEqual(view.alpha, targetValue)
        XCTAssertEqual(view.animator.alpha, targetValue)

        XCTAssertEqual(Double(view.layer.opacity), targetValue)
        XCTAssertEqual(view.layer.animator.opacity, targetValue)

        Wave.animate(withSpring: .defaultAnimated, mode: .nonAnimated) {
            view.animator.alpha = initialValue
        }

        XCTAssertEqual(view.alpha, initialValue)
        XCTAssertEqual(view.animator.alpha, initialValue)

        XCTAssertEqual(Double(view.layer.opacity), initialValue)
        XCTAssertEqual(view.layer.animator.opacity, initialValue)
    }

    func testPropertyAnimation() {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1
        animator.start()

        animator.valueChanged = { value in
            if value > 0.5 {
                animator.stop(immediately: true)
            }
        }

        wait(for: .defaultAnimated) {
            guard let value = animator.value else {
                return
            }

            XCTAssertEqual(animator.state, .inactive)
            XCTAssert(value > 0.5 && value < 0.55)
            XCTAssertEqual(animator.target, 1)
            XCTAssertEqual(animator.velocity, .zero)
        }
    }

}

#endif
