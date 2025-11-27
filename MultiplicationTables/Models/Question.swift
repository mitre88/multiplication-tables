//
//  Question.swift
//  Multiplication Tables
//

import Foundation

struct Question: Identifiable, Equatable {
    let id = UUID()
    let multiplier: Int
    let multiplicand: Int
    let startTime: Date = Date()

    var answer: Int {
        multiplier * multiplicand
    }

    var questionText: String {
        "\(multiplier) × \(multiplicand)"
    }

    static func generate(for table: Int, count: Int = 10, randomize: Bool = true) -> [Question] {
        var questions: [Question] = []

        if randomize {
            // Generate random questions from the table
            let range = 0...10
            var used: Set<Int> = []

            while questions.count < count {
                let num = Int.random(in: range)
                if !used.contains(num) {
                    questions.append(Question(multiplier: table, multiplicand: num))
                    used.insert(num)
                }
            }
        } else {
            // Generate sequential questions (0 to 10)
            for i in 0...min(10, count - 1) {
                questions.append(Question(multiplier: table, multiplicand: i))
            }
        }

        return questions
    }

    static func generateMixed(from tables: [Int], count: Int = 10) -> [Question] {
        var questions: [Question] = []
        let multiplicands = Array(0...10)

        for _ in 0..<count {
            let table = tables.randomElement() ?? 1
            let num = multiplicands.randomElement() ?? 0
            questions.append(Question(multiplier: table, multiplicand: num))
        }

        return questions.shuffled()
    }

    func timeElapsed() -> TimeInterval {
        Date().timeIntervalSince(startTime)
    }
}

struct QuizSession {
    var questions: [Question]
    var currentQuestionIndex: Int = 0
    var answers: [UUID: Int] = [:]
    var correctCount: Int = 0
    var startTime: Date = Date()

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var isComplete: Bool {
        currentQuestionIndex >= questions.count
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var accuracy: Double {
        guard currentQuestionIndex > 0 else { return 0 }
        return Double(correctCount) / Double(currentQuestionIndex) * 100
    }

    var totalTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    mutating func submitAnswer(_ answer: Int) -> Bool {
        guard let question = currentQuestion else { return false }

        answers[question.id] = answer
        let isCorrect = answer == question.answer

        if isCorrect {
            correctCount += 1
        }

        currentQuestionIndex += 1
        return isCorrect
    }

    mutating func reset() {
        currentQuestionIndex = 0
        answers = [:]
        correctCount = 0
        startTime = Date()
    }
}
