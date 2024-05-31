//
//  CreateExerciseView.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 28/5/24.
//

import SwiftUI

struct CreateExerciseView: View {
    
    @StateObject var viewModel = CreateExerciseViewModel(newExercise: Exercise(name: "", category: ExerciseCategory(name: "Cardio", description: "Fast Paced"), primaryMuscle: Muscle(name: "Bizeps", bodyRegion: BodyRegion(name: "Upper Body")), equiptmentNeeded: false))
    @State var exerciseCategories: [ExerciseCategory] = []
    @State var muscles: [Muscle] = []
    
    var ExerciseNameTextField: some View {
        TextField("Exercise Name", text: $viewModel.newExercise.name)
            .font(.title2)
    }
    
    var CategoryPicker: some View {
        Picker("Category", selection: $viewModel.newExercise.category){
            ForEach(viewModel.exerciseCategories, id: \.self) { category in
                Text("\(category.name)").tag(category)
            }
        }
    }
    
    var PrimaryMusclePicker: some View {
        Picker("Primary Muscle", selection: $viewModel.newExercise.primaryMuscle){
            ForEach(viewModel.muscles, id: \.self) { muscle in
                Text("\(muscle.name)").tag(muscle)
            }
        }
    }
    
    var SecondaryMusclePicker: some View {
        Picker("Secondary Muscle", selection: $viewModel.newExercise.secondaryMuscle){
            ForEach(viewModel.muscles, id: \.self) { muscle in
                Text("\(muscle.name)").tag(muscle)
            }
        }
    }
    
    var EquiptmentToggle: some View {
        Toggle("Equiptment?", systemImage: "dumbbell", isOn: $viewModel.newExercise.equiptmentNeeded)
    }
    
    var SaveButton: some View {
        Button("Save"){
            viewModel.saveExercise()
        }
    }
//
//    var DescriptionTextField: some View {
//        TextField("Description", text: $viewModel.newExercise.description)
//    }
//    
//    var LinkTextField: some View {
//        TextField("Link", text: $viewModel.newExercise.link)
//    }
    
    var body: some View {
        NavigationView{
            Form{
                ExerciseNameTextField
                
                CategoryPicker
                
                PrimaryMusclePicker
                
//                SecondaryMusclePicker
                
                EquiptmentToggle
                
                //            DescriptionTextField
                //
                //            LinkTextField
            }
            .navigationTitle("Create Exercise")
            .navigationBarItems(trailing: SaveButton)
        }
        .onAppear(){
            viewModel.loadData()
        }
    }
}
