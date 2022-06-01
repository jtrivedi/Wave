<p align="center">
    <img width="300" src="./Assets/Logo.png">
</p>

## Wave

Wave is a spring-based animation engine for iOS and iPadOS. It makes it easy to create fluid, interactive, and interruptible animations that feel great.

Wave has no external dependencies, and can be easily dropped into existing UIKit-based projects and apps.

The core feature of Wave is that all animations are _re-targetable_, meaning that you can change an animation’s destination value in-flight, and the animation will gracefully _redirect_ to that new value.

- [Understanding Retargeting](#features)
- [Installation](#installation)
- [Documentation](#documentation)
- [Getting Started](#getting-started)
    - [Block-Based Animation](#block-based-animation)
    - [Property-Based Animation](#property-based-animation)
- [Example Code](#example-code)

#### Understanding Retargeting

Consider these demos of the iOS Picture-in-Picture feature. The screen on the left is created with standard UIKit animations, and the one on the right is created with Wave.

Though both are “interruptible”, the Wave-based implementation handles the interruption much better, and fluidly _arcs_ to its new destination. The UIKit animation feels stiff and jerky in comparison.

At its core, [retargeting](https://developer.apple.com/videos/play/wwdc2018/803/) is the process of preserving an animation’s velocity even as its target changes, which Wave does automatically.

![Demo](./Assets/Retargeting.gif)


### Installation

Add Wave to your app's `Package.swift` file, or selecting `File -> Add Packages` in Xcode:

```swift
.package(url: "https://github.com/jtrivedi/Wave")
```

If you clone the repo, you can run the sample app, which contains a few interactive demos to understand what Wave provides.

### Documentation

There’s a full Wave [documentation site](https://Wave-jtrivedi.structure.sh) available for full API and usage documentation.

### Getting Started



There are two ways you can interact with Wave, depending on your needs: the block-based and property-based animations:

#### Block-Based Animation

The easiest way to get started is by using Wave’s block-based APIs that resemble the `UIView.animateWithDuration()` APIs.

This API lets you animate several common UIView and CALayer properties, like `frame`, `center`, `scale`, `backgroundColor`, and more.

For these supported properties, Wave will create, manage, and execute the required spring animations under-the-hood.

For example, animating the above PiP view to its final destination is extremely simple:

```swift
if panGestureRecognizer.state == .ended {

    // Create a spring with some bounciness. `response` affects the animation's duration.
    let animatedSpring = Spring(dampingRatio: 0.68, response: 0.80)

    // Get the gesture's lift-off velocity
    let gestureVelocity = panGestureRecognizer.velocity(in: view)

    Wave.animate(withSpring: animatedSpring, gestureVelocity: touchVelocity) {
        // Update the `center` and `scale` properties of the view's _animator_, not the view itself.
        pipView.animator.center = pipViewDestination
        pipView.animator.scale = CGPoint(x: 1.1, y: 1.1)
    }
}
```

Note that at _any_ time, you can _retarget_ the view’s `center` property to somewhere else, and it’ll gracefully animate.

##### Supported Animatable Properties

The block-based API currently supports animating the following properties. For other properties, you can use the property-based animation API below.

* `frame`
* `bounds`
* `center`
* `origin`
* `alpha`
* `backgroundColor`
* `cornerRadius`
* `scale`
* `translation`

Upcoming properties:

* `rotation`
* `shadow color/radius/offset/opacity`

#### Property-Based Animation

While the block-based API is often most convenient, you may want to animate something that the block-based API doesn’t yet support (e.x. rotation). Or, you may want the flexibility of getting the intermediate spring values and driving an animation yourself (e.x. a progress value).

For example, to draw the orange path of the PiP demo, we need to know the value of every `CGPoint` from the view’s initial center, to its destination center:

```swift
// When the gesture ends, create a `CGPoint` animation from the PiP view's initial center, to its target.
// The `valueChanged` callback provides the intermediate locations of the callback, allowing us to draw the path.

let positionAnimator = Animation<CGPoint>(spring: animatedSpring)
positionAnimator.value = pipView.center           // The presentation value
positionAnimator.target = pipView.animator.center // The target value
positionAnimator.velocity = touchVelocity

positionAnimator.valueChanged = { [weak self] location in
    self?.drawPathPoint(at: location)
}

positionAnimator.start()
```



##### Completion Blocks

Both the block-based and property-based APIs support completion blocks. If an animation completes fully, the completion block’s `finished` flag will be true.

However, if an animation’s target was changed in-flight (“retargeted”), `finished` will be false, while `retargeted` will be true.

```swift
Wave.animate(withSpring: Spring.defaultAnimated) {
    myView.animator.backgroundColor = .systemBlue
} completion: { finished, retargeted in
    print(finished, retargeted)
}
```

### Example Code

Exploring the provided sample app is a great way to get started with Wave.

Simply open the `Wave-Sample` Xcode project and hit “Run”. The full source code for the Picture-in-Picture demo is available there, too!

### Acknowledgements

Special thanks to [Ben Oztalay](https://github.com/boztalay) for helping architect the underlying physics of Wave!
