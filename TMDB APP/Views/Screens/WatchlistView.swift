//
//  WatchlistView.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Watchlist View
struct WatchlistView: View {
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @State private var showingDeleteConfirmation = false
    @State private var selectedLayout: LayoutType = .grid
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    enum LayoutType: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
        
        var icon: String {
            switch self {
            case .grid: return "square.grid.2x2"
            case .list: return "list.bullet"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content
                if watchlistManager.watchlist.isEmpty {
                    emptyWatchlistView
                } else {
                    watchlistContent
                }
            }
            .background {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Layout", selection: $selectedLayout) {
                            ForEach(LayoutType.allCases, id: \.self) { layout in
                                Label(layout.rawValue, systemImage: layout.icon)
                                    .tag(layout)
                            }
                        }
                        .pickerStyle(.inline)
                        
                        if !watchlistManager.watchlist.isEmpty {
                            Divider()
                            
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Clear Watchlist", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Watchlist options")
                }
            }
            .confirmationDialog(
                "Clear Watchlist",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    withAnimation(
                        reduceMotion ? 
                            .linear(duration: 0.3) : 
                            .spring(response: 0.5, dampingFraction: 0.7)
                    ) {
                        watchlistManager.clearWatchlist()
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove all movies from your watchlist. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Empty Watchlist View
    private var emptyWatchlistView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("No Movies in Watchlist")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("Start building your movie collection by adding films you want to watch later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Button {
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "film")
                    Text("Discover Movies")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.blue.gradient)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Watchlist Content
    private var watchlistContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if selectedLayout == .grid {
                    gridLayout
                } else {
                    listLayout
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Grid Layout
    private var gridLayout: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
            spacing: 20
        ) {
            ForEach(watchlistManager.watchlist) { movie in
                MovieCard(movie: movie, cardSize: .medium)
                    .contextMenu {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                watchlistManager.removeFromWatchlist(movie)
                            }
                        } label: {
                            Label("Remove from Watchlist", systemImage: "bookmark.slash")
                        }
                    }
            }
        }
    }
    
    // MARK: - List Layout
    private var listLayout: some View {
        LazyVStack(spacing: 16) {
            ForEach(watchlistManager.watchlist) { movie in
                WatchlistMovieRow(movie: movie)
                    .contextMenu {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                watchlistManager.removeFromWatchlist(movie)
                            }
                        } label: {
                            Label("Remove from Watchlist", systemImage: "bookmark.slash")
                        }
                    }
            }
        }
    }
}

// MARK: - Watchlist Movie Row
struct WatchlistMovieRow: View {
    let movie: Movie
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @State private var isPressed = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    var body: some View {
        HStack(spacing: 16) {
            // Movie Poster
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Image(systemName: "film")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .enhancedShimmer()
            }
            .frame(width: 80, height: 120)
            .clipShape(.rect(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                if let overview = movie.overview {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text(movie.formattedRating)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(
                            reduceMotion ? 
                                .linear(duration: 0.2) : 
                                .spring(response: 0.3, dampingFraction: 0.7)
                        ) {
                            watchlistManager.removeFromWatchlist(movie)
                        }
                    } label: {
                        Image(systemName: "bookmark.slash")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(8)
                            .background(.red.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .floatingCard()
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(
            reduceMotion ? 
                .linear(duration: 0.1) : 
                .spring(response: 0.3, dampingFraction: 0.7), 
            value: isPressed
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Extensions
extension WatchlistView {
    private var deleteConfirmationAlert: Alert {
        Alert(
            title: Text("Clear Watchlist"),
            message: Text("Are you sure you want to remove all movies from your watchlist? This action cannot be undone."),
            primaryButton: .destructive(Text("Clear All")) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    watchlistManager.clearWatchlist()
                }
            },
            secondaryButton: .cancel()
        )
    }
}

// MARK: - Preview
#Preview {
    WatchlistView()
        .environmentObject(WatchlistManager.shared)
        .alert("Clear Watchlist", isPresented: .constant(false)) {
            Button("Clear All", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove all movies from your watchlist?")
        }
}