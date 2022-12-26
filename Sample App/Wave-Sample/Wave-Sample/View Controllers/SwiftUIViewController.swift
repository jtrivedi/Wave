//
//  SwiftUIViewController.swift
//  Wave-Sample
//
//  Copyright (c) 2022 Janum Trivedi
//

import SwiftUI

import Wave

struct SwiftUIView: View {

    let offsetAnimator = SpringAnimator<CGPoint>(spring: Spring(dampingRatio: 0.72, response: 0.7))

    @State var boxOffset: CGPoint = .zero

    var body: some View {
        let size = 80.0
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(.blue)
                .frame(width: size, height: size)
            VStack {
                Text("SwiftUI")
                    .foregroundColor(.white)
            }

        }.onAppear {
            offsetAnimator.value = .zero

            // The offset animator's callback will update the `offset` state variable.
            offsetAnimator.valueChanged = { newValue in
                boxOffset = newValue
            }
        }
        .offset(x: boxOffset.x, y: boxOffset.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Update the animator's target to the new drag translation.
                    offsetAnimator.target = CGPoint(x: value.translation.width, y: value.translation.height)

                    // Don't animate the box's position when we're dragging it.
                    offsetAnimator.mode = .nonAnimated
                    offsetAnimator.start()
                }
                .onEnded { value in
                    // Animate the box to its original location (i.e. with zero translation).
                    offsetAnimator.target = .zero

                    // We want the box to animate to its original location, so use an `animated` mode.
                    // This is different than the
                    offsetAnimator.mode = .animated

                    // Take the velocity of the gesture, and give it to the animator.
                    // This makes the throw animation feel natural and continuous.
                    offsetAnimator.velocity = CGPoint(x: value.velocity.width, y: value.velocity.height)
                    offsetAnimator.start()
                }
        )
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}

class SwiftUIViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "SwiftUI"
        tabBarItem.image = UIImage(systemName: "swift")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let hostingController = UIHostingController(rootView: SwiftUIView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
    }
}
