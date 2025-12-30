//
//  MultiplicationTablesApp.swift
//  Multiplication Tables
//
//  A fun and interactive app for kids to learn multiplication tables
//  Created with ❤️
//

import SwiftUI

@main
struct MultiplicationTablesApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var showSplash = true
    @Published var currentLanguage: AppLanguage = .english
    @Published var userProgress = UserProgress.load()
    @Published var settings = AppSettings.load()

    init() {
        loadSettings()
    }

    func loadSettings() {
        // Load from UserDefaults
        if let languageCode = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = AppLanguage(rawValue: languageCode) ?? .english
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
    }
}

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        }
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}

// MARK: - Localization Helper
extension AppState {
    func localizedString(_ key: String, comment: String = "") -> String {
        return NSLocalizedString(key, bundle: currentLanguage.bundle, comment: comment)
    }
}
