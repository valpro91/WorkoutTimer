//
//  DoSetView.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 23/5/24.
//

import SwiftUI


struct DoSetView: View {
    
    // add between Set screen - customize between set pause ?
    
    @StateObject var viewModel: DoSetViewModel
    
    @State var showCancelAlert = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var CurrentWorkoutName: some View {
        Text(viewModel.workout.name)
    }
    
    var CurrentSet: some View {
        Text("\(String(describing: viewModel.workout.sets[viewModel.setArray[viewModel.setCounter]]!))x \(viewModel.setArray[viewModel.setCounter].name): \(viewModel.exerciseCounter + 1)/\(viewModel.setArray[viewModel.setCounter].exercises.count)")
    }
    
    var RoundsText: some View {
        Text("\(String(describing: viewModel.workout.sets[viewModel.setArray[viewModel.setCounter]]))")
    }
    
    var CurrentExerciseName: some View {
        Text(viewModel.setArray[viewModel.setCounter].exercises[viewModel.exerciseCounter])
    }
    
    var TimeLeft: some View {
        Text("\(viewModel.timeRemaining)")
            .font(.system(size: 100))
            .fontWeight(.bold)
    }
    
    var PauseButton: some View {
        Button("Pause", systemImage: viewModel.isRunning ? "pause.circle":"play.circle"){
            viewModel.isRunning ? viewModel.pauseSet(): viewModel.startSet()
            
        }
        .font(.system(size: 50))
        .labelStyle(.iconOnly)
        .tint(Color(.systemGray5))
    }
    
    var CancelButton: some View {
        Button("Cancel"){
            showCancelAlert = true
        }
    }
    
    var CountdownOverlay: some View {
         ZStack {
             Color.black.opacity(0.9)
                 .edgesIgnoringSafeArea(.all)
             VStack{
                 Text("Get ready Workout starts in:")
                     .font(.headline)
                 Text("\(viewModel.countDownTime)")
                     .font(.system(size: 120))
                     .fontWeight(.bold)
                     .foregroundColor(.white)
             }
         }
         .transition(.opacity)
         .zIndex(1)  // Ensure the overlay is on top
     }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color(viewModel.isSetActive ? .systemGreen: .systemBackground)
                    .edgesIgnoringSafeArea(.all)

                
                VStack{
                    CurrentSet
                    Spacer()
                    TimeLeft
                    Spacer()
                    PauseButton
                        .padding()
                    VStack{
                        CurrentWorkoutName
                            .font(.title)
                    }
                }
                if viewModel.showCountDownOverlay {
                                    CountdownOverlay
                                }
            }
            .navigationTitle(viewModel.setArray[viewModel.setCounter].exercises[viewModel.exerciseCounter])
            .navigationBarItems(leading: CancelButton)
            
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showCancelAlert) {
                   Alert(
                       title: Text("Cancel Workout"),
                       message: Text("Are you sure you want to cancel the workout and go back?"),
                       primaryButton: .destructive(Text("Give Up")) {
                           viewModel.pauseSet()
                           dismiss()
                       },
                       secondaryButton: .cancel(Text("Get Stronger"))
                   )
               }
        .onAppear(){
            viewModel.startCountDownTimer()
            viewModel.startSet()
        }
        .onDisappear(){
            viewModel.pauseSet()
        }
        .onChange(of: viewModel.shouldDismiss, initial: false){
            dismiss()
        }
    }
}
