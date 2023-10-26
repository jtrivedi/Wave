//
//  AssociatedValue.swift
//
//  Parts taken from:
//  github.com/bradhilton/AssociatedValues
//  Created by Skyvive
//  Created by Florian Zand on 23.02.23.
//

import Foundation
import ObjectiveC.runtime

private extension String {
    var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}

/**
 Returns the associated value for the specified object and key.
 
 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
 - Returns: The associated value for the object and key, or nil if the value couldn't be found for the key..
 */
internal func getAssociatedValue<T>(key: String, object: AnyObject) -> T? {
    return (objc_getAssociatedObject(object, key.address) as? _AssociatedValue)?.value as? T
}

/**
 Returns the associated value for the specified object, key and inital value.
 
 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
internal func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.
 
 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
internal func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

private func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

/**
 Sets a associated value for the specified object and key.
 
 - Parameters:
    - associatedValue: The value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
internal func set<T>(associatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: _AssociatedValue(associatedValue), key: key, object: object)
}

/**
 Sets a weak associated value for the specified object and key.
 
 - Parameters:
    - weakAssociatedValue: The weak value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
internal func set<T: AnyObject>(weakAssociatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: _AssociatedValue(weak: weakAssociatedValue), key: key, object: object)
}

private func set(associatedValue: _AssociatedValue, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, associatedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private class _AssociatedValue {
    weak var _weakValue: AnyObject?
    var _value: Any?

    var value: Any? {
        return _weakValue ?? _value
    }

    init(_ value: Any?) {
        _value = value
    }

    init(weak: AnyObject?) {
        _weakValue = weak
    }
}
