//
//  File.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class BodyRegion : Identifiable, Hashable, Equatable, Encodable, Decodable {
    
    var id: UUID
    var name: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: BodyRegion, rhs: BodyRegion) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
