import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Mood
    let comment: String?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Mood, comment: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.comment = comment
    }
}

enum Mood: String, Codable, CaseIterable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😞"
    case angry = "😡"
    case love = "😍"
    
    var color: String {
        switch self {
        case .happy: return "moodHappy"
        case .neutral: return "moodNeutral"
        case .sad: return "moodSad"
        case .angry: return "moodAngry"
        case .love: return "moodLove"
        }
    }
} 