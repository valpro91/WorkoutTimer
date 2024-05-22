//
//  SetCell.swift
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

                NavigationLink(destination: DoWorkoutScreen(workout: LocalWorkout(name: set.name, sets: [set: 1], rounds: 1), workoutSets: [set], currentSet: set)) { // Navigation to the
                    }
                    .frame(width: 20)
                }
        }
    }
}
