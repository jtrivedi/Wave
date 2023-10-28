//
//  Collection+Extension.swift
//  
//
//  Created by Florian Zand on 28.10.23.
//

import Foundation

public extension Collection where Index == Int {
    
    /**
     Splits the collection into arrays with the specified size.
     
     Any remaining elements will be added to a seperate chunk.
     
     ```swift
     let array = [1,2,3,4,5,6,7,8,9]
     array.chunked(size: 3) // [[1,2,3], [4,5,6], [7,8,9]]
     array.chunked(size: 2) // [[1,2], [3,4], [5,6], [7,8], [9]]
     ```
     
     - Parameters size: The size of the chunk.
     - Returns: Returns an array of chunks.
     */
    func chunked(size: Int) -> [[Element]] {
        let size = (size > 0) ? size : 1
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
