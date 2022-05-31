//
//  SheetViewController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

import Wave

class SheetViewController: UIViewController {

    let sheetView = SheetView()

    let interactiveSpring = Spring(dampingRatio: 0.8, response: 0.2)
    let animatedSpring = Spring(dampingRatio: 0.68, response: 0.8)

    lazy var sheetPresentationAnimator = Animation<CGFloat>(spring: animatedSpring)

    var sheetPresentationProgress: CGFloat = 0 {
        didSet {
            self.layoutSheet(withPresentationProgress: sheetPresentationProgress)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.addSubview(sheetView)
        sheetView.addGestureRecognizer(InstantPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))

        // `0` progress represents the docked/minimized state of the sheet.
        // `1.0` represents the fully-presented state.
        self.sheetPresentationProgress = 0
        sheetPresentationAnimator.value = self.sheetPresentationProgress

        sheetPresentationAnimator.valueChanged = { [weak self] newProgress in
            self?.sheetPresentationProgress = newProgress
        }
    }

    func layoutSheet(withPresentationProgress progress: CGFloat) {
        let sheetHeight = mapRange(progress, 0, 1, fullyCollapsedHeight, fullyPresentedHeight)

        let collapsedMargin = 80.0
        let presentedMargin = 40.0

        let sheetOriginX = mapRange(progress, 0, 1, collapsedMargin / 2.0, presentedMargin / 2.0)
        let sheetWidth = mapRange(progress, 0, 1, view.bounds.width - collapsedMargin, view.bounds.size.width - presentedMargin)

        sheetView.frame = CGRect(
            x: sheetOriginX,
            y: view.bounds.height - sheetHeight,
            width: sheetWidth,
            height: sheetHeight
        )
    }

    // MARK: - Gesture Handling

    var initialGestureAnimationProgress: CGFloat = 0

    var fullyCollapsedHeight: CGFloat {
        200
    }

    var fullyPresentedHeight: CGFloat {
        view.bounds.height * 0.9
    }

    func progressForTranslation(_ translation: CGFloat) -> CGFloat {
        (-translation / (fullyPresentedHeight - fullyCollapsedHeight)) + initialGestureAnimationProgress
    }

    @objc
    private func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        if sender.state == .began {
            initialGestureAnimationProgress = sheetPresentationProgress
        }

        if sender.state == .began || sender.state == .changed {
            sheetPresentationAnimator.spring = .defaultNonAnimated

            let targetProgress = progressForTranslation(translation.y)
            sheetPresentationAnimator.target = targetProgress

        } else if sender.state == .ended || sender.state == .cancelled {
            let normalizedVelocity = -velocity.y / (fullyPresentedHeight - fullyCollapsedHeight)
            let projectedTranslation = project(value: translation.y, velocity: velocity.y)
            let projectedProgress = progressForTranslation(projectedTranslation)
            let targetProgress = (projectedProgress > 0.5) ? 1.0 : 0.0

            sheetPresentationAnimator.spring = Spring(dampingRatio: 0.8, response: 0.7)
            sheetPresentationAnimator.target = targetProgress
            sheetPresentationAnimator.velocity = normalizedVelocity
        }

        sheetPresentationAnimator.start()
    }

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "Sheet"
        tabBarItem.image = UIImage(systemName: "square.stack")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SheetView: UIView {

    init() {
        super.init(frame: .zero)

        layer.cornerCurve = .continuous
        layer.cornerRadius = 38

        backgroundColor = .systemGray5

        var yOffset: CGFloat = 50.0
        for row in 0...14 {
            let width = CGFloat(Int.random(in: 40...200))
            let rect = UIView(frame: CGRect(x: 30.0, y: yOffset, width: width, height: 32))
            rect.backgroundColor = UIColor.systemGray2

            let colors: [UIColor] = [.systemRed, .systemYellow, .systemOrange, .systemPink, .systemPurple]
            rect.backgroundColor = colors.randomElement()
            rect.alpha = 0.5

            rect.layer.cornerRadius = 8
            rect.layer.cornerCurve = .continuous

            let sectionBreak = (row + 1) % 3 == 0 ? 40.0 : 0.0

            addSubview(rect)
            yOffset += (rect.bounds.size.height * 1.5 + sectionBreak)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
