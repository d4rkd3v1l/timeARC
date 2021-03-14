//
//  Sequence+Unique.swift
//  timeARC
//
//  Created by d4Rk on 10.10.20.
//

extension Sequence where Iterator.Element: Equatable {
    // https://stackoverflow.com/a/27624476/2019384
    var unique: [Iterator.Element] {
        var uniqueValues: [Iterator.Element] = []

        self.forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues.append(item)
            }
        }
        
        return uniqueValues
    }
}
