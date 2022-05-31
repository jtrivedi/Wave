//
//  WaveTests.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
@testable import Wave

final class WaveTests: XCTestCase {

    func testFrameTargetValue() {
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

    func testBoundsSizeTargetValue() {
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

    func testCenterTargetValue() {
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

    func testFrameTargetValuesWithoutAnimation() {
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

    func testCornerRadiusTargetValue() {
        let view = UIView()

        let initialValue = 10.0
        let targetValue = 20.0
        view.layer.cornerRadius = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.cornerRadius = targetValue
        }

        XCTAssertEqual(view.layer.cornerRadius, initialValue)
        XCTAssertEqual(view.animator.cornerRadius, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.layer.cornerRadius, targetValue)
            XCTAssertEqual(view.animator.cornerRadius, targetValue)
        }
    }

    func testAlphaTargetValue() {
        let view = UIView()

        let initialValue = 1.0
        let targetValue = 0.5

        view.alpha = initialValue

        Wave.animate(withSpring: .defaultAnimated) {
            view.animator.alpha = targetValue
        }

        XCTAssertEqual(view.alpha, initialValue)
        XCTAssertEqual(view.animator.alpha, targetValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(view.alpha, targetValue)
            XCTAssertEqual(view.animator.alpha, targetValue)
        }
    }

    func testScaleTargetValue() {
        let view = UIView()

        let initialValue = CGPoint(x: 1.0, y: 1.0)
        let targetValue = CGPoint(x: 0.5, y: 0.75)

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

    func testPropertyAnimation() {
        let animation = Animation<CGFloat>(spring: .defaultAnimated)
        animation.value = 0
        animation.target = 1
        animation.start()

        animation.valueChanged = { value in
            print(value)

            if value > 0.5 {
                animation.stop(immediately: true)
            }
        }

        wait(for: .defaultAnimated) {
            guard let value = animation.value else {
                return
            }

            XCTAssertEqual(animation.state, .inactive)
            XCTAssert(value > 0.5 && value < 0.55)
            XCTAssertEqual(animation.target, 1)
            XCTAssertEqual(animation.velocity, .zero)
        }
    }

    func wait(for spring: Spring, block: (() -> Void)) {
        let exp = expectation(description: "Waiting for spring to settle")
        let result = XCTWaiter.wait(for: [exp], timeout: spring.settlingDuration * 1.5)
        if result == XCTWaiter.Result.timedOut {
            block()
        } else {
            XCTFail("Delay interrupted")
        }
    }

}
