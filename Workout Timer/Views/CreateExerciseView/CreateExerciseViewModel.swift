//
//  CreateExerciseViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 28/5/24.
//

import Foundation

class CreateExerciseViewModel: ObservableObject {
    
    @Published var newExercise: Exercise
    @Published var muscles: [Muscle] = []
    @Published var exerciseCategories: [ExerciseCategory] = []
    
    @Published var errorMessage: String?

    init(newExercise: Exercise) {
        self.newExercise = newExercise
    }
    
    
    func saveExercise(){
        
//        for exerciseCategorie in exerciseCategories {
//            saveDocument(document: exerciseCategorie, collectionName: "exerciseCategories") {
//                result in switch result {
//                case .success():
//                    return
//                case .failure(let error):
//                    print("Error saving ecercise", error.localizedDescription)
//                }
//            }
//        }
        
        saveDocument(document: newExercise, collectionName: "exercises") { result in
            switch result {
            case .success():
                return
            case .failure(let error):
                print("Error saving exercise", error.localizedDescription)
            }
        }
        
        print("tried to save")
        
    }
    
    func loadData() {

        loadDocuments(collectionName: "muscles") { (result: Result<[Muscle], Error>) in
            switch result {
            case .success(let fetchedMuscles):
                self.muscles = fetchedMuscles
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
        
        loadDocuments(collectionName: "exerciseCategories") { (result: Result<[ExerciseCategory], Error>) in
            switch result {
            case .success(let fetchedExerciseCategories):
                self.exerciseCategories = fetchedExerciseCategories
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
