import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingDatePicker = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("moodHappy").opacity(0.18), Color.blue.opacity(0.12), Color.purple.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Date Header with Selection
                    HStack {
                        Text(viewModel.selectedDate.formatted(.dateTime.day().month().year()))
                            .font(.title2.bold())
                            .foregroundStyle(LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading, endPoint: .trailing))
                        Button {
                            showingDatePicker = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    .padding(.top, 8)
                    
                    // Mood Selection
                    VStack(spacing: 16) {
                        Text("How are you feeling today?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 24) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.selectedMood = mood
                                    }
                                } label: {
                                    ZStack {
                                        if viewModel.selectedMood == mood {
                                            Circle()
                                                .fill(LinearGradient(
                                                    colors: [Color(mood.color), Color.blue.opacity(0.3)] ,
                                                    startPoint: .top, endPoint: .bottom))
                                                .frame(width: 60, height: 60)
                                                .shadow(color: Color(mood.color).opacity(0.25), radius: 10, x: 0, y: 4)
                                        }
                                        Text(mood.rawValue)
                                            .font(.system(size: 40))
                                            .scaleEffect(viewModel.selectedMood == mood ? 1.25 : 1)
                                            .opacity(viewModel.selectedMood == mood ? 1 : 0.6)
                                            .animation(.easeInOut, value: viewModel.selectedMood)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Comment Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Describe your day (optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextEditor(text: $viewModel.comment)
                            .frame(height: 100)
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.13), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Save Button
                    Button {
                        viewModel.saveEntry()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: viewModel.selectedMood != nil ? [Color.blue, Color.purple] : [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                    startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: viewModel.selectedMood != nil ? Color.blue.opacity(0.18) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(viewModel.selectedMood == nil)
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 12)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $viewModel.selectedDate, isPresented: $showingDatePicker)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                )
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(MoodViewModel())
} 