//
//  ProgressView.swift
//  Multiplication Tables
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text("📊")
                                .font(.system(size: 80))

                    Text(appState.localizedString("your_progress", comment: ""))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.primary)
                        }
                        .padding(.top, 20)

                        // Overall stats
                        OverallStatsCard(progress: appState.userProgress, appState: appState)
                            .padding(.horizontal, 20)

                        // Achievements
                        if !appState.userProgress.achievements.isEmpty {
                            AchievementsSection(achievements: appState.userProgress.achievements)
                                .padding(.horizontal, 20)
                        }

                        // Table progress
                        TableProgressSection(progress: appState.userProgress)
                            .padding(.horizontal, 20)
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Overall Stats Card
struct OverallStatsCard: View {
    let progress: UserProgress
    let appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            // Stars with gradient
            HStack(spacing: 12) {
                Text("⭐")
                    .font(.system(size: 48))
                Text("\(progress.stars)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.text)
                Text(appState.localizedString("stars", comment: ""))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(AppPalette.text)
            }

            Divider()
                .background(AppPalette.border)
                .frame(height: 1.5)

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                ProgressStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(progress.totalQuestionsAnswered)",
                    label: "total_questions",
                    color: AppPalette.secondary,
                    appState: appState
                )

                ProgressStatItem(
                    icon: "percent",
                    value: String(format: "%.0f%%", progress.accuracy),
                    label: "accuracy",
                    color: AppPalette.warning,
                    appState: appState
                )

                ProgressStatItem(
                    icon: "flame.fill",
                    value: "\(progress.bestStreak)",
                    label: "best_streak",
                    color: AppPalette.primary,
                    appState: appState
                )

                ProgressStatItem(
                    icon: "book.fill",
                    value: "\(progress.completedTables.count)",
                    label: "tables_mastered",
                    color: AppPalette.info,
                    appState: appState
                )
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppPalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppPalette.border, lineWidth: 1)
        )
    }
}

struct ProgressStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let appState: AppState

    @State private var iconScale = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(color)
                .scaleEffect(iconScale ? 1.1 : 1.0)
                .animation(reduceMotion ? nil : .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: iconScale)

            AnimatedText(text: value)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(AppPalette.text)

            Text(appState.localizedString(label, comment: ""))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppPalette.textMuted)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            iconScale = !reduceMotion
        }
    }
}

// MARK: - Animated Text
struct AnimatedText: View {
    let text: String
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .scaleEffect(appear ? 1.0 : 0.5)
            .opacity(appear ? 1.0 : 0)
            .onAppear {
                if reduceMotion {
                    appear = true
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                        appear = true
                    }
                }
            }
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    let achievements: [Achievement]
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(appState.localizedString("achievements", comment: ""))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: achievement.type.icon)
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(colorForType(achievement.type.color))

            Text(achievement.type.title(appState: appState))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.text)
                .multilineTextAlignment(.center)

            Text(achievement.type.description(appState: appState))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppPalette.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 160)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppPalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorForType(achievement.type.color), lineWidth: 1)
        )
    }

    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "yellow": return AppPalette.warning
        case "orange": return AppPalette.primary
        case "purple": return AppPalette.info
        case "blue": return AppPalette.accent
        case "gold": return AppPalette.warning
        default: return AppPalette.textMuted
        }
    }
}

// MARK: - Table Progress Section
struct TableProgressSection: View {
    let progress: UserProgress
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(appState.localizedString("table_progress", comment: ""))
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(AppPalette.text)

            VStack(spacing: 14) {
                ForEach(Array(progress.tableScores.sorted(by: { $0.key < $1.key })), id: \.key) { table, score in
                    TableProgressRow(table: table, score: score)
                }

                if progress.tableScores.isEmpty {
                    Text(appState.localizedString("no_progress_yet", comment: ""))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppPalette.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 36)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppPalette.border, lineWidth: 1)
            )
        }
    }
}

struct TableProgressRow: View {
    let table: Int
    let score: TableScore
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 15) {
            // Table number
            Text("\(table)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(AppPalette.primary)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(appState.localizedString("table_x", comment: ""))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppPalette.text)

                    Spacer()

                    if score.mastered {
                        HStack(spacing: 5) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppPalette.warning)
                            Text(appState.localizedString("mastered", comment: ""))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppPalette.warning)
                        }
                    }
                }

                // Progress bar with shimmer effect
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(AppPalette.border.opacity(0.7))
                            .frame(height: 8)

                        ProgressBarWithShimmer(
                            width: geometry.size.width * (score.accuracy / 100),
                            height: 8
                        )
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(score.attempts) " + appState.localizedString("attempts", comment: ""))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppPalette.textMuted)

                    Spacer()

                    Text("\(Int(score.accuracy))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.text)
            }
        }
    }
}
}

// MARK: - Progress Bar with Shimmer
struct ProgressBarWithShimmer: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(AppPalette.secondary)
            .frame(width: width, height: height)
    }
}

#Preview {
    NavigationStack {
        ProgressView()
            .environmentObject(AppState())
    }
}
