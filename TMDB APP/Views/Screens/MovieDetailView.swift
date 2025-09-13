//
//  MovieDetailView.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Movie Detail View
struct MovieDetailView: View {
    let movie: Movie
    @StateObject private var viewModel = MovieDetailViewModel()
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showingTrailer = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    heroSection(geometry: geometry)
                    
                    contentSection
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .overlay(alignment: .topLeading) {
            navigationBar
        }
        .onAppear {
            viewModel.loadMovieDetails(id: movie.id)
        }
        .sheet(isPresented: $showingTrailer) {
            if let trailer = viewModel.videos.first {
                TrailerView(video: trailer)
            }
        }
    }
    
    // MARK: - Hero Section
    private func heroSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: movie.backdropURL ?? movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: geometry.size.width, height: 500)
            .offset(y: scrollOffset > 0 ? -scrollOffset * 0.8 : 0)
            .clipped()
            
            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    .black.opacity(0.3),
                    .black.opacity(0.8),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 16) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(movie.formattedRating)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white)
                            }
                            
                            // Release Year
                            if let releaseDate = movie.releaseDate {
                                Text(String(releaseDate.prefix(4)))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Runtime
                            if let runtime = viewModel.movieDetails?.runtime {
                                Text("\(runtime)m")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Overview
                        if let overview = movie.overview {
                            Text(overview)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(4)
                                .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    if !viewModel.videos.isEmpty {
                        Button {
                            showingTrailer = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Trailer")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            watchlistManager.toggleWatchlist(movie)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: watchlistManager.isInWatchlist(movie) ? "bookmark.fill" : "bookmark")
                            Text(watchlistManager.isInWatchlist(movie) ? "In Watchlist" : "Add to Watchlist")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(height: 500)
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("scroll")).minY
                )
            }
        )
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .opacity(scrollOffset < -50 ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: scrollOffset)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: 32) {
            if let movieDetails = viewModel.movieDetails {
                movieDetailsSection(movieDetails)
            }
            
            if !viewModel.cast.isEmpty {
                castSection
            }
            
            if !viewModel.recommendations.isEmpty {
                recommendationsSection
            }
            
            if !viewModel.similarMovies.isEmpty {
                similarMoviesSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
        .background(.regularMaterial)
    }
    
    // MARK: - Movie Details Section
    private func movieDetailsSection(_ details: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if let genres = details.genres, !genres.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genres")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(genres) { genre in
                                Text(genre.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            // Additional Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    if let status = details.status {
                        detailRow(title: "Status", value: status)
                    }
                    
                    if let budget = details.budget, budget > 0 {
                        detailRow(title: "Budget", value: "$\(budget.formatted())")
                    }
                    
                    if let revenue = details.revenue, revenue > 0 {
                        detailRow(title: "Revenue", value: "$\(revenue.formatted())")
                    }
                }
                .padding(16)
                .glassMaterial()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Detail Row
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Cast Section
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.cast.prefix(10)) { castMember in
                        CastMemberCard(castMember: castMember)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendations.prefix(10)) { movie in
                        MovieCard(movie: movie, cardSize: .small)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Similar Movies Section
    private var similarMoviesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Similar Movies")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.similarMovies.prefix(10)) { movie in
                        MovieCard(movie: movie, cardSize: .small)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Cast Member Card
struct CastMemberCard: View {
    let castMember: CastMember
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: castMember.profileURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(castMember.name)
                    .font(.caption.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if let character = castMember.character {
                    Text(character)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(width: 80)
    }
}

// MARK: - Trailer View
struct TrailerView: View {
    let video: Video
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if video.youTubeURL != nil {
                    Rectangle()
                        .fill(.black)
                        .overlay {
                            VStack(spacing: 16) {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                
                                Text("Trailer: \(video.name)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("YouTube: \(video.key)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    Spacer()
                }
            }
            .navigationTitle("Trailer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleMovie = Movie(
        id: 1,
        title: "Sample Movie",
        originalTitle: "Sample Movie",
        overview: "This is a sample movie overview that shows how the detail view looks with content.",
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
    
    MovieDetailView(movie: sampleMovie)
        .environmentObject(WatchlistManager.shared)
}
