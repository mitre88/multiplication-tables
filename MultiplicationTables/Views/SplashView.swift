//
//  SplashView.swift
//  Multiplication Tables
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var showStars = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: "FF6B9D"),
                    Color(hex: "C371F4"),
                    Color(hex: "6E8EFB"),
                    Color(hex: "4ECDC4")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated stars
            if showStars {
                ForEach(0..<20, id: \.self) { index in
                    StarView(delay: Double(index) * 0.1)
                }
            }

            VStack(spacing: 30) {
                Spacer()

                // App Logo
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 60,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)

                    // Logo background
                    Circle()
                        .fill(.white)
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)

                    // Logo content
                    VStack(spacing: 5) {
                        Text("✖️")
                            .font(.system(size: 70))
                            .rotationEffect(.degrees(rotation))

                        Text("×")
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B9D"), Color(hex: "C371F4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // App name
                VStack(spacing: 10) {
                    Text("Multiplication")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)

                    Text("Masters")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "FFE66D")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                }
                .opacity(opacity)

                Spacer()

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.bottom, 50)
                    .opacity(opacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }

        // Rotation animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // Show stars
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showStars = true
        }

        // Hide splash after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                appState.showSplash = false
            }
        }
    }
}

// MARK: - Star View Component
struct StarView: View {
    let delay: Double
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0

    private let xPosition = CGFloat.random(in: 50...350)
    private let size = CGFloat.random(in: 20...40)

    var body: some View {
        Text("⭐")
            .font(.system(size: size))
            .offset(x: xPosition - 200, y: yOffset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .delay(delay)
                ) {
                    opacity = 1
                    scale = 1
                    yOffset = -600
                }
            }
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

#Preview {
    SplashView()
        .environmentObject(AppState())
}
