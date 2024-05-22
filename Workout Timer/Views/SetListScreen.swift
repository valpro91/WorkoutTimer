//
//  SetListScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct SetListScreen: View {
    @State private var sets: [Set] = []
    @State private var selectedSet: Set = Set(name: "Default", exercises: ["deadlift"], activeTime: 1, pauseTime: 1)
    
    @State private var showingEditScreen = false
    @State private var isNewSet = false
    @State private var errorMessage: String?

        var body: some View {
            NavigationView {
                VStack{
                    List(sets) { set in
                       SetCell(
                            set: set,
                            onEdit: {
                                
                                selectedSet = set // Store ID
                                showingEditScreen = true
                            
                            }
                        )
                    }
                    .listStyle(.plain)
                    .sheet(isPresented: $showingEditScreen) {
                        
                            EditSetScreen(set: $selectedSet, sets: $sets, isNewSet: $isNewSet)
                     
                    }
                    
                    Button("Add New Set", systemImage: "plus.circle", action: {
                        let newSet = Set(name: "New Workout", exercises: [], activeTime: 0, pauseTime: 0)
                        sets.append(newSet)
                        selectedSet = newSet
                        showingEditScreen = true
                        isNewSet = true
                    })
                    .font(.largeTitle)
                    .labelStyle(.iconOnly)
                }
                .navigationBarTitle("Sets")
                .onAppear(){
                    print("Loading")
                    loadSets { result in
                        switch result {
                        case .success(let fetchedSets):
                            sets = fetchedSets
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
}
