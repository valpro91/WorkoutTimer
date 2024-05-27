//
//  EditSetScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct EditSetScreen: View {
    @StateObject private var viewModel: EditSetViewModel
    
    @Environment(\.dismiss) var dismiss
    
    init(set: Binding<Set>, sets: Binding<[Set]>, isNewSet: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: EditSetViewModel(set: set.wrappedValue, sets: sets.wrappedValue, isNewSet: isNewSet.wrappedValue))
    }
    
    var body: some View {
        VStack {
            HStack {
                TextInputField(viewModel.set.name, text: $viewModel.set.name)
                    .font(.largeTitle)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Text("Active Time")
                    Picker("Active Time", selection: $viewModel.set.activeTime) {
                        ForEach([15, 30, 45, 60, 75, 90, 120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }
                
                VStack {
                    Text("Pause Time")
                    Picker("Pause Time", selection: $viewModel.set.pauseTime) {
                        ForEach([0, 5, 10, 15, 30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }
            }
            
            VStack {
                Text("Exercises")
                List {
                    ForEach(viewModel.set.exercises, id: \.self) { element in
                        Text(element)
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    TextInputField("Add Exercise", text: $viewModel.exerciseToAdd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        viewModel.addExercise()
                    }
                }
                .padding()
            }
            .padding()
            
            HStack {
                Button("Save") {
                    viewModel.saveSetToFireBase { result in
                        switch result {
                        case .success():
                            dismiss()
                        case .failure(let error):
                            print("Error saving workout:", error.localizedDescription)
                        }
                    }
                }
            }
            .padding()
        }
        .onDisappear {
            viewModel.handleDisappear()
        }
    }
}
