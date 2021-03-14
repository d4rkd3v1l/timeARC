//
//  Sequence+Duplicates.swift
//  timeARC
//
//  Created by d4Rk on 14.03.21.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    /// Returns any duplicates after the first instance seen
    func duplicates<T: Hashable>(by transform: (Iterator.Element) -> T) -> [Iterator.Element] {
        var uniqueValues: [T] = []
        var duplicateValues: [Iterator.Element] = []

        self.forEach { item in
            let transformedItem = transform(item)
            if uniqueValues.contains(transformedItem) {
                duplicateValues.append(item)
            } else  {
                uniqueValues.append(transformedItem)
            }
        }

        return duplicateValues
    }
}
