//
//  CreateWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct CreateWorkoutScreen: View {
    @State private var sets: [Set] = []
    @State private var errorMessage: String?
    
    @State private var workoutSetList: [Set] = []
    @State private var newWorkoutName: String = "New Workout"
    @State private var workoutRounds: Int = 1
    @State private var workoutSetDict: [UUID: Int] = [:]
    
    @State private var showNewSetSheet: Bool = false
    @State private var isNewSet: Bool = false
    @State private var newSet: Set = Set(name: "New Set", exercises: [], activeTime: 60, pauseTime: 0)
    
    func saveNewWorkout(name: String, workoutSetDict: [UUID: Int], rounds: Int) {
        let workoutToSave = Workout(name: name, sets: workoutSetDict, rounds: rounds)
        saveWorkout(workout: workoutToSave){ result in
            switch result {
            case .success():
                break
            case .failure(let error):
                print("Error saving workout:", error.localizedDescription)
            }
        }
        
    }
    
    var WorkoutTitleTextField: some View {
        TextField(newWorkoutName, text: $newWorkoutName)
            .font(.largeTitle)
            .padding()
    }
    
    var SaveButton: some View {
        Button("Save"){
            saveNewWorkout(name: newWorkoutName, workoutSetDict: workoutSetDict, rounds: workoutRounds)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    var WorkoutRoundsPicker: some View {
        Picker("Rounds", selection: $workoutRounds){
            ForEach([1,2,3,4,5], id: \.self) { round in
                Text("\(round)").tag(round)
            }
        }
            .pickerStyle(.segmented)
    }
    
  
    func setListCellNameTitle(_ text: String) -> Text {
        Text(text)
            .font(.title)
    }
    
    
    

    var body: some View {
    
        NavigationView{
            VStack{
                HStack{
                    WorkoutTitleTextField
                    SaveButton
                }
                    Text("Sets in your new Workout")
                    
                
                List(workoutSetList) { set in
                    HStack{
                        setListCellNameTitle(set.name)
                            .frame(width: UIScreen.main.bounds.width/4)
                        Spacer()
                        
                        Picker("Rounds", selection: Binding(
                            get: { workoutSetDict[set.id] ?? 1 },
                            set: { workoutSetDict[set.id] = $0 }
                        )){
                            ForEach(1...10, id: \.self) { round in
                                Text("\(round)").tag(round)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: UIScreen.main.bounds.width/3)

    

                        Spacer()
                        Button("Remove"){
                            let index = workoutSetList.firstIndex(of:set)
                            workoutSetList.remove(at: index ?? 0)
                            workoutSetDict[set.id] = nil
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .listStyle(.grouped)
                Text("Workout Rounds:")
                    .font(.callout)
                WorkoutRoundsPicker
                Spacer()
                HStack{
                    Text("Set Library")
                    Button("New Set", systemImage: "plus.circle", action: {
                        sets.append(newSet)
                        isNewSet = true
                        showNewSetSheet = true
                        
                        
                    })
                    .labelStyle(.iconOnly)
              
                }
                .sheet(isPresented: $showNewSetSheet) {
                    
                    EditSetScreen(set: $newSet, sets: $sets, isNewSet: $isNewSet)
                 
                }
               
                
                List(sets) {set in
                    HStack{
                        Text(set.name)
                            .font(.title)
                        Spacer()
                        Button("Add"){
                            
                            if workoutSetDict[set.id] == nil {
                                workoutSetList.append(set)
                                workoutSetDict[set.id] = 1
                            } else {
                                
                            }
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .onAppear(){
                loadSets { result in
                    switch result {
                    case .success(let fetchedSets):
                        sets = fetchedSets
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
