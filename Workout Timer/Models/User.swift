//
//  User.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 26/5/24.
//

import Foundation

class User: Identifiable, Hashable, Equatable, Encodable, Decodable {
    
    var id: UUID
    var firstname: String
    var lastname: String
    var sex: String
    var workouts: [UUID] = []
    
    init(id: UUID, firstname: String, lastname: String, sex: String, workouts: [UUID]) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.sex = sex
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
