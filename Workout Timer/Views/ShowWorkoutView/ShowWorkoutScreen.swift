//
//  ShowWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI
import AVFoundation
import AVFAudio
import UIKit // Required for UIApplication.shared

//import FirebaseFirestore
//import FirebaseFirestoreSwift

struct ShowWorkoutScreen: View {
    @Binding var workout: Workout
    @State private var setLibrary: [Set] = []
    @State private var workoutSetArray: [Set] = []
    @State private var workoutSetRoundsDict: [Set: Int] = [:]
    
    @State private var errorMessage: String?
    
    // Design Workout Screen
    // Design DoWorkout Screen
    // Handle Storage, Saving and Loading globally
    // split up code in multiple files
    
    
    func matchSetIDsWithSets(workoutDict: [UUID: Int]) -> [Set]{
        let setIDArray = Array(workoutDict.keys)
        let workoutSets = setLibrary.filter { set in
            if workout.sets[set.id] != nil {
                return true
            } else {
                return false
            }
        }
        return workoutSets
    }
    
    func createSetRoundsDict(workoutSetArray: [Set], workoutDict: [UUID: Int]) -> [Set: Int] {
        var workoutSetDict: [Set: Int] = [:]
        for set in workoutSetArray {
            workoutSetDict[set] = workoutDict[set.id]
        }
        return workoutSetDict
    }
    
    var body: some View{
        NavigationView{
            VStack{
                Text(workout.name)
//                List(workoutSetArray){ set in
//                    Text("Hello")
//
//                }
                NavigationLink(destination: DoWorkoutScreen(workout: LocalWorkout(name: workout.name, sets: workoutSetRoundsDict ,rounds: workout.rounds), workoutSets: workoutSetArray, currentSet: workoutSetArray.first ?? Set(name: "Default", exercises: [], activeTime: 60, pauseTime: 0))){
                    Text("Start Workout")
                }
            }
            .onAppear(){
                print("hello")
                loadSets { result in
                    switch result {
                    case .success(let fetchedSets):
                        setLibrary = fetchedSets
                        workoutSetArray = matchSetIDsWithSets(workoutDict: workout.sets)
                        workoutSetRoundsDict = createSetRoundsDict(workoutSetArray: workoutSetArray, workoutDict: workout.sets)
                        print("hello")
                        print(workoutSetArray)
                        print(workoutSetRoundsDict)
                    case .failure(let error):
                        
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
