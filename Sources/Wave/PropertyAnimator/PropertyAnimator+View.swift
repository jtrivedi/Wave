//
//  PropertyAnimator+View.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Decomposed

extension NSUIView: AnimatablePropertyProvider { }

public typealias ViewAnimator = PropertyAnimator<NSUIView>

extension PropertyAnimator where Object: NSUIView {
    /// The bounds of the view.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }
    
    /// The size of the view. Changing this value keeps the view centered.
    public var size: CGSize {
        get { frame.size }
        set { frame.sizeCentered = newValue }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get { object.optionalLayer?.animator.backgroundColor }
        set {
            object.optionalLayer?.animator.backgroundColor = newValue
        }
    }
    
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { object.optionalLayer?.animator.opacity ?? 1.0 }
        set { object.optionalLayer?.animator.opacity = newValue }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { object.optionalLayer?.animator.cornerRadius ?? 0.0 }
        set { object.optionalLayer?.animator.cornerRadius = newValue }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { object.optionalLayer?.animator.borderColor ?? .zero }
        set { object.optionalLayer?.animator.borderColor = newValue
        }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { object.optionalLayer?.animator.borderWidth ?? 0.0 }
        set { object.optionalLayer?.animator.borderWidth = newValue }
    }
    
    /// The shadow opacity of the view.
    public var shadowOpacity: CGFloat {
        get { object.optionalLayer?.animator.shadowOpacity ?? 0.0 }
        set { object.optionalLayer?.animator.shadowOpacity = newValue }
    }
    
    /// The shadow color of the view.
    public var shadowColor: NSUIColor? {
        get { object.optionalLayer?.animator.shadowColor }
        set { object.optionalLayer?.animator.shadowColor = newValue }
    }
    
    /// The shadow offset of the view.
    public var shadowOffset: CGSize {
        get { object.optionalLayer?.animator.shadowOffset ?? .zero }
        set { object.optionalLayer?.animator.shadowOffset = newValue }
    }
    
    /// The shadow radius of the layer.
    public var shadowRadius: CGFloat {
        get { object.optionalLayer?.animator.shadowRadius ?? 0.0 }
        set { object.optionalLayer?.animator.shadowRadius = newValue }
    }
    
    /// The three-dimensional transform of the view.
    public var transform3D: CATransform3D {
        get { object.optionalLayer?.transform ?? CATransform3DIdentity }
        set { object.optionalLayer?.transform = newValue }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { object.optionalLayer?.animator.scale ?? CGPoint(x: 1, y: 1) }
        set { object.optionalLayer?.animator.scale = newValue  }
    }
    
    /// The rotation transform of the view.
    public var rotation: CGQuaternion {
        get { object.optionalLayer?.animator.rotation ?? .zero }
        set { object.optionalLayer?.animator.rotation = newValue }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { object.optionalLayer?.animator.translation ?? .zero }
        set { object.optionalLayer?.animator.translation = newValue }
    }
}


extension PropertyAnimator where Object: NSUITextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

fileprivate extension NSUITextField {
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
}

extension PropertyAnimator where Object: NSUIScrollView {
    /// The point at which the origin of the content view is offset from the origin of the scroll view.
    public var contentOffset: CGPoint {
        get { self[\.contentOffset] }
        set { self[\.contentOffset] = newValue }
    }
    
    #if os(macOS)
    /// The amount by which the content is currently scaled.
    public var magnification: CGFloat {
        get {  self[\.magnification] }
        set { self[\.magnification] = newValue }
    }
    #elseif canImport(UIKit)
    /// The scale factor applied to the scroll view’s content.
    public var zoomScale: CGFloat {
        get {  self[\.zoomScale] }
        set { self[\.zoomScale] = newValue }
    }
    #endif
}


#if os(macOS)
extension PropertyAnimator where Object: NSImageView {
    /// The tint color of the image.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}

extension PropertyAnimator where Object: NSButton {
    /// The tint color of the button.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}


extension PropertyAnimator where Object: NSControl {
    /// The double value of the control.
    public var doubleValue: Double {
        get { self[\.doubleValue] }
        set { self[\.doubleValue] = newValue }
    }
    
    /// The float value of the control.
    public var floatValue: Float {
        get { self[\.floatValue] }
        set { self[\.floatValue] = newValue }
    }
}
#elseif canImport(UIKit)
extension PropertyAnimator where Object: UIImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension PropertyAnimator where Object: UIButton {
    /// The tint color of the button.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension PropertyAnimator where Object: UILabel {
    /// The text color of the label.
    public var textColor: NSUIColor {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the label.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension PropertyAnimator where Object: UITextView {
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

fileprivate extension UILabel {
    @objc var fontSize: CGFloat {
        get { font.pointSize }
        set { font = font?.withSize(newValue) }
    }
}

fileprivate extension UITextView {
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
}
#endif

