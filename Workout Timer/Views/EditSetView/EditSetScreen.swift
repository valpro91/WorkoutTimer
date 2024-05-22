//
//  EditSetScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct EditSetScreen: View {
    @Binding var set: Set
    @Binding var sets: [Set]
    @Binding var isNewSet: Bool
    @State private var savedNewSet: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var exerciseToAdd = ""
    @State private var renamingWorkout = false
    
    
    
    //try using form  
    
    var body: some View {
        VStack {
            HStack {
                TextField(set.name, text: $set.name)
                    .font(.largeTitle)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $set.activeTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                    
                }
                
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $set.pauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
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
                    ForEach(set.exercises, id: \.self) { element in
                        Text(element)
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    TextField("Add Exercise", text: $exerciseToAdd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !exerciseToAdd.isEmpty {
                            set.exercises.append(exerciseToAdd)
                            exerciseToAdd = ""
                        }
                    }
                }
                .padding()
            }
            .padding()
            
            HStack{
                Button("Save") {
                    saveSet(set: set) { result in
                        switch result {
                        case .success():
                            savedNewSet = true
                            dismiss()
                        case .failure(let error):
                            print("Error saving workout:", error.localizedDescription)
                        }
                    }
                }
            
            }
            .padding()
        }
        .onDisappear(){
            if (isNewSet == true && savedNewSet == false) {
                sets.removeLast()
                isNewSet = false
            }
        }
    }
}
