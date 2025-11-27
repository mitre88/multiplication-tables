//
//  ContentView.swift
//  Multiplication Tables
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

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
        .animation(.easeInOut(duration: 0.5), value: appState.showSplash)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
