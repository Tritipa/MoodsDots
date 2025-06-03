import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingClearConfirmation = false
    @State private var showingExportSheet = false
    @State private var showingRatingSheet = false
    @AppStorage("userRating") private var userRating: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("moodNeutral").opacity(0.13), Color.blue.opacity(0.10), Color.purple.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    SettingsSectionCard {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .font(.headline)
                    }
                    
                    SettingsSectionCard {
                        Button {
                            showingExportSheet = true
                        } label: {
                            SettingsButtonLabel(title: "Export to PDF", systemImage: "square.and.arrow.up", gradient: [Color.blue, Color.purple])
                        }
                        Divider().padding(.vertical, 2)
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            SettingsButtonLabel(title: "Clear All Data", systemImage: "trash", gradient: [Color.red, Color.orange])
                        }
                    }
                    
                    SettingsSectionCard {
                        Link(destination: URL(string: "https://example.com/privacy")!) {
                            SettingsButtonLabel(title: "Privacy Policy", systemImage: "hand.raised", gradient: [Color.gray, Color.blue])
                        }
                        Divider().padding(.vertical, 2)
                        Button {
                            showingRatingSheet = true
                        } label: {
                            SettingsButtonLabel(title: "Rate App", systemImage: "star", gradient: [Color.yellow, Color.orange])
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 12)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Clear All Data", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("Are you sure you want to delete all your mood entries? This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingRatingSheet) {
                RatingSheet(userRating: $userRating, isPresented: $showingRatingSheet)
            }
        }
    }
}

struct SettingsSectionCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
    }
}

struct SettingsButtonLabel: View {
    let title: String
    let systemImage: String
    let gradient: [Color]
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct RatingSheet: View {
    @Binding var userRating: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How do you rate MoodDots?")
                    .font(.title2.bold())
                    .padding(.top, 24)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= userRating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                userRating = star
                            }
                            .accessibilityLabel("Set rating to \(star) star\(star > 1 ? "s" : "")")
                    }
                }
                .padding(.bottom, 8)
                
                if userRating > 0 {
                    Button {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                        isPresented = false
                    } label: {
                        Text("Rate in App Store")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Rate App")
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

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Export to PDF")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Your mood history will be exported as a PDF document.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Button {
                    // TODO: Implement PDF export
                    dismiss()
                } label: {
                    Text("Export")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
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
    SettingsView()
        .environmentObject(MoodViewModel())
} 