//
//  MovieCard.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Movie Card
struct MovieCard: View {
    let movie: Movie
    let cardSize: CardSize
    @State private var isPressed = false
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @EnvironmentObject private var appRouter: AppRouter
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    enum CardSize {
        case small, medium, large
        
        var dimensions: CGSize {
            switch self {
            case .small:
                return CGSize(width: 120, height: 180)
            case .medium:
                return CGSize(width: 160, height: 240)
            case .large:
                return CGSize(width: 200, height: 300)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(0.5, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "film")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .symbolEffect(
                                .pulse,
                                options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                            )
                    }
                    .enhancedShimmer()
            }
            .frame(width: cardSize.dimensions.width, height: cardSize.dimensions.height * 0.75)
            .clipShape(
                .rect(
                    topLeadingRadius: cardSize.cornerRadius,
                    topTrailingRadius: cardSize.cornerRadius
                )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(movie.formattedRating)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(
                            reduceMotion ? 
                                .linear(duration: 0.2) : 
                                .spring(response: 0.3, dampingFraction: 0.7)
                        ) {
                            watchlistManager.toggleWatchlist(movie)
                        }
                    } label: {
                        Image(systemName: watchlistManager.isInWatchlist(movie) ? "bookmark.fill" : "bookmark")
                            .font(.caption)
                            .foregroundStyle(watchlistManager.isInWatchlist(movie) ? Color.accentColor : Color.secondary)
                            .symbolEffect(
                                .bounce.down,
                                options: reduceMotion ? .nonRepeating.speed(0) : .default,
                                value: watchlistManager.isInWatchlist(movie)
                            )
                    }
                    .accessibilityLabel(watchlistManager.isInWatchlist(movie) ? "Remove from watchlist" : "Add to watchlist")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(width: cardSize.dimensions.width, height: cardSize.dimensions.height * 0.25, alignment: .top)
        }
        .frame(width: cardSize.dimensions.width, height: cardSize.dimensions.height)
        .floatingCard(elevation: 8, cornerRadius: cardSize.cornerRadius)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(
            reduceMotion ? 
                .linear(duration: 0.1) : 
                .spring(response: 0.3, dampingFraction: 0.7), 
            value: isPressed
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), rated \(movie.formattedRating)")
        .accessibilityHint("Double tap to view details")
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            appRouter.navigateToMovie(movie)
        }
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

// MARK: - Featured Movie Card
struct FeaturedMovieCard: View {
    let movie: Movie
    @State private var isPressed = false
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @EnvironmentObject private var appRouter: AppRouter
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            AsyncImage(url: movie.backdropURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .symbolEffect(
                                .pulse,
                                options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                            )
                    }
                    .enhancedShimmer()
            }
            .frame(height: 280)
            .clipShape(.rect(cornerRadius: 20))
            
            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    .black.opacity(0.1),
                    .black.opacity(0.5),
                    .black.opacity(0.8),
                    .black.opacity(0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(.rect(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0) // Push content to bottom
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text(movie.formattedRating)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        }
                        
                        if let releaseDate = movie.releaseDate {
                            Text("• \(String(releaseDate.prefix(4)))")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        Button {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(
                                reduceMotion ? 
                                    .linear(duration: 0.2) : 
                                    .spring(response: 0.3, dampingFraction: 0.7)
                            ) {
                                watchlistManager.toggleWatchlist(movie)
                            }
                        } label: {
                            Image(systemName: watchlistManager.isInWatchlist(movie) ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .symbolEffect(
                                    .bounce.down,
                                    options: reduceMotion ? .nonRepeating.speed(0) : .default,
                                    value: watchlistManager.isInWatchlist(movie)
                                )
                                .padding(10)
                                .background {
                                    if reduceTransparency {
                                        Circle()
                                            .fill(.black.opacity(0.5))
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    } else {
                                        Circle()
                                            .fill(.ultraThinMaterial.opacity(0.8))
                                            .stroke(.white.opacity(0.1), lineWidth: 1)
                                    }
                                }
                        }
                        .accessibilityLabel(watchlistManager.isInWatchlist(movie) ? "Remove from watchlist" : "Add to watchlist")
                    }
                    
                    if let overview = movie.overview, !overview.isEmpty {
                        Text(overview)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .floatingCard(elevation: 12, cornerRadius: 20)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(
            reduceMotion ? 
                .linear(duration: 0.1) : 
                .spring(response: 0.3, dampingFraction: 0.7), 
            value: isPressed
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Featured: \(movie.title), rated \(movie.formattedRating)")
        .accessibilityHint("Double tap to view details")
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            appRouter.navigateToMovie(movie)
        }
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
    }
}

// MARK: - Preview
#Preview {
    let sampleMovie = Movie(
        id: 1,
        title: "Sample Movie",
        originalTitle: "Sample Movie",
        overview: "This is a sample movie overview that shows how the card looks with text content.",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2024-01-01",
        voteAverage: 8.5,
        voteCount: 1000,
        popularity: 100.0,
        adult: false,
        video: false,
        genreIds: [28, 12]
    )
    
    VStack {
        MovieCard(movie: sampleMovie, cardSize: .medium)
        FeaturedMovieCard(movie: sampleMovie)
    }
    .padding()
    .environmentObject(WatchlistManager.shared)
    .environmentObject(AppRouter())
}
