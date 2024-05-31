//
//  UserProfileView.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 27/5/24.
//

import SwiftUI

struct UserProfileView: View {
    
//    @StateObject var viewModel: UserProfileViewModel
    
    var UserName: some View {
        Text("UserName")
            .font(.largeTitle)
    }

    var Streak: some View {
        HStack{
                Text("x")
                Text("x")
                Text("x")
                Text("x")
        }
    }
    
    var body: some View {
        VStack{
            UserName
            Streak
        }
    }
}
