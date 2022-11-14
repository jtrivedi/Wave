//
//  GridViewController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit

import Wave

class GridViewController: UIViewController {

    let dampingLabel = UILabel()
    let responseLabel = UILabel()
    let settlingTimeLabel = UILabel()

    let dampingSlider = UISlider()
    let responseSlider = UISlider()

    var sliderSpring: Spring {
        Spring(
            dampingRatio: Double(dampingSlider.value),
            response: Double(responseSlider.value)
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.backgroundColor = .white

        setupSliders()
        setupGrid()
        updateGridColors()

        dampingSlider.value = 0.70
        responseSlider.value = 0.80

        updateLabels()
    }

    // MARK: - Gesture handling

    @objc
    func handlePanWithBlock(sender: UIPanGestureRecognizer) {
        guard let draggedView = sender.view as? Box else {
            return
        }

        draggedView.superview?.bringSubviewToFront(draggedView)

        let touchLocation = sender.location(in: view)
        let touchVelocity = sender.velocity(in: view)

        switch sender.state {
        case .began, .changed:
            let scale = mapRange(touchLocation.y, 0, view.bounds.size.height, 0.2, 2.5)

            let interactiveSpring = Spring(dampingRatio: 1.0, response: 0.3)

            Wave.animate(withSpring: interactiveSpring) {
                draggedView.animator.center = touchLocation
                draggedView.animator.scale = CGPoint(x: scale, y: scale)
            }

        case .ended, .cancelled:
            Wave.animate(withSpring: sliderSpring, gestureVelocity: touchVelocity) {
                draggedView.animator.center = draggedView.originCenter
                draggedView.animator.scale = CGPoint(x: 1, y: 1)
            } completion: { finished, retargeted in
                print("[Ended] completion: finished: \(finished), retargeted: \(retargeted)")
            }

        default:
            break
        }
    }

    // MARK: - View setup

    func setupGrid() {
        let totalWidth = view.bounds.size.width

        let size = 80.0
        let columns = Int(totalWidth / size)
        let rows = columns + 1

        let boxWidth = (CGFloat(columns) * size)
        let xPadding = (totalWidth - boxWidth) / (CGFloat(columns + 1))

        for row in 0..<rows {
            for col in 0..<columns {
                let box = Box()
                view.addSubview(box)

                box.frame.origin = CGPoint(
                    x: xPadding + CGFloat(col) * size + CGFloat(col) * xPadding,
                    y: 60 + xPadding + CGFloat(row) * size + CGFloat(row) * xPadding
                ).scaledIntegral

                box.originCenter = box.center

                let panGestureRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(handlePanWithBlock(sender:)))
                box.addGestureRecognizer(panGestureRecognizer)
            }
        }
    }

    func setupSliders() {
        dampingSlider.minimumValue = 0
        dampingSlider.maximumValue = 1.2

        responseSlider.minimumValue = 0.05
        responseSlider.maximumValue = 3

        dampingSlider.addTarget(self, action: #selector(dampingChanged(sender:)), for: .valueChanged)
        responseSlider.addTarget(self, action: #selector(responseChanged(sender:)), for: .valueChanged)

        let sliderStack = UIStackView(arrangedSubviews: [settlingTimeLabel, dampingLabel, dampingSlider, responseLabel, responseSlider])
        sliderStack.setCustomSpacing(10, after: settlingTimeLabel)
        sliderStack.axis = .vertical
        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderStack)

        sliderStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        sliderStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        sliderStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }

    func updateGridColors() {
        let boxes = view.subviews.compactMap {
            $0 as? Box
        }

        boxes.forEach {
            let firstBox = boxes.first!
            let lastBox = boxes.last!

            let maxDistance = lastBox.center.distance(to: firstBox.center)
            let distanceFromCenter = $0.center.distance(to: firstBox.center)
            let progress = mapRange(distanceFromCenter, 0, maxDistance, 0, 1)
            $0.backgroundColor = UIColor.interpolate(from: .systemBlue, to: .systemPurple, with: progress)
        }
    }

    // MARK: - Slider handling

    @objc
    func dampingChanged(sender: UISlider) {
        updateLabels()
    }

    @objc
    func responseChanged(sender: UISlider) {
        updateLabels()
    }

    func updateLabels() {
        dampingLabel.text = String(format: "Damping Ratio: %.2f", dampingSlider.value)
        responseLabel.text = String(format: "Frequency Response: %.2f", responseSlider.value)
        settlingTimeLabel.text = String(format: "Settling time: %.2f", sliderSpring.settlingDuration)
    }

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "Grid"
        tabBarItem.image = UIImage(systemName: "square.grid.2x2")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class Box: UIView {
    var originCenter: CGPoint = .zero

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        backgroundColor = .systemBlue
        layer.cornerCurve = .continuous
        layer.cornerRadius = (bounds.size.height * 0.2237)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
