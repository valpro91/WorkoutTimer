//
//  SetClass.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import Foundation

// adding the body parts that the sets use
// prepare for making exercises their own class with description - how to 

class Set: Identifiable, Hashable, Equatable, Encodable, Decodable, FirestoreIdentifiable {
    var id: UUID
    var name: String
    var exercises: [String] = []
    var activeTime: Int
    var pauseTime: Int
    
    init(id: UUID = UUID(), name: String, exercises: [String], activeTime: Int, pauseTime: Int) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.activeTime = activeTime
        self.pauseTime = pauseTime
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Set, rhs: Set) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
