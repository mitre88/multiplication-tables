//
//  TableSelectorView.swift
//  Multiplication Tables
//

import SwiftUI

struct TableSelectorView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTable: Int?
    @State private var showPractice = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var availableTables: [Int] {
        Array(0...appState.settings.maxTableNumber)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 28) {
                        VStack(spacing: 12) {
                            Text(appState.localizedString("select_table", comment: ""))
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(AppPalette.primary)

                            Text(appState.localizedString("choose_table_practice", comment: ""))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(AppPalette.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        StatsBar(progress: appState.userProgress, appState: appState)
                            .padding(.horizontal, 20)

                        // Table grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(availableTables.enumerated()), id: \.element) { index, table in
                                TableCard(
                                    table: table,
                                    progress: appState.userProgress.tableScores[table],
                                    index: index
                                ) {
                                    selectedTable = table
                                    showPractice = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Expand range button
                        if appState.settings.maxTableNumber < 100 {
                            ExpandRangeButton {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    appState.settings.maxTableNumber = min(appState.settings.maxTableNumber + 10, 100)
                                    appState.settings.save()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPractice) {
            if let table = selectedTable {
                PracticeView(tableNumber: table, appState: appState)
            }
        }
    }
}

// MARK: - Stats Bar
struct StatsBar: View {
    let progress: UserProgress
    let appState: AppState

    var body: some View {
        HStack(spacing: 16) {
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(progress.completedTables.count)",
                label: "completed",
                color: AppPalette.secondary,
                appState: appState
            )

            StatBadge(
                icon: "percent",
                value: String(format: "%.0f%%", progress.accuracy),
                label: "accuracy",
                color: AppPalette.warning,
                appState: appState
            )

            StatBadge(
                icon: "flame.fill",
                value: "\(progress.streak)",
                label: "streak",
                color: AppPalette.primary,
                appState: appState
            )
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
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let appState: AppState

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.text)

            Text(appState.localizedString(label, comment: ""))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppPalette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Table Card
struct TableCard: View {
    let table: Int
    let progress: TableScore?
    let index: Int
    let action: () -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var appear = false

    private var cardColor: Color {
        AppPalette.tableColors[table % AppPalette.tableColors.count]
    }

    private var animationDelay: Double {
        Double(index % 12) * 0.04
    }

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
            VStack(spacing: 10) {
                // Table number
                Text("\(table)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                // Multiplication symbol
                Text("×")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                // Progress indicator
                if let progress = progress {
                    HStack(spacing: 5) {
                        if progress.mastered {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppPalette.warning)
                        }
                        Text("\(Int(progress.accuracy))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                } else {
                    Text(appState.localizedString("new", comment: ""))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(cardColor)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(appear ? 1.0 : 0.7)
        .opacity(appear ? 1.0 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7).delay(animationDelay), value: appear)
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Expand Range Button
struct ExpandRangeButton: View {
    let action: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                Text(appState.localizedString("unlock_more_tables", comment: ""))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(AppPalette.primary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack {
        TableSelectorView()
            .environmentObject(AppState())
    }
}
