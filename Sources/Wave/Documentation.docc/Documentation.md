# Wave

Wave is a spring-based animation library for iOS. It makes it easy to create fluid, interactive animations that feel great.

The core feature of Wave is that all animations are _re-directable_, meaning that you can change the animation's target value in-flight, and it will gracefully start animating to the new target.

#### Example Usage

```swift
// `dampingRatio` determines how "bouncy" the animation will be,
//  while `response` determines its speed.
let bouncySpring = Spring(dampingRatio: 0.60, response: 0.80)

Wave.animateWith(spring: bouncySpring) {
    myView.animator.scale = CGPoint(x: 1.5, y: 1.5)
}
```

If you want the spring values directly, you can animate values yourself:

```swift
var scaleAnimation = Animation<CGFloat>(spring: bouncySpring)
scaleAnimation.value = 1.0
scaleAnimation.target = 1.5

scaleAnimation.valueChanged = { springValue in 
    myView.transform = CGAffineTransform(scaleX: springValue, y: springValue)
}

scaleAnimation.start()
```

#### Installation

Add Wave to your app's `Package.swift` file, or selecting `File -> Add Packages` in Xcode:

```swift
.package(url: "https://github.com/jtrivedi/Wave")
```

