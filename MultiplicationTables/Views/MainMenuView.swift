//
//  MainMenuView.swift
//  Multiplication Tables
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedView: MenuOption? = nil
    @State private var showLanguageSelector = false
    @State private var animateButtons = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: 25) {
                        // Header with logo and stars
                        HeaderView(stars: appState.userProgress.stars)
                            .padding(.top, 20)

                        // Language selector
                        LanguageSelectorButton(showLanguageSelector: $showLanguageSelector)
                            .padding(.horizontal)

                        // Menu buttons
                        VStack(spacing: 20) {
                            MenuButton(
                                title: LocalizedText.practice,
                                subtitle: LocalizedText.practiceSubtitle,
                                icon: "pencil.and.list.clipboard",
                                gradient: [Color(hex: "FF6B9D"), Color(hex: "FF8E8E")],
                                delay: 0
                            ) {
                                selectedView = .practice
                            }

                            MenuButton(
                                title: LocalizedText.challenge,
                                subtitle: LocalizedText.challengeSubtitle,
                                icon: "flame.fill",
                                gradient: [Color(hex: "FFB347"), Color(hex: "FF6B9D")],
                                delay: 0.1
                            ) {
                                selectedView = .challenge
                            }

                            MenuButton(
                                title: LocalizedText.progress,
                                subtitle: LocalizedText.progressSubtitle,
                                icon: "chart.bar.fill",
                                gradient: [Color(hex: "6E8EFB"), Color(hex: "A371F7")],
                                delay: 0.2
                            ) {
                                selectedView = .progress
                            }

                            MenuButton(
                                title: LocalizedText.settings,
                                subtitle: LocalizedText.settingsSubtitle,
                                icon: "gearshape.fill",
                                gradient: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                delay: 0.3
                            ) {
                                selectedView = .settings
                            }
                        }
                        .padding(.horizontal)
                        .offset(y: animateButtons ? 0 : 50)
                        .opacity(animateButtons ? 1 : 0)
                    }
                    .padding(.bottom, 30)
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateButtons = true
            }
        }
    }

    @ViewBuilder
    private func destinationView(for option: MenuOption) -> some View {
        switch option {
        case .practice:
            TableSelectorView()
        case .challenge:
            ChallengeView()
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

    var body: some View {
        VStack(spacing: 15) {
            // Logo
            HStack(spacing: 5) {
                Text("✖️")
                    .font(.system(size: 50))

                VStack(alignment: .leading, spacing: 0) {
                    Text("Multiplication")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Masters")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF6B9D"), Color(hex: "C371F4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }

            // Stars display
            HStack(spacing: 8) {
                Text("⭐")
                    .font(.system(size: 24))
                Text("\(stars)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let delay: Double
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: gradient[0].opacity(0.5), radius: isPressed ? 5 : 15, y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
            HStack {
                Text(appState.currentLanguage.flag)
                    .font(.system(size: 24))
                Text(appState.currentLanguage.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}

// MARK: - Animated Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "FF6B9D"),
                Color(hex: "C371F4"),
                Color(hex: "6E8EFB"),
                Color(hex: "4ECDC4")
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Localized Text Helper
struct LocalizedText {
    static var practice: String {
        NSLocalizedString("practice", comment: "Practice button")
    }
    static var practiceSubtitle: String {
        NSLocalizedString("practice_subtitle", comment: "Practice subtitle")
    }
    static var challenge: String {
        NSLocalizedString("challenge", comment: "Challenge button")
    }
    static var challengeSubtitle: String {
        NSLocalizedString("challenge_subtitle", comment: "Challenge subtitle")
    }
    static var progress: String {
        NSLocalizedString("progress", comment: "Progress button")
    }
    static var progressSubtitle: String {
        NSLocalizedString("progress_subtitle", comment: "Progress subtitle")
    }
    static var settings: String {
        NSLocalizedString("settings", comment: "Settings button")
    }
    static var settingsSubtitle: String {
        NSLocalizedString("settings_subtitle", comment: "Settings subtitle")
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppState())
}
