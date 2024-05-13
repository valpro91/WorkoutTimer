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

struct WelcomeScreen: View {
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Hello World")
                NavigationLink(destination: SetListScreen()) {  // <-- Move NavigationLink outside
                    Text("Do Something")
                                
                              }
            }
        }
    }
}

struct CreateWorkoutPlaylistScreen: View {
    @State private var sets: [Workout] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack{
            Text("Here you can create your Full Workout")
        }
        .onAppear(){
            loadWorkouts { result in
                switch result {
                case .success(let fetchedWorkouts):
                    sets = fetchedWorkouts
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
       
}


struct SetListScreen: View {
    @State private var workouts: [Workout] = []
    @State private var selectedWorkout: Workout = Workout(name: "Default", activeTime: 1, pauseTime: 1, rounds: 1)
    
    @State private var showingEditScreen = false
    @State private var isNewWorkout = false
    @State private var errorMessage: String?

        var body: some View {
            NavigationView {
                VStack{
                    List(workouts) { workout in
                        WorkoutCell(
                            workout: workout,
                            onEdit: {
                                
                                selectedWorkout = workout // Store ID
                                showingEditScreen = true
                            
                            }
                        )
                    }
                    .listStyle(.plain)
                    .sheet(isPresented: $showingEditScreen) {
                        
                            EditWorkoutScreen(workout: $selectedWorkout, workouts: $workouts, isNewWorkout: $isNewWorkout)
                     
                    }
                    
                    Button("Add New Workout", systemImage: "plus.circle", action: {
                        let newWorkout = Workout(name: "New Workout", activeTime: 0, pauseTime: 0, rounds: 0)
                        workouts.append(newWorkout)
                        selectedWorkout = newWorkout
                        showingEditScreen = true
                        isNewWorkout = true
                    })
                    .font(.largeTitle)
                    .labelStyle(.iconOnly)
                }
                .navigationBarTitle("Workouts")
                .onAppear(){
                    print("Loading")
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
    @Binding var workouts: [Workout]
    @Binding var isNewWorkout: Bool
    @State private var savedNewWorkout: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var exerciseToAdd = ""
    @State private var renamingWorkout = false
    
    
    
    var body: some View {
        VStack {
            HStack {
                TextField(workout.name, text: $workout.name)
                    .font(.largeTitle)
                    .padding()
            }
            
            Spacer()
            
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
                .listStyle(.plain)
                
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
                .padding()
            }
            .padding()
            
            HStack{
                Button("Save") {
                    saveWorkout(workout: workout) { result in
                        switch result {
                        case .success():
                            savedNewWorkout = true
                            dismiss()
                        case .failure(let error):
                            print("Error saving workout:", error.localizedDescription)
                        }
                    }
                }
            
            }
            .padding()
        }
        .onDisappear(){
            if (isNewWorkout == true && savedNewWorkout == false) {
                workouts.removeLast()
                isNewWorkout = false
            }
        }
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
                    speak(text: "Prepare for \(nextExercise)")
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
        isWorkoutActive = false
        timeLeft = timeRemaining
        timer?.invalidate()
    }

    func resetWorkout() {
        UIApplication.shared.isIdleTimerDisabled = false // Prevent sleep mode

        startWorkoutQueueItem?.cancel()
        timer?.invalidate()
        isRunning = false
        isWorkoutActive = false
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
                .buttonStyle(.borderedProminent)
                .padding()
                
                Button("Reset") {
                    resetWorkout()
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .background(isWorkoutActive ? Color(.systemGreen) : Color(.systemBackground))
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
        WelcomeScreen()
    }
}

#Preview {
    ContentView()
}
