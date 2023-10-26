//
//  PropertyAnimator+Layer.swift
//  
//
//  Created by Florian Zand on 26.10.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Decomposed

extension CALayer: AnimatablePropertyProvider { }

public typealias LayerAnimator = PropertyAnimator<CALayer>

extension PropertyAnimator where Object: CALayer {
    /// The bounds of the layer.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }
    
    /// The frame of the layer.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }
    
    /// The background color of the layer.
    public var backgroundColor: WaveColor? {
        get { self[\.backgroundColor]?.waveColor }
        set { self[\.backgroundColor] = newValue?.cgColor }
    }
    
    /// The size of the layer. Changing this value keeps the layer centered.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The origin of the layer.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the layer.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The opacity value of the layer.
    public var opacity: CGFloat {
        get { CGFloat(self[\.opacity]) }
        set { self[\.opacity] = Float(newValue) }
    }
    
    /// The three-dimensional transform of the layer.
    public var transform: CATransform3D {
        get { self[\.transform] }
        set { self[\.transform] = newValue }
    }
    
    /// The scale of the layer.
    public var scale: CGPoint {
        get { CGPoint(x: self.transform.scale.x, y: self.transform.scale.y) }
        set { self.transform.scale = Scale(newValue.x, newValue.y, transform.scale.z) }
    }
    
    /// The rotation of the layer.
    public var rotation: CGQuaternion {
        get { self[\.rotation] }
        set { self[\.rotation] = newValue }
    }
    
    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(x: self.transform.translation.x, y: self.transform.translation.y) }
        set { self.transform.translation = Translation(newValue.x, newValue.y, self.transform.translation.z) }
    }
    
    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { self[\.cornerRadius] }
        set { self[\.cornerRadius] = newValue }
    }
    
    /// The border color of the layer.
    public var borderColor: WaveColor? {
        get { self[\.borderColor]?.waveColor }
        set { self[\.borderColor] = newValue?.cgColor }
    }
    
    /// The border width of the layer.
    public var borderWidth: CGFloat {
        get { self[\.borderWidth] }
        set { self[\.borderWidth] = newValue }
    }

    /// The shadow opacity of the layer.
    public var shadowOpacity: CGFloat {
        get { CGFloat(self[\.shadowOpacity]) }
        set { self[\.shadowOpacity] = Float(newValue) }
    }
    
    /// The shadow color of the layer.
    public var shadowColor: WaveColor? {
        get { self[\.shadowColor]?.waveColor }
        set { self[\.shadowColor] = newValue?.cgColor }
    }
    
    /// The shadow offset of the layer.
    public var shadowOffset: CGSize {
        get { self[\.shadowOffset] }
        set { self[\.shadowOffset] = newValue }
    }
    
    /// The shadow radius of the layer.
    public var shadowRadius: CGFloat {
        get { self[\.shadowRadius] }
        set { self[\.shadowRadius] = newValue }
    }
}

extension PropertyAnimator where Object: CATextLayer {
    /// The font size of the layer.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the layer.
    public var textColor: WaveColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

fileprivate extension CATextLayer {
    @objc var textColor: WaveColor? {
        get { self.foregroundColor?.waveColor }
        set { self.foregroundColor = newValue?.cgColor }
    }
}
