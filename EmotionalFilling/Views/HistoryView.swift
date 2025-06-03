import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @State private var selectedDate = Date()
    @State private var showingEntryDetail: MoodEntry?
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.13), Color("moodSad").opacity(0.10), Color.blue.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Month selector
                    HStack {
                        Button {
                            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Text(selectedDate.formatted(.dateTime.month().year()))
                            .font(.title2.bold())
                            .foregroundStyle(LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(maxWidth: .infinity)
                        
                        Button {
                            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar grid
                    VStack {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(daysInWeek, id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(daysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date, entry: entryForDate(date))
                                        .onTapGesture {
                                            if let entry = entryForDate(date) {
                                                showingEntryDetail = entry
                                            }
                                        }
                                } else {
                                    Color.clear.frame(height: 50)
                                }
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
            .sheet(item: $showingEntryDetail) { entry in
                EntryDetailView(entry: entry)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Pad to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func entryForDate(_ date: Date) -> MoodEntry? {
        viewModel.entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
}

struct DayCell: View {
    let date: Date
    let entry: MoodEntry?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14))
                .foregroundColor(.primary)
            if let entry = entry {
                ZStack {
                    Circle()
                        .fill(Color(entry.mood.color).opacity(0.7))
                        .frame(width: 28, height: 28)
                        .shadow(color: Color(entry.mood.color).opacity(0.25), radius: 6, x: 0, y: 2)
                    Text(entry.mood.rawValue)
                        .font(.system(size: 18))
                        .shadow(color: .white.opacity(0.18), radius: 2, x: 0, y: 1)
                }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

struct EntryDetailView: View {
    let entry: MoodEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("moodHappy").opacity(0.13), Color.blue.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(entry.mood.rawValue)
                    .font(.system(size: 60))
                    .shadow(color: Color(entry.mood.color).opacity(0.18), radius: 8, x: 0, y: 4)
                Text(entry.date.formatted(.dateTime.day().month().year()))
                    .font(.headline)
                    .foregroundColor(.secondary)
                if let comment = entry.comment {
                    Text(comment)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(MoodViewModel())
} 