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
    public var backgroundColor: NSUIColor? {
        get { self[\.backgroundColor]?.nsUIColor }
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
    public var borderColor: NSUIColor? {
        get { self[\.borderColor]?.nsUIColor }
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
    public var shadowColor: NSUIColor? {
        get { self[\.shadowColor]?.nsUIColor }
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
    
    /// The property animators for the layer's sublayers.
    public var sublayers: [PropertyAnimator<CALayer>] {
        object.sublayers?.compactMap({$0.animator}) ?? []
    }
    
    /// The property animator for the layer's superlayer.
    public var superlayer: PropertyAnimator<CALayer>? {
        object.superlayer?.animator
    }
    
    /// The property animator for the layer's mask.
    public var mask: PropertyAnimator<CALayer>? {
        object.mask?.animator
    }
    
    /**
     Adds the specified layer animated. The sublayers's opacity gets animated to `1.0`.
     
     - Note: The animation only occurs if the layer's sublayers doesn't contain the specified sublayer.
     */
    public func addSublayer(_ layer: CALayer) {
        guard layer.superlayer != object else { return }
        layer.opacity = 0.0
        Wave.nonAnimate {
            layer.animator.opacity = 0.0
        }
        object.addSublayer(layer)
        layer.animator.opacity = 1.0
    }
    
    /**
     Inserts the layer at the specified index animated. The sublayers's opacity gets animated to `1.0`.
     
     - Note: The animation only occurs if the layer's sublayers doesn't contain the specified sublayer.
     */
    public func insertSublayer(_ layer: CALayer, at index: UInt32) {
        guard layer.superlayer != object else { return }
        layer.opacity = 0.0
        Wave.nonAnimate {
            layer.animator.opacity = 0.0
        }
        object.insertSublayer(layer, at: index)
        layer.animator.opacity = 1.0
    }
    
    /**
     Inserts the layer above a different sublayer animated. The sublayers's opacity gets animated to `1.0`.
     
     - Note: The animation only occurs if the layer's sublayers doesn't contain the specified sublayer.
     */
    public func insertSublayer(_ layer: CALayer, above sibling: CALayer) {
        guard layer.superlayer != object, object.sublayers?.contains(sibling) == true else { return }
        layer.opacity = 0.0
        Wave.nonAnimate {
            layer.animator.opacity = 0.0
        }
        object.insertSublayer(layer, above: sibling)
        layer.animator.opacity = 1.0
    }
    
    /**
     Inserts the layer below a different sublayer animated. The sublayers's opacity gets animated to `1.0`.
     
     - Note: The animation only occurs if the layer's sublayers doesn't contain the specified sublayer.
     */
    public func insertSublayer(_ layer: CALayer, below sibling: CALayer) {
        guard layer.superlayer != object, object.sublayers?.contains(sibling) == true else { return }
        layer.opacity = 0.0
        Wave.nonAnimate {
            layer.animator.opacity = 0.0
        }
        object.insertSublayer(layer, below: sibling)
        layer.animator.opacity = 1.0
    }
}

extension PropertyAnimator where Object: CATextLayer {
    /// The font size of the layer.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the layer.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

fileprivate extension CATextLayer {
    @objc var textColor: NSUIColor? {
        get { self.foregroundColor?.nsUIColor }
        set { self.foregroundColor = newValue?.cgColor }
    }
}

extension PropertyAnimator where Object: CAShapeLayer {
    /// The color used to fill the shape’s path.
    public var fillColor: NSUIColor? {
        get { self[\.fillColor]?.nsUIColor }
        set { self[\.fillColor] = newValue?.cgColor }
    }
        
    /// The dash pattern applied to the shape’s path when stroked.
    public var lineDashPattern: [Double] {
        get { self[\._lineDashPattern] }
        set { self[\._lineDashPattern] = newValue }
    }
    
    /// The dash phase applied to the shape’s path when stroked.
    public var lineDashPhase: CGFloat {
        get { self[\.lineDashPhase] }
        set { self[\.lineDashPhase] = newValue }
    }
    
    /// Specifies the line width of the shape’s path.
    public var lineWidth: CGFloat {
        get { self[\.lineWidth] }
        set { self[\.lineWidth] = newValue }
    }
    
    /// The miter limit used when stroking the shape’s path.
    public var miterLimit: CGFloat {
        get { self[\.miterLimit] }
        set { self[\.miterLimit] = newValue }
    }
        
    /// The color used to stroke the shape’s path.
    public var strokeColor: NSUIColor? {
        get { self[\.strokeColor]?.nsUIColor }
        set { self[\.strokeColor] = newValue?.cgColor }
    }
    
    /// The relative location at which to begin stroking the path.
    public var strokeStart: CGFloat {
        get { self[\.strokeStart] }
        set { self[\.strokeStart] = newValue }
    }
    
    /// The relative location at which to stop stroking the path.
    public var strokeEnd: CGFloat {
        get { self[\.strokeEnd] }
        set { self[\.strokeEnd] = newValue }
    }
}

extension PropertyAnimator where Object: CAReplicatorLayer {
    /// Specifies the delay, in seconds, between replicated copies.
    public var instanceDelay: CGFloat {
        get { self[\.instanceDelay] }
        set { self[\.instanceDelay] = newValue }
    }
    
    /// The transform matrix applied to the previous instance to produce the current instance.
    public var instanceTransform: CATransform3D {
        get { self[\.instanceTransform] }
        set { self[\.instanceTransform] = newValue }
    }
    
    /// Defines the color used to multiply the source object.
    public var instanceColor: NSUIColor? {
        get { self[\.instanceColor]?.nsUIColor }
        set { self[\.instanceColor] = newValue?.cgColor }
    }
    
    /// Defines the offset added to the red component of the color for each replicated instance. Animatable.
    public var instanceRedOffset: CGFloat {
        get { CGFloat(self[\.instanceRedOffset]) }
        set { self[\.instanceRedOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the green component of the color for each replicated instance. Animatable.
    public var instanceGreenOffset: CGFloat {
        get { CGFloat(self[\.instanceGreenOffset]) }
        set { self[\.instanceGreenOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the blue component of the color for each replicated instance. Animatable.
    public var instanceBlueOffset: CGFloat {
        get { CGFloat(self[\.instanceBlueOffset]) }
        set { self[\.instanceBlueOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the alpha component of the color for each replicated instance. Animatable.
    public var instanceAlphaOffset: CGFloat {
        get { CGFloat(self[\.instanceAlphaOffset]) }
        set { self[\.instanceAlphaOffset] = Float(newValue) }
    }
}

extension PropertyAnimator where Object: CATiledLayer {
    /// The maximum size of each tile used to create the layer's content.
    public var tileSize: CGSize {
        get { self[\.tileSize] }
        set { self[\.tileSize] = newValue }
    }
}

extension PropertyAnimator where Object: CAGradientLayer {
    /// The fill color of the layer.
    public var colors: [NSUIColor] {
        get { colors(for: self[\._colors]) }
        set { self[\._colors] = animatableVector(for: newValue) }
    }
    
    /// The locations of each gradient stop.
    public var locations: [Double] {
        get { self[\._locations] }
        set { self[\._locations] = newValue }
    }
    
    /// The start point of the gradient when drawn in the layer’s coordinate space.
    public var startPoint: CGPoint {
        get { self[\.startPoint] }
        set { self[\.startPoint] = newValue }
    }
    
    /// The end point of the gradient when drawn in the layer’s coordinate space.
    public var endPoint: CGPoint {
        get { self[\.endPoint] }
        set { self[\.endPoint] = newValue }
    }
    
    internal func colors(for values: AnimatableVector) -> [NSUIColor] {
        values.chunked(size: 4).compactMap({ NSUIColor(red: $0[0], green: $0[0], blue: $0[0], alpha: $0[0]) })
    }
    
    internal func animatableVector(for colors: [NSUIColor]) -> AnimatableVector {
        colors.compactMap({$0.rgbaComponents}).flatMap({ [$0.r, $0.g, $0.b, $0.a] })
    }
}

extension PropertyAnimator where Object: CAEmitterLayer {
    /// The position of the center of the particle emitter.
    public var emitterPosition: CGPoint {
        get { self[\.emitterPosition] }
        set { self[\.emitterPosition] = newValue }
    }
    
    /// Specifies the center of the particle emitter shape along the z-axis.
    public var emitterZPosition: CGFloat {
        get { self[\.emitterZPosition] }
        set { self[\.emitterZPosition] = newValue }
    }
    
    /// Determines the depth of the emitter shape.
    public var emitterDepth: CGFloat {
        get { self[\.emitterDepth] }
        set { self[\.emitterDepth] = newValue }
    }
    
    /// Determines the size of the particle emitter shape.
    public var emitterSize: CGSize {
        get { self[\.emitterSize] }
        set { self[\.emitterSize] = newValue }
    }
    
    /// Defines a multiplier applied to the cell-defined particle spin.
    public var spin: CGFloat {
        get { CGFloat(self[\.spin]) }
        set { self[\.spin] = Float(newValue) }
    }
    
    /// Defines a multiplier applied to the cell-defined particle velocity.
    public var velocity: CGFloat {
        get { CGFloat(self[\.velocity]) }
        set { self[\.velocity] = Float(newValue) }
    }
    
    /// Defines a multiplier that is applied to the cell-defined birth rate.
    public var birthRate: CGFloat {
        get { CGFloat(self[\.birthRate]) }
        set { self[\.birthRate] = Float(newValue) }
    }
    
    /// Defines a multiplier applied to the cell-defined lifetime range when particles are created.
    public var lifetime: CGFloat {
        get { CGFloat(self[\.lifetime]) }
        set { self[\.lifetime] = Float(newValue) }
    }
}

internal extension CAGradientLayer {
    var _locations: [Double] {
        get { locations?.compactMap({$0.doubleValue}) ?? [] }
        set { locations = newValue as [NSNumber] }
    }
}

internal extension CAShapeLayer {
    var _lineDashPattern: [Double] {
        get { lineDashPattern?.compactMap({$0.doubleValue}) ?? [] }
        set { lineDashPattern = newValue as [NSNumber] }
    }
}

internal extension CAGradientLayer {
    var _colors: [Double] {
        get { (self.colors as? [CGColor])?.flatMap({$0.animatableData}) ?? [] }
        set { self.colors = newValue.chunked(size: 4).compactMap({ CGColor($0) })
        }
    }
}
