//
//  LiquidGlassTabBar.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Tab Item
struct TabItem {
    let id: String
    let icon: String
    let iconFilled: String
    let title: String
    let accessibilityLabel: String?
    let badge: Int?
    
    init(id: String, icon: String, iconFilled: String, title: String, accessibilityLabel: String? = nil, badge: Int? = nil) {
        self.id = id
        self.icon = icon
        self.iconFilled = iconFilled
        self.title = title
        self.accessibilityLabel = accessibilityLabel ?? title
        self.badge = badge
    }
}

// MARK: - Liquid Glass Tab Bar
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: String
    let tabs: [TabItem]
    let isMinimized: Bool
    
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var tabAnimation
    @State private var dragOffset: CGFloat = 0
    @State private var showHoverEffect: Bool = false
    
    init(selectedTab: Binding<String>, tabs: [TabItem], isMinimized: Bool = false) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.isMinimized = isMinimized
    }
    
    var body: some View {
        if isMinimized {
            minimizedTabBar
        } else {
            fullTabBar
        }
    }
    
    // MARK: - Full Tab Bar
    private var fullTabBar: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.id) { tab in
                LiquidGlassTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab.id,
                    namespace: tabAnimation,
                    reduceMotion: reduceMotion,
                    showHoverEffect: showHoverEffect
                ) {
                    selectTab(tab.id)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            liquidGlassBackground
        }
        .overlay {
            if !reduceTransparency && showHoverEffect {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.3),
                                Color.accentColor.opacity(0.1),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .animation(.easeInOut(duration: 0.3), value: showHoverEffect)
            }
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !reduceMotion {
                        dragOffset = min(value.translation.height * 0.3, 20)
                        showHoverEffect = abs(value.translation.height) > 10
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        dragOffset = 0
                        showHoverEffect = false
                    }
                }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Minimized Tab Bar
    private var minimizedTabBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                if let selectedTabItem = tabs.first(where: { $0.id == selectedTab }) {
                    Image(systemName: selectedTabItem.iconFilled)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(selectedTabItem.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(Color.accentColor.gradient)
                    .glassEffect(.regular.interactive())
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(tabs.filter { $0.id != selectedTab }.prefix(2), id: \.id) { tab in
                    Button {
                        selectTab(tab.id)
                    } label: {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(.thinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Liquid Glass Background
    private var liquidGlassBackground: some View {
        ZStack {
            if reduceTransparency {
                // Accessibility fallback
                RoundedRectangle(cornerRadius: 28)
                    .fill(.background.opacity(0.95))
                    .stroke(.separator.opacity(0.3), lineWidth: 0.5)
            } else {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.clear)
                    .glassEffect(.regular)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
        }
        .shadow(
            color: .black.opacity(reduceTransparency ? 0.1 : 0.15),
            radius: reduceTransparency ? 8 : 24,
            x: 0,
            y: reduceTransparency ? 4 : 12
        )
    }
    
    // MARK: - Tab Selection
    private func selectTab(_ tabId: String) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(
            reduceMotion ? 
                .linear(duration: 0.2) : 
                .spring(response: 0.4, dampingFraction: 0.75)
        ) {
            selectedTab = tabId
        }
    }
}

// MARK: - Liquid Glass Tab Button
struct LiquidGlassTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let reduceMotion: Bool
    let showHoverEffect: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseEffect = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        selectionBackground
                    }
                    
                    iconView
                    
                    if let badge = tab.badge, badge > 0 {
                        badgeView(count: badge)
                    }
                }
                .frame(width: 44, height: 44)
                
                titleView
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .scaleEffect(pulseEffect ? 1.05 : 1.0)
            .animation(
                reduceMotion ? 
                    .linear(duration: 0.1) : 
                    .spring(response: 0.3, dampingFraction: 0.6), 
                value: isPressed
            )
            .animation(
                reduceMotion ? 
                    .linear(duration: 0.2) : 
                    .spring(response: 0.4, dampingFraction: 0.7), 
                value: isSelected
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.accessibilityLabel ?? tab.title)
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onChange(of: isSelected) { _, newValue in
            if newValue && !reduceMotion {
                triggerPulseEffect()
            }
        }
    }
    
    // MARK: - Selection Background
    private var selectionBackground: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.gradient)
                .glassEffect(.regular.interactive())
                .matchedGeometryEffect(id: "selectedTab", in: namespace)
            
            if showHoverEffect && !reduceMotion {
                Circle()
                    .fill(Color.accentColor.opacity(0.3))
                    .scaleEffect(1.2)
                    .blur(radius: 8)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showHoverEffect)
            }
        }
    }
    
    // MARK: - Icon View
    private var iconView: some View {
        Image(systemName: isSelected ? tab.iconFilled : tab.icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(isSelected ? .white : .primary)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .symbolEffect(
                .bounce.down,
                options: reduceMotion ? .nonRepeating.speed(0) : .default,
                value: isSelected
            )
            .symbolEffect(
                .pulse,
                options: reduceMotion ? .nonRepeating.speed(0) : .repeating,
                value: pulseEffect
            )
    }
    
    // MARK: - Badge View
    private func badgeView(count: Int) -> some View {
        Text("\(min(count, 99))")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .frame(minWidth: 16, minHeight: 16)
            .background(.red.gradient, in: Circle())
            .glassEffect(.regular)
            .offset(x: 18, y: -18)
            .scaleEffect(pulseEffect ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pulseEffect)
    }
    
    // MARK: - Title View
    private var titleView: some View {
        Text(tab.title)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .opacity(isSelected ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Effects
    private func triggerPulseEffect() {
        pulseEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseEffect = false
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedTab = "discover"
    let tabs = [
        TabItem(id: "discover", icon: "film", iconFilled: "film.fill", title: "Discover"),
        TabItem(id: "search", icon: "magnifyingglass", iconFilled: "magnifyingglass", title: "Search"),
        TabItem(id: "watchlist", icon: "bookmark", iconFilled: "bookmark.fill", title: "Watchlist", badge: 3),
        TabItem(id: "profile", icon: "person", iconFilled: "person.fill", title: "Profile")
    ]
    
    return VStack {
        Spacer()
        
        LiquidGlassTabBar(selectedTab: $selectedTab, tabs: tabs)
        
        Spacer().frame(height: 20)
        
        LiquidGlassTabBar(selectedTab: $selectedTab, tabs: tabs, isMinimized: true)
    }
    .background {
        LinearGradient(
            colors: [.blue.opacity(0.6), .purple.opacity(0.4), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
