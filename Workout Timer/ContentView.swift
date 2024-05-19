import SwiftUI
import AVFoundation
import AVFAudio
import UIKit // Required for UIApplication.shared

import FirebaseFirestore
import FirebaseFirestoreSwift

class Set: Identifiable, Hashable, Equatable, Encodable, Decodable {
    var id: UUID
    var name: String
    var exercises: [String] = []
    var activeTime: Int
    var pauseTime: Int
    
    init(id: UUID = UUID(), name: String, exercises: [String], activeTime: Int, pauseTime: Int) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.activeTime = activeTime
        self.pauseTime = pauseTime
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Set, rhs: Set) -> Bool {
        return lhs.id == rhs.id // Equality check based on `UUID`
    }
}

class Workout: Identifiable, Hashable, Equatable, Encodable, Decodable {
    var id: UUID // This field will be used for hashing
    var name: String
    var sets: [UUID: Int]
    var rounds: Int
    
    init(id: UUID = UUID(), name: String, sets: [UUID: Int], rounds: Int) {
        self.id = id
        self.name = name
        self.sets = sets
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

class LocalWorkout: Identifiable, Hashable, Equatable, Encodable, Decodable {
    var id: UUID // This field will be used for hashing
    var name: String
    var sets: [Set: Int] = [:]
    var rounds: Int
    
    init(id: UUID = UUID(), name: String, sets: [Set: Int] = [:], rounds: Int) {
        self.id = id
        self.name = name
        self.sets = sets
        self.rounds = rounds
    }
    
    // Implement the `Hashable` requirements
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique `UUID` to ensure a unique hash
    }
    
    static func ==(lhs: LocalWorkout, rhs: LocalWorkout) -> Bool {
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


// Define a custom SwiftUI cell to represent each workout in the list
struct SetCell: View {
    let set: Set
    let onEdit: () -> Void // Closure for the edit action

    var body: some View {
        HStack {
            Text(set.name) // Workout name
                .font(.headline)
            Spacer()

            HStack{
                    Button(action: onEdit) { // Button for the edit action
                        Image(systemName: "pencil") // Pencil icon for editing
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 20)

                NavigationLink(destination: DoWorkoutScreen(workout: LocalWorkout(name: set.name, sets: [set: 1], rounds: 1), workoutSets: [set], currentSet: set)) { // Navigation to the
                    }
                    .frame(width: 20)
                }
        }
    }
}


struct WorkoutCell: View {
    @State var workout: Workout
    
    var body: some View {
        HStack{
            Text(workout.name)
                .font(.title)
            Spacer()
            NavigationLink(destination: ShowWorkoutScreen(workout: $workout)){
                Text("Show")
            }
            .buttonStyle(.borderedProminent)
        }
        
        .onDisappear(){
            print("Disappear")
            print(workout)
        }
    }
}

struct WelcomeScreen: View {
    
    @State private var workouts: [Workout] = []
    @State private var setLibrary: [Set] = []
        
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Your Workouts")
                    .font(.largeTitle)
                
                List(workouts){ workout in
                        WorkoutCell(workout: workout)
                }
                .listStyle(.plain)
                HStack{
                    NavigationLink(destination: SetListScreen()) {
                        Text("Set Library")
                    }
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: CreateWorkoutScreen()) {  // <-- Move NavigationLink outside
                        Text("Add new Workout")
                    }
                    .padding()
                }
            }
        }
        .onAppear() {
            loadSets { result in
                switch result {
                case .success(let fetchedSets):
                    setLibrary = fetchedSets
                    print(setLibrary)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            
            loadWorkouts { result in
                switch result  {
                case .success(let fetchedWorkouts):
                    workouts = fetchedWorkouts
                    print(workouts)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CreateWorkoutScreen: View {
    @State private var sets: [Set] = []
    @State private var errorMessage: String?
    
    @State private var workoutSetList: [Set] = []
    @State private var newWorkoutName: String = "New Workout"
    @State private var workoutRounds: Int = 1
    @State private var workoutSetDict: [UUID: Int] = [:]
    
    @State private var showNewSetSheet: Bool = false
    @State private var isNewSet: Bool = false
    @State private var newSet: Set = Set(name: "New Set", exercises: [], activeTime: 60, pauseTime: 0)
    
    func saveNewWorkout(name: String, workoutSetDict: [UUID: Int], rounds: Int) {
        let workoutToSave = Workout(name: name, sets: workoutSetDict, rounds: rounds)
        saveWorkout(workout: workoutToSave){ result in
            switch result {
            case .success():
                break
            case .failure(let error):
                print("Error saving workout:", error.localizedDescription)
            }
        }
        
    }

    var body: some View {
    
        NavigationView{
            VStack{
                HStack{
                    TextField(newWorkoutName, text: $newWorkoutName)
                        .font(.largeTitle)
                        .padding()
                    
                    Button("Save"){
                        saveNewWorkout(name: newWorkoutName, workoutSetDict: workoutSetDict, rounds: workoutRounds)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                    Text("Sets in your new Workout")
                    
                
                List(workoutSetList) { set in
                    HStack{
                        Text(set.name)
                            .font(.title)
                            .frame(width: UIScreen.main.bounds.width/4)
                        Spacer()
                        
                        Picker("Rounds", selection: Binding(
                            get: { workoutSetDict[set.id] ?? 1 },
                            set: { workoutSetDict[set.id] = $0 }
                        )){
                            ForEach(1...10, id: \.self) { round in
                                Text("\(round)").tag(round)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: UIScreen.main.bounds.width/3)

    

                        Spacer()
                        Button("Remove"){
                            let index = workoutSetList.firstIndex(of:set)
                            workoutSetList.remove(at: index ?? 0)
                            workoutSetDict[set.id] = nil
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .listStyle(.grouped)
                Text("Workout Rounds:")
                    .font(.callout)
                Picker("Rounds", selection: $workoutRounds){
                    ForEach([1,2,3,4,5], id: \.self) { round in
                        Text("\(round)").tag(round)
                    }
                }
                    .pickerStyle(.segmented)
                Spacer()
                HStack{
                    Text("Set Library")
                    Button("New Set", systemImage: "plus.circle", action: {
                        sets.append(newSet)
                        isNewSet = true
                        showNewSetSheet = true
                        
                        
                    })
                    .labelStyle(.iconOnly)
              
                }
                .sheet(isPresented: $showNewSetSheet) {
                    
                    EditSetScreen(set: $newSet, sets: $sets, isNewSet: $isNewSet)
                 
                }
               
                
                List(sets) {set in
                    HStack{
                        Text(set.name)
                            .font(.title)
                        Spacer()
                        Button("Add"){
                            
                            if workoutSetDict[set.id] == nil {
                                workoutSetList.append(set)
                                workoutSetDict[set.id] = 1
                            } else {
                                
                            }
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .onAppear(){
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

struct ShowWorkoutScreen: View {
    @Binding var workout: Workout
    @State private var setLibrary: [Set] = []
    @State private var workoutSetArray: [Set] = []
    @State private var workoutSetRoundsDict: [Set: Int] = [:]
    
    @State private var errorMessage: String?
    
    // Design Workout Screen
    // Design DoWorkout Screen
    // Handle Storage, Saving and Loading globally
    // split up code in multiple files
    
    
    func matchSetIDsWithSets(workoutDict: [UUID: Int]) -> [Set]{
        let setIDArray = Array(workoutDict.keys)
        let workoutSets = setLibrary.filter { set in
            if workout.sets[set.id] != nil {
                return true
            } else {
                return false
            }
        }
        return workoutSets
    }
    
    func createSetRoundsDict(workoutSetArray: [Set], workoutDict: [UUID: Int]) -> [Set: Int] {
        var workoutSetDict: [Set: Int] = [:]
        for set in workoutSetArray {
            workoutSetDict[set] = workoutDict[set.id]
        }
        return workoutSetDict
    }
    
    var body: some View{
        NavigationView{
            VStack{
                Text(workout.name)
//                List(workoutSetArray){ set in
//                    Text("Hello")
//                    
//                }
                NavigationLink(destination: DoWorkoutScreen(workout: LocalWorkout(name: workout.name, sets: workoutSetRoundsDict ,rounds: workout.rounds), workoutSets: workoutSetArray, currentSet: workoutSetArray.first ?? Set(name: "Default", exercises: [], activeTime: 60, pauseTime: 0))){
                    Text("Start Workout")
                }
            }
            .onAppear(){
                print("hello")
                loadSets { result in
                    switch result {
                    case .success(let fetchedSets):
                        setLibrary = fetchedSets
                        workoutSetArray = matchSetIDsWithSets(workoutDict: workout.sets)
                        workoutSetRoundsDict = createSetRoundsDict(workoutSetArray: workoutSetArray, workoutDict: workout.sets)
                        print("hello")
                        print(workoutSetArray)
                        print(workoutSetRoundsDict)
                    case .failure(let error):
                        
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}


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


struct EditSetScreen: View {
    @Binding var set: Set
    @Binding var sets: [Set]
    @Binding var isNewSet: Bool
    @State private var savedNewSet: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var exerciseToAdd = ""
    @State private var renamingWorkout = false
    
    
    
    var body: some View {
        VStack {
            HStack {
                TextField(set.name, text: $set.name)
                    .font(.largeTitle)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $set.activeTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                    
                }
                
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $set.pauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 75)
                }
                
            }
            
            VStack {
                Text("Exercises")
                List {
                    ForEach(set.exercises, id: \.self) { element in
                        Text(element)
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    TextField("Add Exercise", text: $exerciseToAdd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !exerciseToAdd.isEmpty {
                            set.exercises.append(exerciseToAdd)
                            exerciseToAdd = ""
                        }
                    }
                }
                .padding()
            }
            .padding()
            
            HStack{
                Button("Save") {
                    saveSet(set: set) { result in
                        switch result {
                        case .success():
                            savedNewSet = true
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
            if (isNewSet == true && savedNewSet == false) {
                sets.removeLast()
                isNewSet = false
            }
        }
    }
}

struct DoWorkoutScreen: View {
    @State var workout: LocalWorkout
    @State var workoutSets: [Set]
    @State var currentSet: Set
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    @State private var isSetActive = false
    
    
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
        isSetActive = true
        
        // Announce the first exercise
        
        
        startWorkoutQueueItem = DispatchWorkItem {
                   playTone("start")
                   self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                       self.handleTimerTick()
                   }
               }
        
        if timeLeft == 0 {
            let exerciseName = currentSet.exercises[currentExercise]
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
    
            speakCountdown(for: timeRemaining, isActivePhase: isSetActive)
            
            } else {
            if isSetActive {
                isSetActive = false
                timeRemaining = localPauseTime
                playTone("end")
                
                currentExercise += 1
                if currentExercise < currentSet.exercises.count {
                    let nextExercise = currentSet.exercises[currentExercise]
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
                isSetActive = true
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
        isSetActive = false
        timeLeft = timeRemaining
        timer?.invalidate()
    }

    func resetWorkout() {
        UIApplication.shared.isIdleTimerDisabled = false // Prevent sleep mode

        startWorkoutQueueItem?.cancel()
        timer?.invalidate()
        isRunning = false
        isSetActive = false
        currentExercise = 0
        currentSet = workoutSets[0]
        currentRound = 0
        timeRemaining = localActiveTime
    }
    
    func defaultTimes() {
        updateLocalTimes()
    }
    
    func updateLocalTimes() {
        localActiveTime = currentSet.activeTime
        localPauseTime = currentSet.pauseTime
        localRounds = 1
    }
    
    
    var body: some View {
        VStack {
            Text(workout.name).font(.largeTitle)
            
            List(workoutSets) { set in
                Text(set.name)
            }
            
            Text("Current set: \(currentSet.name)").font(.title)
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
            
            Text(isRunning ? "Current Exercise: \(currentSet.exercises[currentExercise])" :"Next Exercise: \(currentSet.exercises[currentExercise])").font(.headline)
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
        .background(isSetActive ? Color(.systemGreen) : Color(.systemBackground))
        .onAppear {
            configureAudioSession() // Call the function when the view appears
            updateLocalTimes()
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
