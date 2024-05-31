import SwiftUI
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var localWorkout: LocalWorkout?
    @Published var setLibrary: [Set] = []
    @Published var workoutSetArray: [Set] = []
    @Published var workoutSetRoundsDict: [Set: Int] = [:]
    @Published var errorMessage: String?

    init(workout: Workout) {
        self.workout = workout
    }
    

    func loadData() {
        // Assume this is an asynchronous function
        loadDocuments(collectionName: "sets") { (result: Result<[Set], Error>) in
            switch result {
            case .success(let fetchedSets):
                self.setLibrary = fetchedSets
                self.workoutSetArray = self.matchSetIDsWithSets(workoutDict: self.workout.sets)
                self.workoutSetRoundsDict = self.createSetRoundsDict(workoutSetArray: self.workoutSetArray, workoutDict: self.workout.sets)
                self.localWorkout = LocalWorkout(name: self.workout.name, sets: self.workoutSetRoundsDict, rounds: self.workout.rounds)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func matchSetIDsWithSets(workoutDict: [UUID: Int]) -> [Set] {
        return setLibrary.filter { set in
            workout.sets[set.id] != nil
        }
    }

    private func createSetRoundsDict(workoutSetArray: [Set], workoutDict: [UUID: Int]) -> [Set: Int] {
        var workoutSetDict: [Set: Int] = [:]
        for set in workoutSetArray {
            if let rounds = workoutDict[set.id] {
                workoutSetDict[set] = rounds
            }
        }
        return workoutSetDict
    }
    
    func updateSet(_ updatedSet: Set) {
            if let index = workoutSetArray.firstIndex(where: { $0.id == updatedSet.id }) {
                workoutSetArray[index] = updatedSet
        }
    }
}
