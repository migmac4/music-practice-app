import Foundation
import SwiftData

@MainActor
class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var container: ModelContainer
    private var context: ModelContext
    
    private init() {
        let schema = Schema([
            AppSettings.self,
            PracticeInstrument.self,
            PracticeCategory.self,
            PracticeExercise.self,
            PracticeSession.self
        ])
        
        do {
            container = try ModelContainer(for: schema)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Theme Management
    func saveThemeMode(_ isDarkMode: Bool) async throws {
        let descriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(descriptor).first ?? AppSettings(isDarkMode: isDarkMode)
        settings.isDarkMode = isDarkMode
        if settings.modelContext == nil {
            context.insert(settings)
        }
        try context.save()
    }
    
    func getThemeMode() async throws -> Bool {
        let descriptor = FetchDescriptor<AppSettings>()
        return try context.fetch(descriptor).first?.isDarkMode ?? false
    }
    
    // MARK: - Instruments
    func saveInstrument(_ name: String) async throws -> PracticeInstrument {
        let instrument = PracticeInstrument(name: name)
        context.insert(instrument)
        try context.save()
        return instrument
    }
    
    func getInstruments() async throws -> [PracticeInstrument] {
        let descriptor = FetchDescriptor<PracticeInstrument>()
        return try context.fetch(descriptor)
    }
    
    // MARK: - Categories
    func saveCategory(_ name: String, instrumentId: String) async throws -> PracticeCategory {
        let category = PracticeCategory(name: name)
        if let instrument = try await getInstrument(id: instrumentId) {
            category.instrument = instrument
        }
        context.insert(category)
        try context.save()
        return category
    }
    
    func getCategories(instrumentId: String? = nil) async throws -> [PracticeCategory] {
        var descriptor = FetchDescriptor<PracticeCategory>()
        if let instrumentId = instrumentId {
            descriptor.predicate = #Predicate<PracticeCategory> { category in
                category.instrument?.id == instrumentId
            }
        }
        return try context.fetch(descriptor)
    }
    
    // MARK: - Exercises
    func saveExercise(name: String, exerciseDescription: String, categoryId: String) async throws -> PracticeExercise {
        let exercise = PracticeExercise(name: name, exerciseDescription: exerciseDescription)
        if let category = try await getCategory(id: categoryId) {
            exercise.category = category
        }
        context.insert(exercise)
        try context.save()
        return exercise
    }
    
    func getExercises(categoryId: String? = nil) async throws -> [PracticeExercise] {
        var descriptor = FetchDescriptor<PracticeExercise>()
        if let categoryId = categoryId {
            descriptor.predicate = #Predicate<PracticeExercise> { exercise in
                exercise.category?.id == categoryId
            }
        }
        return try context.fetch(descriptor)
    }
    
    // MARK: - Practices
    func savePractice(exerciseId: String, instrumentId: String, duration: TimeInterval, notes: String?) async throws -> PracticeSession {
        let practice = PracticeSession(duration: duration, notes: notes)
        if let exercise = try await getExercise(id: exerciseId) {
            practice.exercise = exercise
        }
        if let instrument = try await getInstrument(id: instrumentId) {
            practice.instrument = instrument
        }
        context.insert(practice)
        try context.save()
        return practice
    }
    
    func getPractices(exerciseId: String? = nil, instrumentId: String? = nil) async throws -> [PracticeSession] {
        var descriptor = FetchDescriptor<PracticeSession>()
        if let exerciseId = exerciseId {
            descriptor.predicate = #Predicate<PracticeSession> { practice in
                practice.exercise?.id == exerciseId
            }
        } else if let instrumentId = instrumentId {
            descriptor.predicate = #Predicate<PracticeSession> { practice in
                practice.instrument?.id == instrumentId
            }
        }
        return try context.fetch(descriptor)
    }
    
    func getPractices() async throws -> [PracticeSession] {
        var descriptor = FetchDescriptor<PracticeSession>()
        descriptor.sortBy = [SortDescriptor(\PracticeSession.startTime, order: .reverse)]
        return try context.fetch(descriptor)
    }
    
    // MARK: - Helper Methods
    private func getCategory(id: String) async throws -> PracticeCategory? {
        let descriptor = FetchDescriptor<PracticeCategory>(
            predicate: #Predicate<PracticeCategory> { category in
                category.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    private func getExercise(id: String) async throws -> PracticeExercise? {
        let descriptor = FetchDescriptor<PracticeExercise>(
            predicate: #Predicate<PracticeExercise> { exercise in
                exercise.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    private func getInstrument(id: String) async throws -> PracticeInstrument? {
        let descriptor = FetchDescriptor<PracticeInstrument>(
            predicate: #Predicate<PracticeInstrument> { instrument in
                instrument.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
} 