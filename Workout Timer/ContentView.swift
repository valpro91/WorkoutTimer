import SwiftUI
import AVFoundation
import AVFAudio
import UIKit // Required for UIApplication.shared

import FirebaseFirestore
import FirebaseFirestoreSwift



class Workout: Identifiable, Hashable, Equatable, Encodable, Decodable {
    var id: UUID // This field will be used for hashing
    var name: String
    var exercises: [String] = []
    var activeTime: Int
    var pauseTime: Int
    var rounds: Int
    
    init(id: UUID = UUID(), name: String, exercises: [String] = [], activeTime: Int, pauseTime: Int, rounds: Int) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.activeTime = activeTime
        self.pauseTime = pauseTime
        self.rounds = rounds
    }
    
    // Implement the `Hashable` requirements
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}


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


// Define a custom SwiftUI cell to represent each workout in the list
struct WorkoutCell: View {
    let workout: Workout
    let onEdit: () -> Void // Closure for the edit action

    var body: some View {
        HStack {
            Text(workout.name) // Workout name
                .font(.headline)
            Spacer()

            HStack{
                    Button(action: onEdit) { // Button for the edit action
                        Image(systemName: "pencil") // Pencil icon for editing
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 20)

                NavigationLink(destination: WorkoutScreen(workout: .constant(workout))) { // Navigation to the
                    }
                    .frame(width: 20)
                }
        }
    }
}

struct StartScreen: View {
    @State private var workouts: [Workout] = []
    @State private var selectedWorkout: Workout?
    @State private var showingEditScreen = false
    @State private var errorMessage: String?

        var body: some View {
            NavigationView {
                List(workouts) { workout in
                    WorkoutCell(
                        workout: workout,
                        onEdit: {
                            
                            // Custom action for the edit button
                            selectedWorkout = workout
                            showingEditScreen = true
                        }
                    )
                }
                .sheet(isPresented: $showingEditScreen) {
                    if let index = workouts.firstIndex(of: selectedWorkout ?? workouts[0]) {
                        EditWorkoutScreen(workout: $workouts[index], isNewWorkout: false)
                    } else {
                        Text("Workout not found")
                    }
                }
                .navigationBarTitle("Workouts")
                .onAppear(){
                    print("Loading workouts")
                    loadWorkouts { result in
                        switch result {
                        case .success(let fetchedWorkouts):
                            workouts = fetchedWorkouts
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
}


struct EditWorkoutScreen: View {
    @Binding var workout: Workout
    let isNewWorkout: Bool
    @Environment(\.dismiss) var dismiss
    @State private var exerciseToAdd = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(workout.name)
                    .font(.title)
            }

            HStack {
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $workout.activeTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                    
                }
                
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $workout.pauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }
               
            }

            HStack {
                Text("Rounds")
                Picker("Rounds", selection: $workout.rounds){
                    ForEach([1,2,3,4,5], id: \.self) { rounds in
                        Text("\(rounds)").tag(rounds)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack {
                Text("Exercises")
                               List {
                                   ForEach(workout.exercises, id: \.self) { element in
                                       Text(element)
                                        }
                                   }
                               

                               HStack {
                                   TextField("Add Exercise", text: $exerciseToAdd)
                                       .textFieldStyle(RoundedBorderTextFieldStyle())
                                   Button("Add") {
                                       if !exerciseToAdd.isEmpty {
                                           workout.exercises.append(exerciseToAdd)
                                           exerciseToAdd = ""
                                       }
                                   }
                               }
            }
            
            Button("Save") {
                
                saveWorkout(workout: workout) { result in
                                    switch result {
                                    case .success():
                                        dismiss()
                                    case .failure(let error):
                                        print("Error saving workout:", error.localizedDescription)
                                    }
                                }
            }
        }
        .padding()
    }
}

struct WorkoutScreen: View {
    @Binding var workout: Workout
    @State private var audioPlayer: AVAudioPlayer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    @State private var isWorkoutActive = false
    @State private var currentExercise = 0
    @State private var currentRound = 0
    @State private var timeRemaining = 0
    @State private var timeLeft = 0
    
    @State private var localActiveTime = 0
    @State private var localPauseTime = 0
    @State private var localRounds = 0
    
    @State private var startWorkoutQueueItem: DispatchWorkItem?


    
    
    func startWorkout() {
        UIApplication.shared.isIdleTimerDisabled = true // Prevent sleep mode
        isRunning = true
        isWorkoutActive = true
        
        // Announce the first exercise
        
        
        startWorkoutQueueItem = DispatchWorkItem {
                   playTone("start")
                   self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                       self.handleTimerTick()
                   }
               }
        
        if timeLeft == 0 {
            let exerciseName = workout.exercises[currentExercise]
            speak(text: "Starting \(exerciseName)")
            timeRemaining = localActiveTime
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: startWorkoutQueueItem!)
        } else {
            timeRemaining = timeLeft
            timeLeft = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                handleTimerTick()
            }
            
        }
    }
    
