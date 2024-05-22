//
//  FirebaseFunctions.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift



// Save a single workout to Firestore
func saveWorkout(workout: Workout, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    do {
        try db.collection("workouts").document(workout.id.uuidString).setData(from: workout) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    } catch {
        completion(.failure(error))
    }
}

// Save a single workout to Firestore
func saveSet(set: Set, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    do {
        try db.collection("sets").document(set.id.uuidString).setData(from: set) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    } catch {
        completion(.failure(error))
    }
}
// Load all workouts from Firestore
func loadWorkouts(completion: @escaping (Result<[Workout], Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection("workouts").getDocuments { querySnapshot, error in
        if let error = error {
            completion(.failure(error))
        } else {
            let workouts: [Workout] = querySnapshot?.documents.compactMap { doc in
                try? doc.data(as: Workout.self)
            } ?? []
            completion(.success(workouts))
        }
    }
}

// Load all sets from Firestore
func loadSets(completion: @escaping (Result<[Set], Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection("sets").getDocuments { querySnapshot, error in
        if let error = error {
            completion(.failure(error))
        } else {
            let sets: [Set] = querySnapshot?.documents.compactMap { doc in
                try? doc.data(as: Set.self)
            } ?? []
            completion(.success(sets))
        }
    }
}

// Delete a workout from Firestore
func deleteWorkout(workout: Workout, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection("workouts").document(workout.id.uuidString).delete { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}

// Delete a set from Firestore
func deleteSet(set: Set, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection("sets").document(set.id.uuidString).delete { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}
