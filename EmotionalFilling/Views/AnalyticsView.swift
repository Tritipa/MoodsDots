import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private var monthEntries: [MoodEntry] {
        viewModel.entriesForMonth(Date())
            .sorted { $0.date < $1.date }
    }
    
    private var moodCounts: [Mood: Int] {
        Dictionary(grouping: monthEntries, by: { $0.mood })
            .mapValues { $0.count }
    }
    
    private var averageMood: Double {
        guard !monthEntries.isEmpty else { return 0 }
        let total = monthEntries.reduce(0) { $0 + ($1.mood.numericValue) }
        return Double(total) / Double(monthEntries.count)
    }
    
    private var streak: Int {
        let sorted = monthEntries.sorted { $0.date > $1.date }
        guard !sorted.isEmpty else { return 0 }
        var streak = 1
        var prev = sorted.first!.date
        for entry in sorted.dropFirst() {
            if Calendar.current.isDate(entry.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: prev)!) {
                streak += 1
                prev = entry.date
            } else {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.13), Color("moodHappy").opacity(0.10), Color.blue.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Label("Mood Chart", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .padding(.bottom, 4)
                        Chart(monthEntries) { entry in
                            LineMark(
                                x: .value("Day", Calendar.current.component(.day, from: entry.date)),
                                y: .value("Mood", entry.mood.numericValue)
                            )
                            .foregroundStyle(Color(entry.mood.color))
                            .interpolationMethod(.catmullRom)
                            PointMark(
                                x: .value("Day", Calendar.current.component(.day, from: entry.date)),
                                y: .value("Mood", entry.mood.numericValue)
                            )
                            .foregroundStyle(Color(entry.mood.color))
                        }
                        .frame(height: 180)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    HStack(spacing: 16) {
                        StatCard(title: "Avg Mood", value: averageMood > 0 ? Mood.fromNumeric(averageMood).rawValue : "-", color: .blue)
                        StatCard(title: "Streak", value: "\(streak)", color: .orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Breakdown")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 12) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                VStack(spacing: 6) {
                                    Text(mood.rawValue)
                                        .font(.system(size: 28))
                                    Text("\(moodCounts[mood, default: 0])")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(mood.color).opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 12)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
    }
}

private extension Mood {
    var numericValue: Int {
        switch self {
        case .happy: return 5
        case .love: return 4
        case .neutral: return 3
        case .sad: return 2
        case .angry: return 1
        }
    }
    static func fromNumeric(_ value: Double) -> Mood {
        switch value {
        case 4.7...: return .happy
        case 3.7..<4.7: return .love
        case 2.7..<3.7: return .neutral
        case 1.7..<2.7: return .sad
        default: return .angry
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(MoodViewModel())
} 
