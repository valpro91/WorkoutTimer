//
//  WorkoutListViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 21/5/24.
//

import Foundation

final class SetWorkoutViewModel: ObservableObject {
    
    @Published var workouts: [Workout] = []
    @Published var setLibrary: [Set] = []
    
    @Published var errorMessage: String?

    func loadData() {
        loadSets { result in
            switch result {
            case .success(let fetchedSets):
                self.setLibrary = fetchedSets
                print(self.setLibrary)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
        
        loadWorkouts { result in
            switch result  {
            case .success(let fetchedWorkouts):
                self.workouts = fetchedWorkouts
                print(self.workouts)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
