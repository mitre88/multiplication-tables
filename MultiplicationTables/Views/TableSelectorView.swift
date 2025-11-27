//
//  TableSelectorView.swift
//  Multiplication Tables
//

import SwiftUI

struct TableSelectorView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTable: Int?
    @State private var showPractice = false
    @State private var expandedRange = false

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
            AnimatedGradientBackground()

            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    VStack(spacing: 10) {
                        Text("select_table")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("choose_table_practice")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Quick stats
                    StatsBar(progress: appState.userProgress)
                        .padding(.horizontal)

                    // Table grid
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(availableTables, id: \.self) { table in
                            TableCard(
                                table: table,
                                progress: appState.userProgress.tableScores[table]
                            ) {
                                selectedTable = table
                                showPractice = true
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Expand range button
                    if appState.settings.maxTableNumber < 100 {
                        ExpandRangeButton {
                            withAnimation(.spring()) {
                                appState.settings.maxTableNumber = min(appState.settings.maxTableNumber + 10, 100)
                                appState.settings.save()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPractice) {
            if let table = selectedTable {
                PracticeView(tableNumber: table)
            }
        }
    }
}

// MARK: - Stats Bar
struct StatsBar: View {
    let progress: UserProgress

    var body: some View {
        HStack(spacing: 15) {
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(progress.completedTables.count)",
                label: "completed",
                color: Color(hex: "4ECDC4")
            )

            StatBadge(
                icon: "percent",
                value: String(format: "%.0f%%", progress.accuracy),
                label: "accuracy",
                color: Color(hex: "FFB347")
            )

            StatBadge(
                icon: "flame.fill",
                value: "\(progress.streak)",
                label: "streak",
                color: Color(hex: "FF6B9D")
            )
        }
        .padding(15)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(NSLocalizedString(label, comment: ""))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Table Card
struct TableCard: View {
    let table: Int
    let progress: TableScore?
    let action: () -> Void

    @State private var isPressed = false

    private var cardColor: [Color] {
        let colors: [[Color]] = [
            [Color(hex: "FF6B9D"), Color(hex: "FF8E8E")],
            [Color(hex: "C371F4"), Color(hex: "A371F7")],
            [Color(hex: "6E8EFB"), Color(hex: "5E7FEB")],
            [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
            [Color(hex: "FFB347"), Color(hex: "FFA07A")],
            [Color(hex: "98D8C8"), Color(hex: "6BCB77")],
        ]
        return colors[table % colors.count]
    }

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
            VStack(spacing: 12) {
                // Table number
                Text("\(table)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                // Multiplication symbol
                Text("×")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))

                // Progress indicator
                if let progress = progress {
                    HStack(spacing: 4) {
                        if progress.mastered {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                        Text("\(Int(progress.accuracy))%")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("new")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: cardColor,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: cardColor[0].opacity(0.5), radius: isPressed ? 5 : 10, y: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Expand Range Button
struct ExpandRangeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("unlock_more_tables")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}

#Preview {
    NavigationStack {
        TableSelectorView()
            .environmentObject(AppState())
    }
}