    func speakCountdown(for seconds: Int, isActivePhase: Bool) {
        let messages = isActivePhase ? [10:"10 Seconds left",
                                        5: "5",
                                        3: "3",
                                        2: "2",
                                        1: "1"]:[5: "5",
                                                 3: "3",
                                                 2: "2",
                                                 1: "1"]
        
          if let message = messages[seconds] {
              speak(text: message)
          }
      }
    
    func handleTimerTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
    
            speakCountdown(for: timeRemaining, isActivePhase: isWorkoutActive)
            
            } else {
            if isWorkoutActive {
                isWorkoutActive = false
                timeRemaining = localPauseTime
                playTone("end")
                
                currentExercise += 1
                if currentExercise < workout.exercises.count {
                    let nextExercise = workout.exercises[currentExercise]
                    speak(text: "Prepare for \(nextExercise) in 3 seconds")
                } else {
                    currentExercise = 0
                    currentRound += 1
                    if currentRound >= localRounds {
                        playTone("complete")
                        resetWorkout() // Reset once complete
                        return
                    }
                }
            } else {
                isWorkoutActive = true
                timeRemaining = localActiveTime
                playTone("start")
            }
        }
    }
    
    func playTone(_ soundType: String) {
        let soundFiles: [String: String] = [
            "start": "start.mp3",
            "end": "pause.mp3",
            "complete": "complete.mp3"
        ]
        
        if let soundFile = soundFiles[soundType],
           let soundURL = Bundle.main.url(forResource: soundFile, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error playing sound:", error)
            }
        }
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session:", error)
        }
    }
    
    func pauseWorkout() {
        startWorkoutQueueItem?.cancel()
        isRunning = false
        timeLeft = timeRemaining
        timer?.invalidate()
    }

    func resetWorkout() {
        UIApplication.shared.isIdleTimerDisabled = false // Prevent sleep mode

        startWorkoutQueueItem?.cancel()
        timer?.invalidate()
        isRunning = false
        currentExercise = 0
        currentRound = 0
        timeRemaining = localActiveTime
    }
    
    func defaultTimes() {
        setLocalTimes()
    }
    
    func setLocalTimes() {
        localActiveTime = workout.activeTime
        localPauseTime = workout.pauseTime
        localRounds = workout.rounds
    }
    
    var body: some View {
        VStack {
            Text(workout.name).font(.largeTitle)
            Spacer()
            HStack {
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $localActiveTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                    
                }
                
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $localPauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                }
               
            }

            HStack {
                Text("Rounds")
                Picker("Rounds", selection: $localRounds){
                    ForEach([1,2,3,4,5], id: \.self) { rounds in
                        Text("\(rounds)").tag(rounds)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            Spacer()
            
            
            
            Text(isRunning ? "Current Exercise: \(workout.exercises[currentExercise])" :"Next Exercise: \(workout.exercises[currentExercise])").font(.headline)
            Text("Time Remaining").font(.title)
            Text(isRunning ? "\(timeRemaining)" : "\(localActiveTime)").font(.system(size: 80))
            
            HStack {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning ? pauseWorkout() : startWorkout()
                }
                .padding()
                
                Button("Reset") {
                    resetWorkout()
                }
                .padding()
            }
        }
        .onAppear {
            configureAudioSession() // Call the function when the view appears
            setLocalTimes()
                }
        .onDisappear {
                resetWorkout()
                }
    }
}

struct ContentView: View {
    var body: some View {
        StartScreen()
    }
}

#Preview {
    ContentView()
}
