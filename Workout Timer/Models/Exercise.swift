//
//  Exercise.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class Exercise: Identifiable, Hashable, Equatable, Encodable, Decodable, FirestoreIdentifiable {
    
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var primaryMuscle: Muscle
    var secondaryMuscle: Muscle?
    var equiptmentNeeded: Bool
    var description: String?
    var link: String?
    
    init(id: UUID = UUID(), name: String, category: ExerciseCategory, primaryMuscle: Muscle, secondaryMuscle: Muscle? = nil, equiptmentNeeded: Bool, description: String? = nil, link: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscle = secondaryMuscle
        self.equiptmentNeeded = equiptmentNeeded
        self.description = description
        self.link = link
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}

