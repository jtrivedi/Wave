//
//  Animator+LayoutConstraint.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSLayoutConstraint: AnimatablePropertyProvider { }

extension PropertyAnimator where Object: NSLayoutConstraint {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { self[\.constant] }
        set { self[\.constant] = newValue }
    }
}

public extension Collection where Element == NSLayoutConstraint {
    /// Use the `animator` property to animate changes to the layout constraints of the collection.
    var animator: LayoutConstraintsAnimator<Self> {
        LayoutConstraintsAnimator(self)
    }
}

/// An object for animating layout constraints in a collection.
public struct LayoutConstraintsAnimator<Object: Collection> where Object.Element == NSLayoutConstraint {
    internal var collection: Object
    internal init(_ collection: Object) {
        self.collection = collection
    }
    
    /// Updates the constant of the constraints and returns itself.
    public func constant(_ constant: CGFloat) {
        collection.forEach({ $0.animator.constant = constant })
    }
}
