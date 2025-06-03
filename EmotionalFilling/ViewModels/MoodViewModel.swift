import Foundation
import SwiftUI

@MainActor
class MoodViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var selectedMood: Mood?
    @Published var comment: String = ""
    @Published var selectedDate: Date = Date()
    
    private let saveKey = "moodEntries"
    
    init() {
        loadEntries()
    }
    
    func saveEntry() {
        guard let mood = selectedMood else { return }
        
        let newEntry = MoodEntry(date: selectedDate, mood: mood, comment: comment.isEmpty ? nil : comment)
        
        // Remove any existing entry for the selected date
        entries.removeAll { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: newEntry.date)
        }
        
        // Add the new entry
        entries.append(newEntry)
        saveEntries()
        
        // Reset for next entry
        selectedMood = nil
        comment = ""
        selectedDate = Date() // Reset to today
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func clearAllData() {
        entries.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    func entriesForMonth(_ date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, equalTo: date, toGranularity: .month)
        }
    }
} 