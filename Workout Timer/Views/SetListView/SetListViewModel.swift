//
//  SetListViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 22/5/24.
//

import Foundation

final class SetListViewModel: ObservableObject {
    
    @Published var sets: [Set] = []
    @Published var selectedSet: Set = Set(name: "Default", exercises: ["deadlift"], activeTime: 1, pauseTime: 1)
    
    @Published var showingEditScreen = false
    @Published var isNewSet = false
    @Published var errorMessage: String?
    
    func loadData() {
        loadDocuments(collectionName: "sets") { (result: Result<[Set], Error>) in
            switch result {
            case .success(let fetchedSets):
                self.sets = fetchedSets
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
}
