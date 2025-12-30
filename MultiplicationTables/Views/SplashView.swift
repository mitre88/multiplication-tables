//
//  SplashView.swift
//  Multiplication Tables
//

import SwiftUI
import UIKit

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var logoScale: CGFloat = 0.92
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppPalette.surface)
                        .overlay(
                            Circle()
                                .stroke(AppPalette.border, lineWidth: 2)
                        )

                    Text("×")
                        .font(.system(size: 120, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.primary)
                }
                .frame(width: 220, height: 220)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 4) {
                    Text(appState.localizedString("app_name_line1", comment: "App name line 1"))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(AppPalette.text)

                    Text(appState.localizedString("app_name_line2", comment: "App name line 2"))
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(AppPalette.primary)

                    Text(appState.localizedString("app_tagline", comment: "App tagline"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppPalette.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.horizontal, 24)
                }
                .opacity(logoOpacity)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            startFlatAnimations()
        }
    }

    private func startFlatAnimations() {
        guard !reduceMotion else {
            logoScale = 1.0
            logoOpacity = 1.0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                appState.showSplash = false
            }
            return
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            appState.showSplash = false
        }
    }
}

// MARK: - Flat Background
struct AppBackground: View {
    var body: some View {
        ZStack {
            AppPalette.background

            RoundedRectangle(cornerRadius: 48)
                .fill(AppPalette.surfaceAlt.opacity(0.7))
                .frame(width: 260, height: 260)
                .offset(x: -140, y: -220)

            Circle()
                .fill(AppPalette.accent.opacity(0.08))
                .frame(width: 220, height: 220)
                .offset(x: 160, y: -160)

            RoundedRectangle(cornerRadius: 36)
                .fill(AppPalette.primary.opacity(0.08))
                .frame(width: 280, height: 180)
                .offset(x: 120, y: 240)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum AppPalette {
    static let background = dynamicColor(light: "F7F4EF", dark: "1B1A17")
    static let surface = dynamicColor(light: "FFFFFF", dark: "262420")
    static let surfaceAlt = dynamicColor(light: "F1EAE2", dark: "2F2C27")
    static let border = dynamicColor(light: "E6DDD3", dark: "3A3630")
    static let primary = Color(hex: "E76F51")
    static let secondary = Color(hex: "2A9D8F")
    static let accent = Color(hex: "2E86AB")
    static let warning = Color(hex: "F4A261")
    static let info = Color(hex: "3D5A80")
    static let text = dynamicColor(light: "1F1A16", dark: "F6F1EB")
    static let textMuted = dynamicColor(light: "6B625A", dark: "C4BBB1")

    static let tableColors: [Color] = [
        Color(hex: "D75A4A"),
        Color(hex: "2A9D8F"),
        Color(hex: "2E86AB"),
        Color(hex: "F08A4B"),
        Color(hex: "C0862B"),
        Color(hex: "6B8F71")
    ]

    private static func dynamicColor(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(hex: hex) ?? .clear
        })
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
