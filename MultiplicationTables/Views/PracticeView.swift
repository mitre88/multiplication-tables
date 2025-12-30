//
//  PracticeView.swift
//  Multiplication Tables
//

import SwiftUI
import UIKit

struct PracticeView: View {
    let tableNumber: Int

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: PracticeViewModel

    init(tableNumber: Int, appState: AppState) {
        self.tableNumber = tableNumber
        _viewModel = StateObject(wrappedValue: PracticeViewModel(tableNumber: tableNumber, appState: appState))
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.showResults {
                ResultsView(
                    session: viewModel.session,
                    tableNumber: tableNumber,
                    onRestart: {
                        viewModel.restart()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                            // Top bar with progress and exit
                            TopBar(
                                progress: viewModel.session.progress,
                                correctCount: viewModel.session.correctCount,
                                totalQuestions: viewModel.session.questions.count,
                                onExit: { dismiss() }
                            )
                            .padding(.top, 10)

                            // Question display
                            if let question = viewModel.currentQuestion {
                                QuestionDisplay(
                                    question: question,
                                    tableNumber: tableNumber,
                                    showFeedback: viewModel.showFeedback,
                                    isCorrect: viewModel.lastAnswerCorrect,
                                    celebration: viewModel.celebration
                                )
                                .padding(.vertical, 10)
                            }

                            // Answer input
                            AnswerInputView(
                                answer: $viewModel.userAnswer,
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
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Practice View Model
class PracticeViewModel: ObservableObject {
    @Published var session: QuizSession
    @Published var userAnswer: String = ""
    @Published var showFeedback = false
    @Published var lastAnswerCorrect = false
    @Published var showResults = false
    @Published var celebration = false

    private let tableNumber: Int
    private let appState: AppState
    private var answerStartTime: Date?

    var currentQuestion: Question? {
        session.currentQuestion
    }

    init(tableNumber: Int, appState: AppState) {
        self.tableNumber = tableNumber
        self.appState = appState
        let questionCount = max(5, appState.settings.questionsPerSession)
        self.session = QuizSession(questions: Question.generate(for: tableNumber, count: questionCount, randomize: true))
        self.answerStartTime = Date()
    }

    func submitAnswer() {
        guard let answer = Int(userAnswer), !showFeedback else { return }

        lastAnswerCorrect = session.submitAnswer(answer)
        showFeedback = true
        triggerHaptic(isCorrect: lastAnswerCorrect)

        // Record progress
        let timeSpent = answerStartTime?.timeIntervalSinceNow ?? 0
        appState.userProgress.recordAnswer(
            table: tableNumber,
            correct: lastAnswerCorrect,
            timeSpent: abs(timeSpent)
        )
        appState.userProgress.save()

        if lastAnswerCorrect {
            celebration = true
            // Play success sound/haptic
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.moveToNext()
        }
    }

    private func moveToNext() {
        showFeedback = false
        celebration = false
        userAnswer = ""
        answerStartTime = Date() // Reset timer for next question

        if session.isComplete {
            // Check if table is mastered
            if let tableScore = appState.userProgress.tableScores[tableNumber],
               tableScore.mastered {
                appState.userProgress.completeTable(tableNumber)
                appState.userProgress.save()
            }
            showResults = true
        }
    }

    func restart() {
        session.reset()
        let questionCount = max(5, appState.settings.questionsPerSession)
        session.questions = Question.generate(for: tableNumber, count: questionCount, randomize: true)
        userAnswer = ""
        showFeedback = false
        showResults = false
        celebration = false
        answerStartTime = Date()
    }

    private func triggerHaptic(isCorrect: Bool) {
        guard appState.settings.hapticEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
    }
}

// MARK: - Top Bar
struct TopBar: View {
    let progress: Double
    let correctCount: Int
    let totalQuestions: Int
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppPalette.text)
                }
                .accessibilityLabel(Text("exit"))

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppPalette.secondary)

                    Text("\(correctCount)/\(totalQuestions)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.text)
                }
                .padding(.horizontal, 16)
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

            GeometryReader { progressGeometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppPalette.border.opacity(0.6))
                        .frame(height: 10)
                        .overlay(
                            Capsule()
                                .stroke(AppPalette.border, lineWidth: 1)
                        )

                    Capsule()
                        .fill(AppPalette.secondary)
                        .frame(width: progressGeometry.size.width * progress, height: 10)
                        .overlay(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Question Display
struct QuestionDisplay: View {
    let question: Question
    let tableNumber: Int
    let showFeedback: Bool
    let isCorrect: Bool
    let celebration: Bool

    @State private var bounce = false
    @State private var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Text(question.questionText)
                    .font(.system(size: 68, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.text)
                    .scaleEffect(bounce ? 1.1 : 1.0)
                    .rotationEffect(.degrees(rotation))

                if showFeedback {
                    FeedbackView(isCorrect: isCorrect, correctAnswer: question.answer)
                } else {
                    Text("=")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.text)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppPalette.border, lineWidth: 1)
            )
        }
        .onChange(of: celebration) { newValue in
            if newValue {
                if reduceMotion {
                    rotation = 0
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        rotation = 360
                    }
                }
            }
        }
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    let isCorrect: Bool
    let correctAnswer: Int

    var body: some View {
        VStack(spacing: 12) {
            // Icon only - no text
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 52))
                .foregroundColor(isCorrect ? AppPalette.secondary : AppPalette.primary)

            // Show correct answer if wrong (number only, no explanatory text)
            if !isCorrect {
                Text("\(correctAnswer)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.primary)
            }
        }
        .transition(.scale.combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(isCorrect ? "correct" : "incorrect"))
        .accessibilityValue(isCorrect ? Text("") : Text("\(correctAnswer)"))
    }
}

// MARK: - Answer Input View
struct AnswerInputView: View {
    @Binding var answer: String
    let isEnabled: Bool
    let onSubmit: () -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var answerScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Text(answer.isEmpty ? "?" : answer)
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(AppPalette.text)
                    .frame(minWidth: 110)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppPalette.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppPalette.border, lineWidth: 1)
                    )
                    .scaleEffect(answerScale)
                    .onChange(of: answer) { _ in
                        guard !reduceMotion else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            answerScale = 1.15
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                answerScale = 1.0
                            }
                        }
                    }

                if !answer.isEmpty {
                    Button(action: {
                        answer = ""
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(AppPalette.text)
                            .padding(14)
                            .background(
                                Circle()
                                    .fill(AppPalette.surface)
                            )
                            .overlay(
                                Circle()
                                    .stroke(AppPalette.border, lineWidth: 1)
                            )
                    }
                    .accessibilityLabel(Text("clear_answer"))
                }
            }

            // Number pad
            NumberPad(answer: $answer, isEnabled: isEnabled)
                .padding(.vertical, 8)

            Button(action: onSubmit) {
                Text(appState.localizedString("check", comment: ""))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(answer.isEmpty || !isEnabled ? AppPalette.textMuted : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(answer.isEmpty || !isEnabled ? AppPalette.border : AppPalette.secondary)
                    )
            }
            .disabled(answer.isEmpty || !isEnabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(answer.isEmpty || !isEnabled ? 0.5 : 1.0)
        }
    }
}

// MARK: - Number Pad
struct NumberPad: View {
    @Binding var answer: String
    let isEnabled: Bool

    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { number in
                        if !number.isEmpty {
                            NumberButton(
                                number: number,
                                isEnabled: isEnabled
                            ) {
                                handleNumberTap(number)
                            }
                        } else {
                            Color.clear
                                .frame(width: 58, height: 58)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func handleNumberTap(_ number: String) {
        guard isEnabled else { return }

        if number == "⌫" {
            if !answer.isEmpty {
                answer.removeLast()
            }
        } else {
            if answer.count < 4 {
                answer += number
            }
        }
    }
}

// MARK: - Number Button
struct NumberButton: View {
    let number: String
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            Text(number)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.text)
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(AppPalette.surface)
                )
                .overlay(
                    Circle()
                        .stroke(AppPalette.border, lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .accessibilityLabel(number == "⌫" ? Text("delete") : Text(number))
    }
}

#Preview {
    let appState = AppState()
    return NavigationStack {
        PracticeView(tableNumber: 7, appState: appState)
            .environmentObject(appState)
    }
}
