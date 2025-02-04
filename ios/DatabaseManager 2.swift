import Foundation
import SwiftData

class DatabaseManager {
    static let shared = DatabaseManager()
    private let container: ModelContainer
    private let context: ModelContext
    
    private init() {
        do {
            let schema = Schema([
                Exercise.self,
                PracticeSession.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Exercise Methods
    
    func createExercise(from map: [String: Any], completion: @escaping (String) -> Void) {
        let exercise = Exercise.fromMap(map)
        context.insert(exercise)
        
        do {
            try context.save()
            completion(exercise.id)
        } catch {
            print("Failed to save exercise: \(error)")
            completion("")
        }
    }
    
    func getExercise(id: String, completion: @escaping (Exercise?) -> Void) {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.id == id
            }
        )
        
        do {
            let exercises = try context.fetch(descriptor)
            completion(exercises.first)
        } catch {
            print("Failed to fetch exercise: \(error)")
            completion(nil)
        }
    }
    
    func getAllExercises(completion: @escaping ([Exercise]) -> Void) {
        let descriptor = FetchDescriptor<Exercise>()
        
        do {
            let exercises = try context.fetch(descriptor)
            completion(exercises)
        } catch {
            print("Failed to fetch exercises: \(error)")
            completion([])
        }
    }
    
    func updateExercise(from map: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let id = map["id"] as? String else {
            completion(false)
            return
        }
        
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.id == id
            }
        )
        
        do {
            let exercises = try context.fetch(descriptor)
            if let exercise = exercises.first {
                exercise.update(from: map)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to update exercise: \(error)")
            completion(false)
        }
    }
    
    func deleteExercise(id: String, completion: @escaping (Bool) -> Void) {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.id == id
            }
        )
        
        do {
            let exercises = try context.fetch(descriptor)
            if let exercise = exercises.first {
                context.delete(exercise)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to delete exercise: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Practice Session Methods
    
    func createPracticeSession(from map: [String: Any], completion: @escaping (String) -> Void) {
        let session = PracticeSession.fromMap(map)
        context.insert(session)
        
        do {
            try context.save()
            completion(session.id)
        } catch {
            print("Failed to save practice session: \(error)")
            completion("")
        }
    }
    
    func getPracticeSession(id: String, completion: @escaping (PracticeSession?) -> Void) {
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.id == id
            }
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            completion(sessions.first)
        } catch {
            print("Failed to fetch practice session: \(error)")
            completion(nil)
        }
    }
    
    func getAllPracticeSessions(completion: @escaping ([PracticeSession]) -> Void) {
        let descriptor = FetchDescriptor<PracticeSession>()
        
        do {
            let sessions = try context.fetch(descriptor)
            completion(sessions)
        } catch {
            print("Failed to fetch practice sessions: \(error)")
            completion([])
        }
    }
    
    func updatePracticeSession(from map: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let id = map["id"] as? String else {
            completion(false)
            return
        }
        
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.id == id
            }
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            if let session = sessions.first {
                session.update(from: map)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to update practice session: \(error)")
            completion(false)
        }
    }
    
    func deletePracticeSession(id: String, completion: @escaping (Bool) -> Void) {
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.id == id
            }
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            if let session = sessions.first {
                context.delete(session)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to delete practice session: \(error)")
            completion(false)
        }
    }
    
    func findPracticeSessionsByDateRange(start: Date, end: Date, completion: @escaping ([PracticeSession]) -> Void) {
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.startTime >= start && session.endTime <= end
            }
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            completion(sessions)
        } catch {
            print("Failed to fetch practice sessions by date range: \(error)")
            completion([])
        }
    }
    
    func getTotalPracticeDuration(start: Date, end: Date, completion: @escaping (Int) -> Void) {
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.startTime >= start && session.endTime <= end
            }
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            let totalDuration = sessions.reduce(0) { $0 + $1.actualDuration }
            completion(totalDuration)
        } catch {
            print("Failed to calculate total practice duration: \(error)")
            completion(0)
        }
    }
} 