//
//  ContentView.swift
//  Multiplication Tables
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if appState.showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainMenuView()
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: appState.showSplash)
        .environment(\.locale, Locale(identifier: appState.currentLanguage.rawValue))
        .id(appState.currentLanguage.rawValue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
