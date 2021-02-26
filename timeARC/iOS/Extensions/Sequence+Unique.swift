//
//  Sequence+Unique.swift
//  timeARC
//
//  Created by d4Rk on 10.10.20.
//

// https://stackoverflow.com/a/27624476/2019384
extension Sequence where Iterator.Element: Equatable {
    var unique: [Iterator.Element] {
        var uniqueValues: [Iterator.Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
