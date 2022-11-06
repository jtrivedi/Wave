//
//  PictureInPictureViewController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

import Wave

class PictureInPictureViewController: UIViewController {

    let pipView = PictureInPictureView(frame: CGRect(x: 0, y: 0, width: 120, height: 80))

    /// A tighter spring used when dragging the PiP view around.
    let interactiveSpring = Spring(dampingRatio: 0.8, response: 0.26)

    /// A looser spring used to animate the PiP view to its final location after dragging ends.
    let animatedSpring = Spring(dampingRatio: 0.68, response: 0.8)

    /// In order to draw the path that the PiP view takes when animating to its final destination,
    /// we need the intermediate spring values. Use a separate `CGPoint` animator to get these values.
    lazy var positionAnimator = SpringAnimator<CGPoint>(spring: animatedSpring)

    /// The view that draws the path of the PiP view.
    lazy var pathView = PathView(frame: view.bounds)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        setupViews()
    }

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "PiP"
        tabBarItem.image = UIImage(systemName: "pip")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Gesture Handling

    private var initialTouchLocation: CGPoint = .zero

    @objc
    private func handlePan(sender: UIPanGestureRecognizer) {
        guard let pipView = sender.view as? PictureInPictureView else {
            return
        }

        let touchLocation = sender.location(in: view)
        let touchTranslation = sender.translation(in: view)
        let touchVelocity = sender.velocity(in: view)

        if sender.state == .began {
            // Mark the view's initial position.
            initialTouchLocation = pipView.center

            // Invalidate the position animator.
            positionAnimator.valueChanged = nil
            pathView.reset()
        }

        switch sender.state {
        case .began, .changed:

            let targetPiPViewCenter = CGPoint(
                x: initialTouchLocation.x + touchTranslation.x,
                y: initialTouchLocation.y + touchTranslation.y
            )

            // We want the dragged view to closely follow the user's touch (not exactly 1:1, but close).
            // So animating using the `interactiveSpring` that has a lower `response` value.
            // See `Spring.swift` for more information.

            Wave.animate(withSpring: interactiveSpring) {
                // Just update the view's `animator.center` – that's it!
                pipView.animator.center = targetPiPViewCenter
            }

        case .ended, .cancelled:
            // The gesture ended, so figure out where the PiP view should ultimately land.
            let pipViewDestination = targetCenter(currentPosition: touchLocation, velocity: touchVelocity)

            // The `animatedSpring` is looser and takes a longer time to settle, so use that to animate the final position.
            //
            // Finally "inject" the pan gesture's lift-off velocity into the animation.
            // That `gestureVelocity` parameter will affect the `center` animation.
            Wave.animate(withSpring: animatedSpring, gestureVelocity: touchVelocity) {
                pipView.animator.center = pipViewDestination
            }

            // This position animation runs the exact same spring animation as the above block (i.e. `pipView.animator.center = ...`)
            // We run this to get the intermediate spring values, such that we can draw the view's animation path.
            positionAnimator.spring = animatedSpring
            positionAnimator.value = pipView.center             // The current, presentation value of the view.
            positionAnimator.target = pipView.animator.center   // The target center that we just set above.
            positionAnimator.velocity = touchVelocity

            positionAnimator.valueChanged = { [weak self] location in
                self?.pathView.add(location)
            }

            positionAnimator.start()

        default:
            break
        }
    }
}

/**
 The below code isn't important or interesting. It's just configuring the view hierarchy, calculating the PiP view target positions, etc.
 */

class PictureInPictureView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        gradient.cornerRadius = 16
        gradient.cornerCurve = .continuous
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = .init(width: 0, height: 3)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DottedBorderView: UIView {
    public init(frame: CGRect, borderColor: UIColor, radius: CGFloat) {
        super.init(frame: frame)

        let borderLayer = CAShapeLayer()
        borderLayer.lineWidth = 1
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineDashPattern = [8, 8]
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath

        layer.addSublayer(borderLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PictureInPictureViewController {

    private func setupViews() {
        let pipViewSize = pipView.bounds.size
        let cornerPoints = [view.frame.topLeft, view.frame.topRight, view.frame.bottomLeft, view.frame.bottomRight]
        cornerPoints.forEach {
            let targetViewCenter = targetCenter(currentPosition: $0, velocity: .zero)
            let targetView = DottedBorderView(
                frame: CGRect(x: 0, y: 0, width: pipViewSize.width, height: pipViewSize.height),
                borderColor: .systemOrange,
                radius: 16
            )

            targetView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            targetView.center = targetViewCenter

            view.addSubview(targetView)
        }

        pipView.center = targetCenter(currentPosition: view.frame.topLeft, velocity: .zero)

        let panGestureRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        pipView.addGestureRecognizer(panGestureRecognizer)

        view.addSubview(pipView)
        view.addSubview(pathView)
    }

    private func targetCenter(currentPosition: CGPoint, velocity: CGPoint) -> CGPoint {
        let size = pipView.bounds.size

        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        var projectedPosition = project(point: currentPosition, velocity: velocity)

        projectedPosition.x = clip(value: projectedPosition.x, lower: 1, upper: screenWidth - 1)
        projectedPosition.y = clip(value: projectedPosition.y, lower: 1, upper: screenHeight - 1)

        let topLeft = CGRect(x: 0, y: 0, width: screenWidth / 2.0, height: screenHeight / 2.0)
        let topRight = CGRect(x: screenWidth / 2.0, y: 0, width: screenWidth / 2.0, height: screenHeight / 2.0)

        let bottomLeft = CGRect(x: 0, y: screenHeight / 2.0, width: screenWidth / 2.0, height: screenHeight / 2.0)
        let bottomRight = CGRect(x: screenWidth / 2.0, y: screenHeight / 2.0, width: screenWidth / 2.0, height: screenHeight / 2.0)

        var origin: CGPoint = .zero

        let marginX = 25.0
        let marginY = marginX

        let window = UIApplication.shared.delegate?.window
        let safeAreaTop = window??.safeAreaInsets.top ?? size.height
        let safeAreaBottom = window??.safeAreaInsets.bottom ?? size.height

        if topLeft.contains(projectedPosition) {
            origin = CGPoint(x: marginX, y: safeAreaTop + marginY)
        } else if topRight.contains(projectedPosition) {
            origin = CGPoint(x: (view.bounds.width - size.width - marginX), y: safeAreaTop + marginY)
        } else if bottomLeft.contains(projectedPosition) {
            origin = CGPoint(x: marginX, y: (view.bounds.height - size.height - safeAreaBottom - marginY))
        } else if bottomRight.contains(projectedPosition) {
            origin = CGPoint(x: (view.bounds.width - size.width - marginX), y: (view.bounds.height - size.height - safeAreaBottom - marginY))
        }

        let center = CGPoint(x: origin.x + size.width / 2.0, y: origin.y + size.height / 2.0)

        return center
    }
}
