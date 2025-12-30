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
            AppBackground()

            ScrollView {
                VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text("⚙️")
                                .font(.system(size: 80))

                            Text(appState.localizedString("settings", comment: ""))
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(AppPalette.primary)
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
                                        .foregroundColor(AppPalette.info)
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(appState.localizedString("language", comment: ""))
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(AppPalette.text)

                                        Text(appState.currentLanguage.displayName)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppPalette.textMuted)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppPalette.textMuted)
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
                                    color: AppPalette.warning
                                )

                                Divider()
                                    .background(AppPalette.border)

                                SettingsToggle(
                                    icon: "music.note",
                                    title: "background_music",
                                    isOn: $appState.settings.musicEnabled,
                                    color: AppPalette.primary
                                )

                                Divider()
                                    .background(AppPalette.border)

                                SettingsToggle(
                                    icon: "hand.tap.fill",
                                    title: "haptic_feedback",
                                    isOn: $appState.settings.hapticEnabled,
                                    color: AppPalette.info
                                )
                            }
                        }

                        // Difficulty
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "gauge")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppPalette.secondary)
                                        .frame(width: 40)

                                    Text(appState.localizedString("difficulty", comment: ""))
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppPalette.text)
                                }

                                Picker("", selection: $appState.settings.difficulty) {
                                    ForEach(AppSettings.Difficulty.allCases, id: \.self) { difficulty in
                                        Text(difficulty.displayName(appState: appState))
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
                                        .foregroundColor(AppPalette.secondary)
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(appState.localizedString("max_table_range", comment: ""))
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(AppPalette.text)

                                        Text(appState.localizedString("up_to_table_x", comment: "") + " \(appState.settings.maxTableNumber)")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppPalette.textMuted)
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
                                .tint(AppPalette.secondary)
                            }
                        }

                        Button(action: { showResetAlert = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                Text(appState.localizedString("reset_progress", comment: ""))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppPalette.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal, 20)

                    // App info
                VStack(spacing: 8) {
                        Text(appState.localizedString("app_name_full", comment: "App name"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppPalette.textMuted)

                        Text(appState.localizedString("version", comment: "") + " 1.0.0")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppPalette.textMuted)

                        Text(appState.localizedString("app_dedication", comment: "App dedication"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(AppPalette.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 15)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0)
                .padding(.bottom, 30)
            }
        }
        .alert(Text(appState.localizedString("reset_progress_title", comment: "")), isPresented: $showResetAlert) {
            Button(appState.localizedString("cancel", comment: ""), role: .cancel) { }
            Button(appState.localizedString("reset", comment: ""), role: .destructive) {
                appState.userProgress = UserProgress()
                appState.userProgress.save()
            }
        } message: {
            Text(appState.localizedString("reset_progress_message", comment: ""))
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
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppPalette.border, lineWidth: 1)
            )
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44)

            Text(appState.localizedString(title, comment: ""))
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.text)

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
            AppPalette.background
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Text("🌍")
                        .font(.system(size: 70))

                    Text(appState.localizedString("select_language", comment: ""))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.text)
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
            HStack(spacing: 22) {
                Text(language.flag)
                    .font(.system(size: 44))

                Text(language.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? AppPalette.text : AppPalette.textMuted)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(AppPalette.secondary)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppPalette.surface : AppPalette.surfaceAlt)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppPalette.secondary : AppPalette.border, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
