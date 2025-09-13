//
//  MovieDetailViewModel.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - Movie Detail View Model
class MovieDetailViewModel: ObservableObject {
    @Published var movieDetails: MovieDetails?
    @Published var cast: [CastMember] = []
    @Published var videos: [Video] = []
    @Published var recommendations: [Movie] = []
    @Published var similarMovies: [Movie] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let tmdbService = TMDBService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadMovieDetails(id: Int) {
        isLoading = true
        errorMessage = nil
        
        tmdbService.getMovieDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.isLoading = false
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] details in
                    self?.movieDetails = details
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getMovieCredits(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] credits in
                    self?.cast = Array(credits.cast.prefix(20))
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getMovieVideos(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] videos in
                    self?.videos = videos.results.filter { $0.isTrailer }.sorted { $0.official && !$1.official }
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getRecommendations(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] recommendations in
                    self?.recommendations = recommendations.results
                }
            )
            .store(in: &cancellables)
        
        tmdbService.getSimilarMovies(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] similar in
                    self?.similarMovies = similar.results
                }
            )
            .store(in: &cancellables)
    }
}