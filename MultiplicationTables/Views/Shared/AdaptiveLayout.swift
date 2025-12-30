//
//  AdaptiveLayout.swift
//  Multiplication Tables
//

import SwiftUI

// MARK: - Device Type Detection
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - Adaptive Container
struct AdaptiveContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: 0)
                content
                    .frame(maxWidth: maxContentWidth(for: geometry.size.width))
                Spacer(minLength: 0)
            }
        }
    }

    private func maxContentWidth(for screenWidth: CGFloat) -> CGFloat {
        if UIDevice.isIPad {
            // iPad: Use 70% of screen width, max 800pt
            return min(screenWidth * 0.7, 800)
        } else {
            // iPhone: Use full width with standard padding
            return screenWidth
        }
    }
}

// MARK: - Adaptive Padding
extension View {
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, UIDevice.isIPad ? 40 : 20)
    }

    func adaptiveHorizontalPadding() -> some View {
        self.padding(.horizontal, UIDevice.isIPad ? 40 : 20)
    }
}

// MARK: - Adaptive Frame Modifier
struct AdaptiveFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.isIPad {
            content
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

extension View {
    func adaptiveFrame() -> some View {
        modifier(AdaptiveFrameModifier())
    }
}
