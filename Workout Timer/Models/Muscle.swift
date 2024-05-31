//
//  File.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class Muscle : Identifiable, FirestoreIdentifiable, Hashable, Equatable, Encodable, Decodable {
    
    var id: UUID
    var name: String
    var bodyRegion: BodyRegion
    
    init(id: UUID = UUID(), name: String, bodyRegion: BodyRegion) {
        self.id = id
        self.name = name
        self.bodyRegion = bodyRegion
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Muscle, rhs: Muscle) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
