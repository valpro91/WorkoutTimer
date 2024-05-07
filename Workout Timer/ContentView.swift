import SwiftUI
import AVFoundation
import AVFAudio


struct Workout: Codable, Identifiable, Hashable {
    var id: UUID // This field will be used for hashing
    var name: String
    var exercises: [String]
    var activeTime: Int
    var pauseTime: Int
    var rounds: Int
    
    // Implement the `Hashable` requirements
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
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
    @State private var workouts: [Workout] = [
        Workout(
            id: UUID(),
            name: "Abs",
            exercises: ["Situps", "Chair Reacher", "Elbows to Knees", "Obliques", "Kicks", "Side Hip Lifts", "Mountainclimbers", "Plank"],
            activeTime: 45,
            pauseTime: 15,
            rounds: 1
        ),
        Workout(
            id: UUID(),
            name: "Back",
            exercises: ["Reachers With Towel", "Supermans", "Reachers", "Lying Jumping Jacks", "Shoulder Lift"],
            activeTime: 60,
            pauseTime: 0,
            rounds: 1
        )
    ]
    

    @State private var selectedWorkout: Workout?
    @State private var showingEditScreen = false

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
                .sheet(item: $selectedWorkout) { workoutToEdit in // Use $selectedWorkout for binding
                    EditWorkoutScreen(workout: .constant(workoutToEdit), isNewWorkout: false)
                    }
                .navigationBarTitle("Workouts")
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
                Text("Name")
                TextField("Workout Name", text: $workout.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Active Time")
                TextField("Active Time", text: Binding(
                    get: { String(workout.activeTime) },
                    set: { workout.activeTime = Int($0) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Pause Time")
                TextField("Pause Time", text: Binding(
                    get: { String(workout.pauseTime) },
                    set: { workout.pauseTime = Int($0) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Rounds")
                TextField("Rounds", text: Binding(
                    get: { String(workout.rounds) },
                    set: { workout.rounds = Int($0) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack {
                Text("Exercises")
                ForEach(workout.exercises.indices, id: \.self) { index in
                    TextField("Exercise \(index + 1)", text: $workout.exercises[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                dismiss() // Go back to the previous screen
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
//        configureAudioSession() // Set up the audio session
      
       
        

        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            playTone("start")
//            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//                handleTimerTick()
//            }
//        }
        
    }
    
    func handleTimerTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
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
            HStack{
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $localActiveTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $localPauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                VStack{
                    Text("Rounds")
                    Picker("Rounds", selection: $localRounds){
                        ForEach(1...10, id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                }
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
