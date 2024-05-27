//
//  CreateWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct CreateWorkoutScreen: View {
   
    @StateObject private var viewModel = CreateWorkoutViewModel()
    
    var WorkoutTitleTextField: some View {
        TextInputField(viewModel.newWorkoutName, text: $viewModel.newWorkoutName)
            .font(.largeTitle)
            .padding()
    }
    
    var SaveButton: some View {
        Button("Save"){
            viewModel.saveNewWorkout(name: viewModel.newWorkoutName, workoutSetDict: viewModel.workoutSetDict, rounds: viewModel.workoutRounds)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    var NewSetButton: some View {
        Button("New Set", systemImage: "plus.circle", action: {
            viewModel.sets.append(viewModel.newSet)
            viewModel.isNewSet = true
            viewModel.showNewSetSheet = true
        })
        .labelStyle(.iconOnly)
    }
    
    var WorkoutRoundsPicker: some View {
        Picker("Rounds", selection: $viewModel.workoutRounds){
            ForEach([1,2,3,4,5], id: \.self) { round in
                Text("\(round)").tag(round)
            }
        }
            .pickerStyle(.segmented)
    }
    
    
    var WorkoutSetList: some View {
        List(viewModel.workoutSetList) { set in
            HStack{
                setListCellNameTitle(set.name)
                    .frame(width: UIScreen.main.bounds.width/4)
                Spacer()
                
                Picker("Rounds", selection: Binding(
                    get: { viewModel.workoutSetDict[set.id] ?? 1 },
                    set: { viewModel.workoutSetDict[set.id] = $0 }
                )){
                    ForEach(1...10, id: \.self) { round in
                        Text("\(round)").tag(round)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: UIScreen.main.bounds.width/3)



                Spacer()
                Button("Remove"){
                    let index = viewModel.workoutSetList.firstIndex(of:set)
                    viewModel.workoutSetList.remove(at: index ?? 0)
                    viewModel.workoutSetDict[set.id] = nil
                }
                .buttonStyle(.borderless)
            }
        }
        .listStyle(.grouped)
    }
    
    var SetLibraryList: some View {
        List(viewModel.sets) {set in
            HStack{
                Text(set.name)
                    .font(.title)
                Spacer()
                Button("Add"){
                    
                    if viewModel.workoutSetDict[set.id] == nil {
                        viewModel.workoutSetList.append(set)
                        viewModel.workoutSetDict[set.id] = 1
                    } else {
                        
                    }
                }
            }
        }
        .listStyle(.grouped)
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
                    
                WorkoutSetList
                
                Text("Workout Rounds:")
                    .font(.callout)
                
                WorkoutRoundsPicker
                Spacer()
                HStack{
                    Text("Set Library")
                    NewSetButton
                }
                .sheet(isPresented: $viewModel.showNewSetSheet) {
                    EditSetScreen(set: $viewModel.newSet, sets: $viewModel.sets, isNewSet: $viewModel.isNewSet)
                }
               
                SetLibraryList
            }
            .onAppear(){
                viewModel.loadData()
            }
        }
    }
}
