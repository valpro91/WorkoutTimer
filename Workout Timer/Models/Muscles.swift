//
//  Muscles.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class Muscle: Identifiable, Hashable, Equatable, Encodable, Decodable {
    var id: UUID
    var name: String
    var primaryBodyRegion: BodyRegion
    
    init(id: UUID, name: String, primaryBodyRegion: BodyRegion) {
        self.id = id
        self.name = name
        self.primaryBodyRegion = primaryBodyRegion
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: Muscle, rhs: Muscle) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
    
}
