//
//  EditSetViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 22/5/24.
//

import Foundation
import SwiftUI

class EditSetViewModel: ObservableObject {
    @Published var set: Set
    @Published var sets: [Set]
    @Published var isNewSet: Bool
    @Published var savedNewSet: Bool = false
    @Published var exerciseToAdd: String = ""

    @Environment(\.dismiss) var dismiss
    
    init(set: Set, sets: [Set], isNewSet: Bool) {
        self.set = set
        self.sets = sets
        self.isNewSet = isNewSet
    }
    
    func addExercise() {
        if !exerciseToAdd.isEmpty {
            set.exercises.append(exerciseToAdd)
            exerciseToAdd = ""
        }
    }
    
    func saveSetToFireBase(completion: @escaping (Result<Void, Error>) -> Void) {
        saveDocument(document: set, collectionName: "sets") { result in
            switch result {
            case .success():
                self.savedNewSet = true
                self.dismiss()
            case .failure(let error):
                print("Error saving workout:", error.localizedDescription)
            }
        }
    }
    
    func handleDisappear() {
        if isNewSet && !savedNewSet {
            sets.removeLast()
            isNewSet = false
        }
    }
}
