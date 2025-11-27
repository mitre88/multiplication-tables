//
//  PracticeView.swift
//  Multiplication Tables
//

import SwiftUI

struct PracticeView: View {
    let tableNumber: Int

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: PracticeViewModel

    init(tableNumber: Int) {
        self.tableNumber = tableNumber
        _viewModel = StateObject(wrappedValue: PracticeViewModel(tableNumber: tableNumber))
    }

    var body: some View {
        ZStack {
            AnimatedGradientBackground()

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
                VStack(spacing: 0) {
                    // Top bar with progress and exit
                    TopBar(
                        progress: viewModel.session.progress,
                        correctCount: viewModel.session.correctCount,
                        totalQuestions: viewModel.session.questions.count,
                        onExit: { dismiss() }
                    )

                    Spacer()

                    // Question display
                    if let question = viewModel.currentQuestion {
                        QuestionDisplay(
                            question: question,
                            tableNumber: tableNumber,
                            showFeedback: viewModel.showFeedback,
                            isCorrect: viewModel.lastAnswerCorrect,
                            celebration: viewModel.celebration
                        )
                    }

                    Spacer()

                    // Answer input
                    AnswerInputView(
                        answer: $viewModel.userAnswer,
                        isEnabled: !viewModel.showFeedback,
                        onSubmit: {
                            viewModel.submitAnswer()
                        }
                    )
                    .padding(.bottom, 30)
                }
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

    var currentQuestion: Question? {
        session.currentQuestion
    }

    init(tableNumber: Int) {
        self.session = QuizSession(questions: Question.generate(for: tableNumber, count: 10, randomize: true))
    }

    func submitAnswer() {
        guard let answer = Int(userAnswer), !showFeedback else { return }

        lastAnswerCorrect = session.submitAnswer(answer)
        showFeedback = true

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

        if session.isComplete {
            showResults = true
        }
    }

    func restart() {
        session.reset()
        session.questions = Question.generate(for: session.questions.first?.multiplier ?? 1, count: 10, randomize: true)
        userAnswer = ""
        showFeedback = false
        showResults = false
        celebration = false
    }
}

// MARK: - Top Bar
struct TopBar: View {
    let progress: Double
    let correctCount: Int
    let totalQuestions: Int
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "4ECDC4"))

                    Text("\(correctCount)/\(totalQuestions)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 10)
            .padding(.horizontal)
        }
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

    var body: some View {
        VStack(spacing: 30) {
            // Animated emojis
            if celebration {
                HStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { index in
                        Text(["🎉", "⭐", "🎊", "✨", "🌟"].randomElement()!)
                            .font(.system(size: 40))
                            .offset(y: bounce ? -20 : 0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.5)
                                .delay(Double(index) * 0.05),
                                value: bounce
                            )
                    }
                }
                .onAppear {
                    bounce = true
                }
            }

            // Question card
            VStack(spacing: 20) {
                Text(question.questionText)
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "FFE66D")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    .scaleEffect(bounce ? 1.1 : 1.0)
                    .rotationEffect(.degrees(rotation))

                if showFeedback {
                    FeedbackView(isCorrect: isCorrect, correctAnswer: question.answer)
                } else {
                    Text("=")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
        }
        .onChange(of: celebration) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 360
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
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isCorrect ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))

                Text(isCorrect ? "correct" : "incorrect")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(isCorrect ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))
            }

            if !isCorrect {
                Text("correct_answer_is")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                +
                Text(" \(correctAnswer)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Answer Input View
struct AnswerInputView: View {
    @Binding var answer: String
    let isEnabled: Bool
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Answer display
            HStack(spacing: 15) {
                Text(answer.isEmpty ? "?" : answer)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(minWidth: 100)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    )

                if !answer.isEmpty {
                    Button(action: {
                        answer = ""
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
            }

            // Number pad
            NumberPad(answer: $answer, isEnabled: isEnabled)

            // Submit button
            Button(action: onSubmit) {
                Text("check")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: answer.isEmpty ? [Color.gray, Color.gray.opacity(0.8)] : [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            }
            .disabled(answer.isEmpty || !isEnabled)
            .padding(.horizontal)
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
        VStack(spacing: 12) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 12) {
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
                                .frame(width: 70, height: 70)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
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
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: isPressed ? 2 : 8, y: isPressed ? 1 : 4)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    NavigationStack {
        PracticeView(tableNumber: 7)
            .environmentObject(AppState())
    }
}
