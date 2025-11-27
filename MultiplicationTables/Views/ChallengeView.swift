//
//  ChallengeView.swift
//  Multiplication Tables
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChallengeViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AnimatedGradientBackground()

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

    func startChallenge() {
        let tables = Array(selectedTables)
        let questions = Question.generateMixed(from: tables, count: totalQuestions)
        session = QuizSession(questions: questions)
        score = 0
        currentAnswer = ""
        showFeedback = false
        isPlaying = true
        showResults = false

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
              let session = session,
              !showFeedback else { return }

        lastCorrect = session.submitAnswer(answer)
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
}

enum ChallengeDifficulty: String, CaseIterable {
    case easy, normal, hard

    var displayName: String {
        NSLocalizedString("difficulty_\(rawValue)", comment: "")
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
    let onStart: () -> Void

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

                    Text("challenge_mode")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("challenge_description")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Difficulty selector
                VStack(alignment: .leading, spacing: 15) {
                    Text("select_difficulty")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

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
                    Text("select_tables")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0...10, id: \.self) { table in
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
                    Text("start_challenge")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: selectedTables.isEmpty ? [Color.gray, Color.gray.opacity(0.8)] : [Color(hex: "FF6B9D"), Color(hex: "FFB347")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.icon)
                    .font(.system(size: 32))

                Text(difficulty.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
            )
        }
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
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(isSelected ? Color(hex: "4ECDC4") : Color.white.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
        }
    }
}

// MARK: - Challenge Game View
struct ChallengeGameView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Timer and score
            HStack {
                // Time
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 20))
                    Text(timeString(viewModel.timeRemaining))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(viewModel.timeRemaining < 10 ? .red : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                Spacer()

                // Score
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Question
            if let question = viewModel.session?.currentQuestion {
                VStack(spacing: 20) {
                    Text(question.questionText)
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    if viewModel.showFeedback {
                        Image(systemName: viewModel.lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.lastCorrect ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))
                    } else {
                        Text("=")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                )
            }

            Spacer()

            // Answer input
            AnswerInputView(
                answer: $viewModel.currentAnswer,
                isEnabled: !viewModel.showFeedback,
                onSubmit: {
                    viewModel.submitAnswer()
                }
            )
            .padding(.bottom, 30)
        }
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

                Text("challenge_complete")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("final_score")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Text("\(score)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "FFE66D")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Spacer()

            VStack(spacing: 15) {
                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("try_again")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF6B9D"), Color(hex: "FFB347")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }

                Button(action: onExit) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("back_to_menu")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6E8EFB"), Color(hex: "A371F7")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
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
    NavigationStack {
        ChallengeView()
            .environmentObject(AppState())
    }
}
