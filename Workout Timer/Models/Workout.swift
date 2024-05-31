//
//  WorkoutClasses.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import Foundation


class Workout: Identifiable, Hashable, Equatable, Encodable, Decodable, FirestoreIdentifiable {
    var id: UUID // This field will be used for hashing
    var name: String
//    var warmup: String
//    var finisher: String
    var sets: [UUID: Int]

    var rounds: Int
    
    init(id: UUID = UUID(), name: String, sets: [UUID: Int], rounds: Int) {
        self.id = id
        self.name = name
        self.sets = sets
        self.rounds = rounds
    }
    
    // Implement the `Hashable` requirements
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
