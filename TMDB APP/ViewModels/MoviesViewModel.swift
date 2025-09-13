//
//  MoviesViewModel.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - Movies View Model
class MoviesViewModel: ObservableObject {
    @Published var trendingMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var upcomingMovies: [Movie] = []
    @Published var featuredMovie: Movie?
    
    @Published var bollywoodMovies: [Movie] = []
    @Published var southIndianMovies: [Movie] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let tmdbService = TMDBService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialData()
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        tmdbService.getTrendingMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] trending in
                    self?.trendingMovies = trending.results
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getNowPlayingMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] nowPlaying in
                    self?.nowPlayingMovies = nowPlaying.results
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getPopularMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] popular in
                    self?.popularMovies = popular.results
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getTopRatedMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] topRated in
                    self?.topRatedMovies = topRated.results
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getBollywoodMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] bollywood in
                    self?.bollywoodMovies = bollywood.results
                    // Set featured movie to highest rated Bollywood movie
                    if let featuredBollywood = bollywood.results.max(by: { $0.voteAverage < $1.voteAverage }) {
                        self?.featuredMovie = featuredBollywood
                    }
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getSouthIndianMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] southIndian in
                    self?.southIndianMovies = southIndian.results
                    // Fallback: if no Bollywood featured movie set, use best South Indian
                    if self?.featuredMovie == nil,
                       let featuredSouthIndian = southIndian.results.max(by: { $0.voteAverage < $1.voteAverage }) {
                        self?.featuredMovie = featuredSouthIndian
                    }
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getUpcomingMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] upcoming in
                    self?.upcomingMovies = upcoming.results
                    // Final fallback: if no Indian featured movie set, use first trending
                    if self?.featuredMovie == nil {
                        self?.featuredMovie = self?.trendingMovies.first
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshData() {
        loadInitialData()
    }
    
    func loadMoreMovies(for category: MovieCategory) {
        print("Loading more movies for category: \(category)")
    }
}

// MARK: - Movie Category
enum MovieCategory: String, CaseIterable {
    case trending = "Trending"
    case nowPlaying = "Now Playing"
    case popular = "Popular"
    case topRated = "Top Rated"
    case upcoming = "Upcoming"
    case bollywood = "Bollywood"
    case southIndian = "South Indian"
    
    var systemImage: String {
        switch self {
        case .trending:
            return "flame"
        case .nowPlaying:
            return "play.circle"
        case .popular:
            return "heart"
        case .topRated:
            return "star"
        case .upcoming:
            return "clock"
        case .bollywood:
            return "theatermasks"
        case .southIndian:
            return "film.stack"
        }
    }
}