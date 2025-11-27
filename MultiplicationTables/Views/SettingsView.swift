//
//  SettingsView.swift
//  Multiplication Tables
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showResetAlert = false
    @State private var showLanguageSheet = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Text("⚙️")
                            .font(.system(size: 80))

                        Text("settings")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Settings sections
                    VStack(spacing: 20) {
                        // Language
                        SettingsCard {
                            Button(action: { showLanguageSheet = true }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "6E8EFB"))
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("language")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)

                                        Text(appState.currentLanguage.displayName)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                        }

                        // Sound & Haptics
                        SettingsCard {
                            VStack(spacing: 20) {
                                SettingsToggle(
                                    icon: "speaker.wave.3.fill",
                                    title: "sound_effects",
                                    isOn: $appState.settings.soundEnabled,
                                    color: Color(hex: "FFB347")
                                )

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                SettingsToggle(
                                    icon: "music.note",
                                    title: "background_music",
                                    isOn: $appState.settings.musicEnabled,
                                    color: Color(hex: "FF6B9D")
                                )

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                SettingsToggle(
                                    icon: "hand.tap.fill",
                                    title: "haptic_feedback",
                                    isOn: $appState.settings.hapticEnabled,
                                    color: Color(hex: "C371F4")
                                )
                            }
                        }

                        // Difficulty
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "gauge")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "4ECDC4"))
                                        .frame(width: 40)

                                    Text("difficulty")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }

                                Picker("", selection: $appState.settings.difficulty) {
                                    ForEach(AppSettings.Difficulty.allCases, id: \.self) { difficulty in
                                        Text(difficulty.displayName)
                                            .tag(difficulty)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }

                        // Max table range
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "number.square.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "98D8C8"))
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("max_table_range")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)

                                        Text("up_to_table_x \(appState.settings.maxTableNumber)")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                Slider(
                                    value: Binding(
                                        get: { Double(appState.settings.maxTableNumber) },
                                        set: { appState.settings.maxTableNumber = Int($0) }
                                    ),
                                    in: 10...100,
                                    step: 10
                                )
                                .tint(Color(hex: "98D8C8"))
                            }
                        }

                        // Reset progress
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.system(size: 24))
                                Text("reset_progress")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        }
                    }
                    .padding(.horizontal)

                    // App info
                    VStack(spacing: 8) {
                        Text("Multiplication Masters")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .alert("reset_progress_title", isPresented: $showResetAlert) {
            Button("cancel", role: .cancel) { }
            Button("reset", role: .destructive) {
                appState.userProgress = UserProgress()
                appState.userProgress.save()
            }
        } message: {
            Text("reset_progress_message")
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguageSelectorSheet()
        }
        .onChange(of: appState.settings) { _ in
            appState.settings.save()
        }
    }
}

// MARK: - Settings Card
struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
            )
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            Text(NSLocalizedString(title, comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(color)
        }
    }
}

// MARK: - Language Selector Sheet
struct LanguageSelectorSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "FF6B9D"),
                    Color(hex: "C371F4"),
                    Color(hex: "6E8EFB")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Text("🌍")
                        .font(.system(size: 70))

                    Text("select_language")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                // Language options
                VStack(spacing: 15) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        LanguageOption(
                            language: language,
                            isSelected: appState.currentLanguage == language
                        ) {
                            appState.currentLanguage = language
                            appState.saveSettings()
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
    }
}

struct LanguageOption: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Text(language.flag)
                    .font(.system(size: 40))

                Text(language.displayName)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "4ECDC4"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
