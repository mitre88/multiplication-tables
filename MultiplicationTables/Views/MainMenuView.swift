//
//  MainMenuView.swift
//  Multiplication Tables
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedView: MenuOption? = nil
    @State private var showLanguageSelector = false
    @State private var animateButtons = false

    var localizedText: LocalizedText {
        LocalizedText(appState: appState)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                            // Header with logo
                            HeaderView(stars: appState.userProgress.stars)
                                .padding(.top, 16)

                            Text(appState.localizedString("app_tagline", comment: "App tagline"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppPalette.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)

                            // Language selector
                            LanguageSelectorButton(showLanguageSelector: $showLanguageSelector)
                                .padding(.horizontal, 20)

                            VStack(spacing: 16) {
                                MenuButton(
                                    title: localizedText.practice,
                                    subtitle: localizedText.practiceSubtitle,
                                    icon: "pencil.and.list.clipboard",
                                    accentColor: AppPalette.primary,
                                    delay: 0
                                ) {
                                    selectedView = .practice
                                }

                                MenuButton(
                                    title: localizedText.challenge,
                                    subtitle: localizedText.challengeSubtitle,
                                    icon: "flame.fill",
                                    accentColor: AppPalette.warning,
                                    delay: 0.08
                                ) {
                                    selectedView = .challenge
                                }

                                MenuButton(
                                    title: localizedText.progress,
                                    subtitle: localizedText.progressSubtitle,
                                    icon: "chart.bar.fill",
                                    accentColor: AppPalette.secondary,
                                    delay: 0.16
                                ) {
                                    selectedView = .progress
                                }

                                MenuButton(
                                    title: localizedText.settings,
                                    subtitle: localizedText.settingsSubtitle,
                                    icon: "gearshape.fill",
                                    accentColor: AppPalette.info,
                                    delay: 0.24
                                ) {
                                    selectedView = .settings
                                }
                            }
                            .padding(.horizontal, 20)
                            .offset(y: animateButtons ? 0 : 40)
                            .opacity(animateButtons ? 1 : 0)
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0)
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(item: $selectedView) { option in
                destinationView(for: option)
            }
            .sheet(isPresented: $showLanguageSelector) {
                LanguageSelectorSheet()
            }
        }
        .onAppear {
            if reduceMotion {
                animateButtons = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    animateButtons = true
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for option: MenuOption) -> some View {
        switch option {
        case .practice:
            TableSelectorView()
        case .challenge:
            ChallengeView(appState: appState)
        case .progress:
            ProgressView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Menu Option
enum MenuOption: Identifiable {
    case practice, challenge, progress, settings

    var id: String {
        switch self {
        case .practice: return "practice"
        case .challenge: return "challenge"
        case .progress: return "progress"
        case .settings: return "settings"
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let stars: Int
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            // Logo with rotation
            HStack(spacing: 8) {
                Text("×")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.localizedString("app_name_line1", comment: "App name line 1"))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(AppPalette.text)
                    Text(appState.localizedString("app_name_line2", comment: "App name line 2"))
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.primary)
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppPalette.warning)

                Text("\(stars)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppPalette.text)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppPalette.surface)
            .overlay(
                Capsule()
                    .stroke(AppPalette.border, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let delay: Double
    let action: () -> Void

    @State private var isPressed = false
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.text)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppPalette.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppPalette.textMuted.opacity(0.7))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppPalette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(appear ? 1.0 : 0.85)
        .opacity(appear ? 1.0 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: appear)
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Language Selector Button
struct LanguageSelectorButton: View {
    @EnvironmentObject var appState: AppState
    @Binding var showLanguageSelector: Bool

    var body: some View {
        Button(action: {
            showLanguageSelector = true
        }) {
            HStack(spacing: 10) {
                Text(appState.currentLanguage.flag)
                    .font(.system(size: 22))
                Text(appState.currentLanguage.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppPalette.text)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppPalette.textMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppPalette.surface)
            .overlay(
                Capsule()
                    .stroke(AppPalette.border, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .accessibilityHint(Text("change_language"))
    }
}

// MARK: - Localized Text Helper
struct LocalizedText {
    let appState: AppState

    var practice: String {
        appState.localizedString("practice", comment: "Practice button")
    }
    var practiceSubtitle: String {
        appState.localizedString("practice_subtitle", comment: "Practice subtitle")
    }
    var challenge: String {
        appState.localizedString("challenge", comment: "Challenge button")
    }
    var challengeSubtitle: String {
        appState.localizedString("challenge_subtitle", comment: "Challenge subtitle")
    }
    var progress: String {
        appState.localizedString("progress", comment: "Progress button")
    }
    var progressSubtitle: String {
        appState.localizedString("progress_subtitle", comment: "Progress subtitle")
    }
    var settings: String {
        appState.localizedString("settings", comment: "Settings button")
    }
    var settingsSubtitle: String {
        appState.localizedString("settings_subtitle", comment: "Settings subtitle")
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppState())
}
