//
//  DoneWorkouts.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 27/5/24.
//

import Foundation

class WorkoutHistory: Identifiable, FirestoreIdentifiable, Hashable, Equatable, Encodable, Decodable {

    
    var id: UUID // This field will be used for hashing
    var UserId: UUID
    var workoutDates: [Date: [LocalWorkout]]
    
    init(id: UUID = UUID(), UserId: UUID, workoutDates: [Date: [LocalWorkout]]) {
        self.id = id
        self.UserId = UserId
        self.workoutDates = workoutDates
    }
    
    // Implement the `Hashable` requirements
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: WorkoutHistory, rhs: WorkoutHistory) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}
