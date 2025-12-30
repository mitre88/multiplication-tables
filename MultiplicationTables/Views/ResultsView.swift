//
//  ResultsView.swift
//  Multiplication Tables
//

import SwiftUI

struct ResultsView: View {
    let session: QuizSession
    let tableNumber: Int
    let onRestart: () -> Void
    let onExit: () -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180

    private var stars: Int {
        let accuracy = session.accuracy
        if accuracy >= 90 { return 3 }
        if accuracy >= 70 { return 2 }
        if accuracy >= 50 { return 1 }
        return 0
    }

    private var message: String {
        let accuracy = session.accuracy
        if accuracy >= 90 { return appState.localizedString("excellent", comment: "") }
        if accuracy >= 70 { return appState.localizedString("great_job", comment: "") }
        if accuracy >= 50 { return appState.localizedString("good_effort", comment: "") }
        return appState.localizedString("keep_practicing", comment: "")
    }

    var body: some View {
        ZStack {
            AppBackground()

            if showConfetti && stars >= 2 && !reduceMotion {
                ConfettiView()
            }

            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 40)

                    // Trophy/Star display
                    VStack(spacing: 20) {
                        Text(stars >= 2 ? "🏆" : "⭐")
                            .font(.system(size: 100))
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotation))

                        Text(message)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(AppPalette.primary)
                            .multilineTextAlignment(.center)

                        // Stars
                        HStack(spacing: 15) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < stars ? "star.fill" : "star")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppPalette.warning)
                            }
                        }
                    }
                    .padding(.vertical)

                    VStack(spacing: 25) {
                        StatRow(
                            icon: "checkmark.circle.fill",
                            label: "correct_answers",
                            value: "\(session.correctCount)/\(session.questions.count)",
                            color: AppPalette.secondary,
                            appState: appState
                        )

                        StatRow(
                            icon: "percent",
                            label: "accuracy",
                            value: String(format: "%.0f%%", session.accuracy),
                            color: AppPalette.warning,
                            appState: appState
                        )

                        StatRow(
                            icon: "clock.fill",
                            label: "time",
                            value: formatTime(session.totalTime),
                            color: AppPalette.info,
                            appState: appState
                        )

                        StatRow(
                            icon: "multiply.circle.fill",
                            label: "table_practiced",
                            value: "\(tableNumber)",
                            color: AppPalette.primary,
                            appState: appState
                        )
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppPalette.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppPalette.border, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: onRestart) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .bold))
                                Text(appState.localizedString("practice_again", comment: ""))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppPalette.primary)
                            .clipShape(Capsule())
                        }

                        Button(action: onExit) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text(appState.localizedString("back_to_menu", comment: ""))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppPalette.info)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                        .frame(height: 30)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        if reduceMotion {
            scale = 1.0
            rotation = 0
            return
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
        }

        if stars >= 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let appState: AppState

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 48)

            VStack(alignment: .leading, spacing: 6) {
                Text(appState.localizedString(label, comment: ""))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppPalette.textMuted)

                Text(value)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.text)
            }

            Spacer()
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(delay: Double(index) * 0.05)
            }
        }
        .ignoresSafeArea()
    }
}

struct ConfettiPiece: View {
    let delay: Double
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    private let colors: [Color] = [
        AppPalette.primary,
        AppPalette.warning,
        AppPalette.secondary,
        AppPalette.info,
        AppPalette.accent,
        AppPalette.tableColors.first ?? AppPalette.primary
    ]

    private let startX = CGFloat.random(in: -200...200)
    private let size = CGFloat.random(in: 8...16)
    private let color: Color

    init(delay: Double) {
        self.delay = delay
        self.color = colors.randomElement()!
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .offset(x: startX + xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: 3)
                    .delay(delay)
                ) {
                    yOffset = 900
                    xOffset = CGFloat.random(in: -50...50)
                    rotation = Double.random(in: 0...720)
                    opacity = 0
                }
            }
    }
}

#Preview {
    ResultsView(
        session: QuizSession(
            questions: Question.generate(for: 5, count: 10, randomize: false),
            currentQuestionIndex: 10,
            correctCount: 8
        ),
        tableNumber: 5,
        onRestart: {},
        onExit: {}
    )
}
