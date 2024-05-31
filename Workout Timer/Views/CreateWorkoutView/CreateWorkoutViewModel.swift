//
//  CreateWorkoutViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 21/5/24.
//

import Foundation

final class CreateWorkoutViewModel: ObservableObject {
    
    @Published var sets: [Set] = []
    @Published var errorMessage: String?
    
    @Published var workoutSetList: [Set] = []
    @Published var newWorkoutName: String = "New Workout"
    @Published var workoutRounds: Int = 1
    @Published var workoutSetDict: [UUID: Int] = [:]
    
    @Published var showNewSetSheet: Bool = false
    @Published var isNewSet: Bool = false
    @Published var newSet: Set = Set(name: "New Set", exercises: [], activeTime: 60, pauseTime: 0)
    
    func saveNewWorkout(name: String, workoutSetDict: [UUID: Int], rounds: Int) {
        let workoutToSave = Workout(name: name, sets: workoutSetDict, rounds: rounds)
        saveDocument(document: workoutToSave, collectionName: "workouts"){ result in
            switch result {
            case .success():
                break
            case .failure(let error):
                print("Error saving workout:", error.localizedDescription)
            }
        }
        
    }
    
    func loadData() {
        loadDocuments(collectionName: "sets") { (result: Result<[Set], Error>) in
            switch result {
            case .success(let fetchedSets):
                self.sets = fetchedSets
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
}
