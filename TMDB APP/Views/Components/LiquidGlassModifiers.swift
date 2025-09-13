//
//  VisualEffectModifiers.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - View Extensions Using Built-in Components Only
extension View {
    func glassMaterial(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    func floatingCard(elevation: CGFloat = 8, cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: elevation, x: 0, y: elevation/2)
    }
    
    func enhancedShimmer() -> some View {
        self
            .overlay {
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .mask(
                        LinearGradient(
                            colors: [.clear, .white, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
            }
            .clipped()
    }
    
}
