//
//  UserProfileViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 27/5/24.
//

import Foundation

class UserProfileViewModel: ObservableObject {
    @Published var User: User
    
    init(User: User) {
        self.User = User
    }
}
