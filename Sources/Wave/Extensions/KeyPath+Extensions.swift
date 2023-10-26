//
//  KeyPath+Extensions.swift
//
//
//  Created by Florian Zand on 13.10.23.
//

import Foundation

public extension PartialKeyPath {
    /// The name of the key path.
    var stringValue: String {
        if let string = self._kvcKeyPathString {
            return string
        }
        let me = String(describing: self)
        let rootName =  String(describing: Root.self)
        let removingRootName = me.components(separatedBy: rootName)
        var keyPathValue = removingRootName.last ?? ""
        if keyPathValue.first == "." { keyPathValue.removeFirst() }
        return keyPathValue
    }
}
