//
//  ChallengeView.swift
//  Multiplication Tables
//

import SwiftUI
import UIKit

struct ChallengeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ChallengeViewModel
    @Environment(\.dismiss) var dismiss

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: ChallengeViewModel(appState: appState))
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.isPlaying {
                ChallengeGameView(viewModel: viewModel)
            } else if viewModel.showResults {
                ChallengeResultsView(
                    score: viewModel.score,
                    totalQuestions: viewModel.totalQuestions,
                    onRestart: {
                        viewModel.startChallenge()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            } else {
                ChallengeSetupView(
                    selectedTables: $viewModel.selectedTables,
                    difficulty: $viewModel.difficulty,
                    maxTableNumber: appState.settings.maxTableNumber,
                    onStart: {
                        viewModel.startChallenge()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(viewModel.isPlaying)
    }
}

// MARK: - Challenge View Model
class ChallengeViewModel: ObservableObject {
    @Published var selectedTables: Set<Int> = [2, 3, 4, 5]
    @Published var difficulty: ChallengeDifficulty = .normal
    @Published var isPlaying = false
    @Published var showResults = false

    @Published var session: QuizSession?
    @Published var currentAnswer = ""
    @Published var score = 0
    @Published var totalQuestions = 20
    @Published var timeRemaining: TimeInterval = 60
    @Published var showFeedback = false
    @Published var lastCorrect = false

    private var timer: Timer?
    private var answerStartTime: Date?
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func startChallenge() {
        let tables = Array(selectedTables)
        let questions = Question.generateMixed(from: tables, count: totalQuestions)
        session = QuizSession(questions: questions)
        score = 0
        currentAnswer = ""
        showFeedback = false
        isPlaying = true
        showResults = false
        answerStartTime = Date()

        switch difficulty {
        case .easy:
            timeRemaining = 120
        case .normal:
            timeRemaining = 60
        case .hard:
            timeRemaining = 30
        }

        startTimer()
    }

    func submitAnswer() {
        guard let answer = Int(currentAnswer),
              !showFeedback else { return }

        guard var sessionCopy = session,
              let currentQ = sessionCopy.currentQuestion else { return }

        lastCorrect = sessionCopy.submitAnswer(answer)
        session = sessionCopy
        triggerHaptic(isCorrect: lastCorrect)

        // Record progress for each table in the question
        let timeSpent = answerStartTime?.timeIntervalSinceNow ?? 0
        let table = currentQ.multiplier
        appState.userProgress.recordAnswer(
            table: table,
            correct: lastCorrect,
            timeSpent: abs(timeSpent)
        )
        appState.userProgress.save()

        if lastCorrect {
            score += 10
        }

        showFeedback = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.moveToNext()
        }
    }

    private func moveToNext() {
        showFeedback = false
        currentAnswer = ""
        answerStartTime = Date() // Reset timer for next question

        if session?.isComplete == true || timeRemaining <= 0 {
            endChallenge()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endChallenge()
            }
        }
    }

    private func endChallenge() {
        timer?.invalidate()
        isPlaying = false
        showResults = true
    }

    private func triggerHaptic(isCorrect: Bool) {
        guard appState.settings.hapticEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
    }
}

enum ChallengeDifficulty: String, CaseIterable {
    case easy, normal, hard

    func displayName(appState: AppState) -> String {
        appState.localizedString("difficulty_\(rawValue)", comment: "")
    }

    var icon: String {
        switch self {
        case .easy: return "🐢"
        case .normal: return "🚀"
        case .hard: return "⚡"
        }
    }
}

// MARK: - Challenge Setup View
struct ChallengeSetupView: View {
    @Binding var selectedTables: Set<Int>
    @Binding var difficulty: ChallengeDifficulty
    let maxTableNumber: Int
    let onStart: () -> Void
    @EnvironmentObject var appState: AppState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Text("🔥")
                        .font(.system(size: 80))

                    Text(appState.localizedString("challenge_mode", comment: ""))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.primary)

                    Text(appState.localizedString("challenge_description", comment: ""))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppPalette.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Difficulty selector
                VStack(alignment: .leading, spacing: 15) {
                    Text(appState.localizedString("select_difficulty", comment: ""))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.text)

                    HStack(spacing: 15) {
                        ForEach(ChallengeDifficulty.allCases, id: \.self) { diff in
                            DifficultyButton(
                                difficulty: diff,
                                isSelected: difficulty == diff
                            ) {
                                difficulty = diff
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Table selector
                VStack(alignment: .leading, spacing: 15) {
                    Text(appState.localizedString("select_tables", comment: ""))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.text)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0...maxTableNumber, id: \.self) { table in
                            TableToggle(
                                table: table,
                                isSelected: selectedTables.contains(table)
                            ) {
                                if selectedTables.contains(table) {
                                    selectedTables.remove(table)
                                } else {
                                    selectedTables.insert(table)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Start button
                Button(action: onStart) {
                    Text(appState.localizedString("start_challenge", comment: ""))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(selectedTables.isEmpty ? AppPalette.textMuted : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedTables.isEmpty ? AppPalette.border : AppPalette.primary)
                        .clipShape(Capsule())
                }
                .disabled(selectedTables.isEmpty)
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let difficulty: ChallengeDifficulty
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(difficulty.icon)
                    .font(.system(size: 36))

                Text(difficulty.displayName(appState: appState))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? AppPalette.text : AppPalette.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? AppPalette.surface : AppPalette.surfaceAlt)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppPalette.primary : AppPalette.border, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Table Toggle
struct TableToggle: View {
    let table: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(table)")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(isSelected ? .white : AppPalette.text)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(isSelected ? AppPalette.secondary : AppPalette.surface)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? AppPalette.secondary : AppPalette.border, lineWidth: 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Challenge Game View
struct ChallengeGameView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    HStack {
                        // Time
                        HStack(spacing: 10) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppPalette.warning)
                            Text(timeString(viewModel.timeRemaining))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(AppPalette.text)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppPalette.surface)
                        )
                        .overlay(
                            Capsule()
                                .stroke(AppPalette.border, lineWidth: 1)
                        )

                        Spacer()

                        // Score
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppPalette.warning)
                            Text("\(viewModel.score)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(AppPalette.text)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppPalette.surface)
                        )
                        .overlay(
                            Capsule()
                                .stroke(AppPalette.border, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    if let question = viewModel.session?.currentQuestion {
                        VStack(spacing: 15) {
                            Text(question.questionText)
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(AppPalette.text)

                            if viewModel.showFeedback {
                                Image(systemName: viewModel.lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 48, weight: .semibold))
                                    .foregroundColor(viewModel.lastCorrect ? AppPalette.secondary : AppPalette.primary)
                            } else {
                                Text("=")
                                    .font(.system(size: 54, weight: .black, design: .rounded))
                                    .foregroundColor(AppPalette.text)
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
                        .padding(.vertical, 10)
                    }

                    // Answer input
                    AnswerInputView(
                        answer: $viewModel.currentAnswer,
                        isEnabled: !viewModel.showFeedback,
                        onSubmit: {
                            viewModel.submitAnswer()
                        }
                    )
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Challenge Results View
struct ChallengeResultsView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    @EnvironmentObject var appState: AppState

    @State private var scale: CGFloat = 0.5

    private var medal: String {
        let percentage = Double(score) / Double(totalQuestions * 10) * 100
        if percentage >= 80 { return "🥇" }
        if percentage >= 60 { return "🥈" }
        if percentage >= 40 { return "🥉" }
        return "🏅"
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 20) {
                Text(medal)
                    .font(.system(size: 100))
                    .scaleEffect(scale)

                Text(appState.localizedString("challenge_complete", comment: ""))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.primary)

                Text(appState.localizedString("final_score", comment: ""))
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(AppPalette.textMuted)

                Text("\(score)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.text)
            }

            Spacer()

            VStack(spacing: 15) {
                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(appState.localizedString("try_again", comment: ""))
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppPalette.primary)
                    .clipShape(Capsule())
                }

                Button(action: onExit) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text(appState.localizedString("back_to_menu", comment: ""))
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppPalette.info)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
    }
}

#Preview {
    let appState = AppState()
    return NavigationStack {
        ChallengeView(appState: appState)
            .environmentObject(appState)
    }
}
