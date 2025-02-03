import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    private var container: ModelContainer
    private var context: ModelContext
    
    private init() {
        let schema = Schema([
            AppSettings.self,
            Instrument.self,
            Category.self,
            Exercise.self,
            Practice.self
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
    func saveInstrument(_ name: String) async throws -> Instrument {
        let instrument = Instrument(name: name)
        context.insert(instrument)
        try context.save()
        return instrument
    }
    
    func getInstruments() async throws -> [Instrument] {
        let descriptor = FetchDescriptor<Instrument>()
        return try context.fetch(descriptor)
    }
    
    // MARK: - Categories
    func saveCategory(_ name: String) async throws -> Category {
        let category = Category(name: name)
        context.insert(category)
        try context.save()
        return category
    }
    
    func getCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>()
        return try context.fetch(descriptor)
    }
    
    // MARK: - Exercises
    func saveExercise(name: String, exerciseDescription: String, categoryId: String) async throws -> Exercise {
        let exercise = Exercise(name: name, exerciseDescription: exerciseDescription)
        if let category = try await getCategory(id: categoryId) {
            exercise.category = category
        }
        context.insert(exercise)
        try context.save()
        return exercise
    }
    
    func getExercises(categoryId: String? = nil) async throws -> [Exercise] {
        var descriptor = FetchDescriptor<Exercise>()
        if let categoryId = categoryId {
            descriptor.predicate = #Predicate<Exercise> { exercise in
                exercise.category?.id == categoryId
            }
        }
        return try context.fetch(descriptor)
    }
    
    // MARK: - Practices
    func savePractice(exerciseId: String, instrumentId: String, duration: TimeInterval, notes: String?) async throws -> Practice {
        let practice = Practice(duration: duration, notes: notes)
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
    
    func getPractices(exerciseId: String? = nil, instrumentId: String? = nil) async throws -> [Practice] {
        var descriptor = FetchDescriptor<Practice>()
        if let exerciseId = exerciseId {
            descriptor.predicate = #Predicate<Practice> { practice in
                practice.exercise?.id == exerciseId
            }
        } else if let instrumentId = instrumentId {
            descriptor.predicate = #Predicate<Practice> { practice in
                practice.instrument?.id == instrumentId
            }
        }
        return try context.fetch(descriptor)
    }
    
    func getPractices() async throws -> [Practice] {
        let descriptor = FetchDescriptor<Practice>()
        descriptor.sortBy = [SortDescriptor(\Practice.startTime, order: .reverse)]
        return try context.fetch(descriptor)
    }
    
    // MARK: - Helper Methods
    private func getCategory(id: String) async throws -> Category? {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate<Category> { category in
                category.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    private func getExercise(id: String) async throws -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    private func getInstrument(id: String) async throws -> Instrument? {
        let descriptor = FetchDescriptor<Instrument>(
            predicate: #Predicate<Instrument> { instrument in
                instrument.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
} 