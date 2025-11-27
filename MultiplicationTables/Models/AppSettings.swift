//
//  AppSettings.swift
//  Multiplication Tables
//

import Foundation
import SwiftUI

struct AppSettings: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticEnabled: Bool = true
    var maxTableNumber: Int = 10
    var questionsPerSession: Int = 10
    var showTimer: Bool = true
    var difficulty: Difficulty = .normal

    enum Difficulty: String, Codable, CaseIterable {
        case easy
        case normal
        case hard

        var displayName: LocalizedStringKey {
            switch self {
            case .easy: return "difficulty_easy"
            case .normal: return "difficulty_normal"
            case .hard: return "difficulty_hard"
            }
        }

        var timeLimit: TimeInterval? {
            switch self {
            case .easy: return nil
            case .normal: return 15
            case .hard: return 8
            }
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appSettings")
        }
    }

    static func load() -> AppSettings {
        if let data = UserDefaults.standard.data(forKey: "appSettings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return decoded
        }
        return AppSettings()
    }
}
