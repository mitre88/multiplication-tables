//
//  ProgressView.swift
//  Multiplication Tables
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            AnimatedGradientBackground()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Text("📊")
                            .font(.system(size: 80))

                        Text("your_progress")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Overall stats
                    OverallStatsCard(progress: appState.userProgress)
                        .padding(.horizontal)

                    // Achievements
                    if !appState.userProgress.achievements.isEmpty {
                        AchievementsSection(achievements: appState.userProgress.achievements)
                            .padding(.horizontal)
                    }

                    // Table progress
                    TableProgressSection(progress: appState.userProgress)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Overall Stats Card
struct OverallStatsCard: View {
    let progress: UserProgress

    var body: some View {
        VStack(spacing: 20) {
            // Stars
            HStack(spacing: 10) {
                Text("⭐")
                    .font(.system(size: 40))
                Text("\(progress.stars)")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("stars")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ProgressStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(progress.totalQuestionsAnswered)",
                    label: "total_questions",
                    color: Color(hex: "4ECDC4")
                )

                ProgressStatItem(
                    icon: "percent",
                    value: String(format: "%.0f%%", progress.accuracy),
                    label: "accuracy",
                    color: Color(hex: "FFB347")
                )

                ProgressStatItem(
                    icon: "flame.fill",
                    value: "\(progress.bestStreak)",
                    label: "best_streak",
                    color: Color(hex: "FF6B9D")
                )

                ProgressStatItem(
                    icon: "book.fill",
                    value: "\(progress.completedTables.count)",
                    label: "tables_mastered",
                    color: Color(hex: "6E8EFB")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
        )
    }
}

struct ProgressStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(NSLocalizedString(label, comment: ""))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    let achievements: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("achievements")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

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

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.type.icon)
                .font(.system(size: 40))
                .foregroundColor(colorForType(achievement.type.color))

            Text(achievement.type.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(achievement.type.description)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 150)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorForType(achievement.type.color), lineWidth: 2)
                )
        )
    }

    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return Color(hex: "C371F4")
        case "blue": return Color(hex: "6E8EFB")
        case "gold": return Color(hex: "FFD700")
        default: return .white
        }
    }
}

// MARK: - Table Progress Section
struct TableProgressSection: View {
    let progress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("table_progress")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(Array(progress.tableScores.sorted(by: { $0.key < $1.key })), id: \.key) { table, score in
                    TableProgressRow(table: table, score: score)
                }

                if progress.tableScores.isEmpty {
                    Text("no_progress_yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
            )
        }
    }
}

struct TableProgressRow: View {
    let table: Int
    let score: TableScore

    var body: some View {
        HStack(spacing: 15) {
            // Table number
            Text("\(table)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF6B9D"), Color(hex: "C371F4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("table_x")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    if score.mastered {
                        HStack(spacing: 5) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            Text("mastered")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (score.accuracy / 100), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(score.attempts) attempts")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Text("\(Int(score.accuracy))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProgressView()
            .environmentObject(AppState())
    }
}
