//
//  Exercise.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class ExerciseCategory: Identifiable, Hashable, Equatable, Encodable, Decodable {
    
    var id: UUID
    var name: String
    var description: String
    
    init(id: UUID, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ExerciseCategory, rhs: ExerciseCategory) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}

