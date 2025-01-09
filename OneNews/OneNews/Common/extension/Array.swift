//
//  Array.swift
//  OneNews
//
//  Created by Sok Pich on 1/9/25.
//

import SwiftUI


extension Array {
    //MARK: - Chunking Arrays
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
///    Components Breakdown
//    1. func chunked(into size: Int)
///        - This function takes an integer size as an argument, which specifies the maximum number of elements in each chunk.
//    2. stride(from: 0, to: count, by: size)
///        - stride generates a sequence of numbers starting from 0 and ending before count, incrementing by size. This lets us iterate over array indices at intervals of size.
///        - Example: If count is 25 and size is 10, stride(from: 0, to: 25, by: 10) will produce 0, 10, 20.
//    3. .map { ... }
///        - map applies a transformation to each element in the stride sequence. Here, it transforms each starting index into a subarray (chunk) of the original array.
//    4. Array(self[$0..<Swift.min($0 + size, count)])
///        - $0 is each starting index from stride.
///        - $0..<Swift.min($0 + size, count) creates a range for slicing the array.
///        - Swift.min($0 + size, count) ensures the end of the range does not exceed the array's bounds (count).
}
