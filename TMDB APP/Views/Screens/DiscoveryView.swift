//
//  DiscoveryView.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Discovery View
struct DiscoveryView: View {
    @StateObject private var moviesViewModel = MoviesViewModel()
    @EnvironmentObject private var watchlistManager: WatchlistManager
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Featured Movie
                    if let featuredMovie = moviesViewModel.featuredMovie {
                        featuredMovieSection(movie: featuredMovie)
                    }
                    
                    movieCategoriesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
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
            .refreshable {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                moviesViewModel.refreshData()
            }
            .overlay {
                if moviesViewModel.isLoading && moviesViewModel.trendingMovies.isEmpty {
                    loadingView
                }
            }
            .overlay {
                if let errorMessage = moviesViewModel.errorMessage {
                    errorView(message: errorMessage)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if moviesViewModel.trendingMovies.isEmpty {
                moviesViewModel.loadInitialData()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Explore the best of Indian cinema")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                } label: {
                    Image(systemName: "person.circle")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background {
                            if reduceTransparency {
                                Circle()
                                    .fill(.background.opacity(0.8))
                                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
                            } else {
                                Circle()
                                    .fill(.clear)
                                    .glassEffect(.regular.interactive())
                            }
                        }
                }
                .accessibilityLabel("Profile")
                .accessibilityHint("Double tap to open profile")
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Featured Movie Section
    private func featuredMovieSection(movie: Movie) -> some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                        .symbolEffect(
                            .pulse,
                            options: reduceMotion ? .nonRepeating.speed(0) : .default
                        )
                    
                    Text("Featured")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Don't miss")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.tint.opacity(0.1), in: Capsule())
            }
            
            FeaturedMovieCard(movie: movie)
        }
    }
    
    // MARK: - Movie Categories Section
    private var movieCategoriesSection: some View {
        VStack(spacing: 32) {
            movieRowSection(
                title: "Trending Now",
                movies: moviesViewModel.trendingMovies,
                category: .trending
            )
            
            movieRowSection(
                title: "Bollywood",
                movies: moviesViewModel.bollywoodMovies,
                category: .bollywood
            )
            
            movieRowSection(
                title: "South Indian",
                movies: moviesViewModel.southIndianMovies,
                category: .southIndian
            )
            
            movieRowSection(
                title: "Now Playing",
                movies: moviesViewModel.nowPlayingMovies,
                category: .nowPlaying
            )
            
            movieRowSection(
                title: "Popular",
                movies: moviesViewModel.popularMovies,
                category: .popular
            )
            
            movieRowSection(
                title: "Top Rated",
                movies: moviesViewModel.topRatedMovies,
                category: .topRated
            )
            
            movieRowSection(
                title: "Coming Soon",
                movies: moviesViewModel.upcomingMovies,
                category: .upcoming
            )
        }
    }
    
    // MARK: - Movie Row Section
    private func movieRowSection(title: String, movies: [Movie], category: MovieCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: category.systemImage)
                        .font(.title3)
                        .foregroundStyle(.tint)
                        .symbolEffect(
                            .pulse,
                            options: reduceMotion ? .nonRepeating.speed(0) : .default
                        )
                    
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                } label: {
                    Text("See All")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.tint)
                }
                .accessibilityLabel("See all \(title.lowercased()) movies")
            }
            
            if movies.isEmpty {
                if moviesViewModel.isLoading {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading \(title.lowercased())...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .frame(height: 240)
                } else {
                    EmptyStateView(message: "No \(title.lowercased()) available")
                        .frame(height: 200)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(movies.prefix(10)) { movie in
                            MovieCard(movie: movie, cardSize: .medium)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 280)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primary)
            
            Text("Loading movies...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if reduceTransparency {
                Rectangle()
                    .fill(.background.opacity(0.95))
            } else {
                Rectangle()
                    .fill(.clear)
                    .glassEffect(.regular)
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
                .symbolEffect(
                    .pulse,
                    options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                )
            
            Text("Oops!")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                moviesViewModel.refreshData()
            } label: {
                Text("Try Again")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor.gradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if reduceTransparency {
                Rectangle()
                    .fill(.background.opacity(0.95))
            } else {
                Rectangle()
                    .fill(.clear)
                    .glassEffect(.regular)
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let message: String
    
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .symbolEffect(
                    .pulse,
                    options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                )
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if reduceTransparency {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.opacity(0.8))
                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.clear)
                    .glassEffect(.regular)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DiscoveryView()
        .environmentObject(WatchlistManager.shared)
}
