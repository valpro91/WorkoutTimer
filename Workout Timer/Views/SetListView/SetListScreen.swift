//
//  SetListScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct SetCell: View {
    let set: Set
    let onEdit: () -> Void // Closure for the edit action

    var body: some View {
        HStack {
            Text(set.name) // Workout name
                .font(.headline)
            Spacer()

            HStack{
                    Button(action: onEdit) { // Button for the edit action
                        Image(systemName: "pencil") // Pencil icon for editing
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 20)

                NavigationLink(destination: DoWorkoutScreen(viewModel: DoWorkoutViewModel(workout: LocalWorkout(name: set.name, sets: [set: 1], rounds: 1), workoutSets: [set]))) { // Navigation to the
                    }
                    .frame(width: 20)
                }
        }
    }
}

struct SetListScreen: View {

    @StateObject var viewModel = SetListViewModel()

        var body: some View {
            NavigationView {
                VStack{
                    List(viewModel.sets) { set in
                       SetCell(
                            set: set,
                            onEdit: {
                                
                                viewModel.selectedSet = set // Store ID
                                viewModel.showingEditScreen = true
                            
                            }
                        )
                    }
                    .listStyle(.plain)
                    .sheet(isPresented: $viewModel.showingEditScreen) {
                        
                        EditSetScreen(set: $viewModel.selectedSet, sets: $viewModel.sets, isNewSet: $viewModel.isNewSet)
                     
                    }
                    
                    Button("Add New Set", systemImage: "plus.circle", action: {
                        let newSet = Set(name: "", exercises: [], activeTime: 0, pauseTime: 0)
                        viewModel.sets.append(newSet)
                        viewModel.selectedSet = newSet
                        viewModel.showingEditScreen = true
                        viewModel.isNewSet = true
                    })
                    .font(.largeTitle)
                    .labelStyle(.iconOnly)
                }
                .navigationBarTitle("Sets")
                .onAppear(){
                    viewModel.loadData()
                }
            }
        }
}
