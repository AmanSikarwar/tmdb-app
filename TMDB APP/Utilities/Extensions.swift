//
//  Extensions.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let movieBackground = Color(.systemBackground)
    static let movieSecondaryBackground = Color(.secondarySystemBackground)
    static let movieTertiary = Color(.tertiarySystemBackground)
    
    static let liquidGlassOverlay = Color.white.opacity(0.1)
    static let liquidGlassBorder = Color.white.opacity(0.2)
    static let liquidGlassShadow = Color.black.opacity(0.1)
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    func conditionalModifier<T: ViewModifier>(_ condition: Bool, modifier: T) -> some View {
        Group {
            if condition {
                self.modifier(modifier)
            } else {
                self
            }
        }
    }
}

// MARK: - String Extensions
extension String {
    func truncated(to length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        return self
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let liquidGlass = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let quickBounce = Animation.spring(response: 0.3, dampingFraction: 0.8)
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}