//
//  FirebaseFunctions.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift

protocol FirestoreIdentifiable {
    var id: UUID { get }
}

//
//
//// Save a single workout to Firestore
//func saveUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    do {
//        try db.collection("users").document(user.id.uuidString).setData(from: user) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    } catch {
//        completion(.failure(error))
//    }
//}
//
//// Save a single workout to Firestore
//func saveWorkout(workout: Workout, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    do {
//        try db.collection("workouts").document(workout.id.uuidString).setData(from: workout) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    } catch {
//        completion(.failure(error))
//    }
//}
//
//// Save a single workout to Firestore
//func saveSet(set: Set, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    do {
//        try db.collection("sets").document(set.id.uuidString).setData(from: set) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    } catch {
//        completion(.failure(error))
//    }
//}
//// Load all workouts from Firestore
//func loadWorkouts(completion: @escaping (Result<[Workout], Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("workouts").getDocuments { querySnapshot, error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            let workouts: [Workout] = querySnapshot?.documents.compactMap { doc in
//                try? doc.data(as: Workout.self)
//            } ?? []
//            completion(.success(workouts))
//        }
//    }
//}
//
//// Load all sets from Firestore
//func loadSets(completion: @escaping (Result<[Set], Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("sets").getDocuments { querySnapshot, error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            let sets: [Set] = querySnapshot?.documents.compactMap { doc in
//                try? doc.data(as: Set.self)
//            } ?? []
//            completion(.success(sets))
//        }
//    }
//}
//
//// Load all sets from Firestore
//func loadUsers(completion: @escaping (Result<[User], Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("users").getDocuments { querySnapshot, error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            let users: [User] = querySnapshot?.documents.compactMap { doc in
//                try? doc.data(as: User.self)
//            } ?? []
//            completion(.success(users))
//        }
//    }
//}
//
//// Delete a workout from Firestore
//func deleteWorkout(workout: Workout, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("workouts").document(workout.id.uuidString).delete { error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            completion(.success(()))
//        }
//    }
//}
//
//// Delete a set from Firestore
//func deleteSet(set: Set, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("sets").document(set.id.uuidString).delete { error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            completion(.success(()))
//        }
//    }
//}
//
//// Delete a set from Firestore
//func deleteUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("users").document(user.id.uuidString).delete { error in
//        if let error = error {
//            completion(.failure(error))
//        } else {
//            completion(.success(()))
//        }
//    }
//}


// Save a single document to Firestore
func saveDocument<T: FirestoreIdentifiable & Codable>(document: T, collectionName: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    do {
        try db.collection(collectionName).document(document.id.uuidString).setData(from: document) { error in
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

// Load all documents from a Firestore collection
func loadDocuments<T: FirestoreIdentifiable & Codable>(collectionName: String, completion: @escaping (Result<[T], Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection(collectionName).getDocuments { querySnapshot, error in
        if let error = error {
            completion(.failure(error))
        } else {
            let documents: [T] = querySnapshot?.documents.compactMap { doc in
                try? doc.data(as: T.self)
            } ?? []
            completion(.success(documents))
        }
    }
}

// Delete a document from Firestore
func deleteDocument<T: FirestoreIdentifiable>(document: T, collectionName: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    db.collection(collectionName).document(document.id.uuidString).delete { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}
