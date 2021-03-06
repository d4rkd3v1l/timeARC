//
//  FetchableById.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

import CoreData

protocol FetchableById: NSManagedObject {
    associatedtype ManagedObject = Self where ManagedObject: FetchableById
    static func fetchRequest() -> NSFetchRequest<ManagedObject>
}

extension ManagedTimeEntry: FetchableById {}
extension ManagedAbsenceEntry: FetchableById {}
extension ManagedAbsenceType: FetchableById {}

