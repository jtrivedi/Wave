//
//  View+Extension.swift
//
//
//  Created by Florian Zand on 26.10.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIView {
    internal var optionalLayer: CALayer? {
        self.layer
    }
    
    /**
     The corner radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public var cornerRadius: CGFloat {
        get { optionalLayer?.cornerRadius ?? 0.0 }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.cornerRadius = newValue
        }
    }
    
    /**
     The border width of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc public dynamic var borderWidth: CGFloat {
        get { optionalLayer?.borderWidth ?? 0.0 }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.borderWidth = newValue
        }
    }

    /**
     The border color of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public dynamic var borderColor: NSUIColor? {
        get { optionalLayer?.borderColor?.nsUIColor }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.borderColor = newValue?.cgColor
        }
    }
    
    /**
     The shadow color of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public dynamic var shadowColor: NSUIColor? {
        get { optionalLayer?.shadowColor?.nsUIColor }
        set { optionalLayer?.shadowColor = newValue?.cgColor }
    }
    
    /**
     The shadow offset of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc public dynamic var shadowOffset: CGSize {
        get { optionalLayer?.shadowOffset ?? .zero }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.shadowOffset = newValue
        }
    }
    
    /**
     The shadow radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc public dynamic var shadowRadius: CGFloat {
        get { optionalLayer?.shadowRadius ?? .zero }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.shadowRadius = newValue
        }
    }
    
    /**
     The shadow opacity of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc public dynamic var shadowOpacity: CGFloat {
        get { CGFloat(optionalLayer?.shadowOpacity ?? .zero) }
        set {
            #if os(macOS)
            wantsLayer = true
            #endif
            optionalLayer?.shadowOpacity = Float(newValue)
        }
    }
    
    #if os(macOS)
    /**
     Specifies the transform applied to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.) The default value of this property is CGAffineTransformIdentity.
     Transformations occur relative to the view's anchor point. By default, the anchor point is equal to the center point of the frame rectangle. To change the anchor point, modify the anchorPoint property of the view's underlying CALayer object.
     Changes to this property can be animated.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform: CGAffineTransform {
        get { wantsLayer = true
            return layer?.affineTransform() ?? CGAffineTransformIdentity
        }
        set {
            wantsLayer = true
            layer?.setAffineTransform(newValue)
        }
    }
        
    /**
     The three-dimensional transform to apply to the view.

     The default value of this property is CATransform3DIdentity.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform3D: CATransform3D {
        get { wantsLayer = true
            return layer?.transform ?? CATransform3DIdentity
        }
        set {
            wantsLayer = true
            layer?.transform = newValue
        }
    }
    #endif
}
