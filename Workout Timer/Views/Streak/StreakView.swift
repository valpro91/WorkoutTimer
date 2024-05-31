//
//  StreakView.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 27/5/24.
//

import SwiftUI

struct StreakView: View {
    
    var body: some View {
        VStack{
            Text("You already worked out today")
                .font(.title)
            Image(systemName: "checkmark")
                .font(.largeTitle)
            Spacer()
            Text("Current Streak:")
                .font(.headline)
            Text("24")
                .font(.headline)
            Text("days")
            Spacer()
            Button("Do another Workout today, and add to your off days"){
                //link to workoutlist
            }
            Button("Do a random Workout"){
                //start random workout
            }
        }
    }
}
