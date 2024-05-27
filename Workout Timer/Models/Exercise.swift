//
//  Exercise.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class Exercise: Identifiable, Hashable, Equatable, Encodable, Decodable {
    
    var id: UUID
    var name: String
    var category: Int
    var bodyRegion: BodyRegion
    var primaryMuscle: Muscle
    var secondaryMusle: Muscle
    var description: String
    
    init(id: UUID, name: String, category: Int, bodyRegion: BodyRegion, primaryMuscle: Muscle, secondaryMusle: Muscle, description: String) {
        self.id = id
        self.name = name
        self.category = category
        self.bodyRegion = bodyRegion
        self.primaryMuscle = primaryMuscle
        self.secondaryMusle = secondaryMusle
        self.description = description
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}

