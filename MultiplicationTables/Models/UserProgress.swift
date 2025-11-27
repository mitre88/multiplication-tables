//
//  UserProgress.swift
//  Multiplication Tables
//

import Foundation

struct UserProgress: Codable {
    var completedTables: Set<Int> = []
    var tableScores: [Int: TableScore] = [:] // table number -> score
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var stars: Int = 0
    var achievements: [Achievement] = []
    var lastPlayedDate: Date = Date()

    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestionsAnswered) * 100
    }

    mutating func recordAnswer(table: Int, correct: Bool, timeSpent: TimeInterval) {
        totalQuestionsAnswered += 1

        if correct {
            correctAnswers += 1
            streak += 1
            bestStreak = max(bestStreak, streak)

            // Update table score
            if tableScores[table] == nil {
                tableScores[table] = TableScore(tableNumber: table)
            }
            tableScores[table]?.recordCorrectAnswer(timeSpent: timeSpent)

            // Award stars for milestones
            if totalQuestionsAnswered % 10 == 0 {
                stars += 1
            }
        } else {
            streak = 0
            if tableScores[table] == nil {
                tableScores[table] = TableScore(tableNumber: table)
            }
            tableScores[table]?.recordIncorrectAnswer()
        }

        lastPlayedDate = Date()
        checkAchievements()
    }

    mutating func completeTable(_ table: Int) {
        completedTables.insert(table)
        stars += 5
        checkAchievements()
    }

    private mutating func checkAchievements() {
        // First steps
        if totalQuestionsAnswered >= 10 && !achievements.contains(where: { $0.id == "first_steps" }) {
            achievements.append(Achievement(id: "first_steps", type: .firstSteps))
        }

        // Perfect 10
        if streak >= 10 && !achievements.contains(where: { $0.id == "perfect_10" }) {
            achievements.append(Achievement(id: "perfect_10", type: .perfectTen))
        }

        // Master
        if completedTables.count >= 11 && !achievements.contains(where: { $0.id == "master" }) {
            achievements.append(Achievement(id: "master", type: .master))
        }

        // Speed demon
        let fastAnswers = tableScores.values.filter { $0.averageTime < 3.0 }.count
        if fastAnswers >= 5 && !achievements.contains(where: { $0.id == "speed_demon" }) {
            achievements.append(Achievement(id: "speed_demon", type: .speedDemon))
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "userProgress")
        }
    }

    static func load() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            return decoded
        }
        return UserProgress()
    }
}

struct TableScore: Codable {
    let tableNumber: Int
    var attempts: Int = 0
    var correct: Int = 0
    var totalTime: TimeInterval = 0
    var mastered: Bool = false

    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts) * 100
    }

    var averageTime: TimeInterval {
        guard correct > 0 else { return 0 }
        return totalTime / Double(correct)
    }

    mutating func recordCorrectAnswer(timeSpent: TimeInterval) {
        attempts += 1
        correct += 1
        totalTime += timeSpent

        // Consider mastered if 90% accuracy with 10+ attempts
        if attempts >= 10 && accuracy >= 90 {
            mastered = true
        }
    }

    mutating func recordIncorrectAnswer() {
        attempts += 1
    }
}

struct Achievement: Codable, Identifiable {
    let id: String
    let type: AchievementType
    let dateEarned: Date = Date()

    enum AchievementType: String, Codable {
        case firstSteps
        case perfectTen
        case master
        case speedDemon
        case centurion

        var title: LocalizedStringKey {
            switch self {
            case .firstSteps: return "first_steps_title"
            case .perfectTen: return "perfect_ten_title"
            case .master: return "master_title"
            case .speedDemon: return "speed_demon_title"
            case .centurion: return "centurion_title"
            }
        }

        var description: LocalizedStringKey {
            switch self {
            case .firstSteps: return "first_steps_desc"
            case .perfectTen: return "perfect_ten_desc"
            case .master: return "master_desc"
            case .speedDemon: return "speed_demon_desc"
            case .centurion: return "centurion_desc"
            }
        }

        var icon: String {
            switch self {
            case .firstSteps: return "star.fill"
            case .perfectTen: return "flame.fill"
            case .master: return "crown.fill"
            case .speedDemon: return "bolt.fill"
            case .centurion: return "trophy.fill"
            }
        }

        var color: String {
            switch self {
            case .firstSteps: return "yellow"
            case .perfectTen: return "orange"
            case .master: return "purple"
            case .speedDemon: return "blue"
            case .centurion: return "gold"
            }
        }
    }
}
