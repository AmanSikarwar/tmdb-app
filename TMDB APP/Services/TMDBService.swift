//
//  TMDBService.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - TMDB Service
class TMDBService: ObservableObject {
    static let shared = TMDBService()
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Movie Lists
    func getNowPlayingMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.commonParameters
        parameters["page"] = "\(page)"
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.nowPlaying,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getPopularMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.commonParameters
        parameters["page"] = "\(page)"
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.popular,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getTopRatedMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.commonParameters
        parameters["page"] = "\(page)"
        parameters["vote_count.gte"] = "100"  // Ensure movies have enough votes
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.topRated,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getUpcomingMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.commonParameters
        parameters["page"] = "\(page)"
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.upcoming,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getTrendingMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters: [String: String] = [
            "page": "\(page)"
        ]
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.trending,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    // MARK: - Search
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters: [String: String] = [
            "query": query,
            "page": "\(page)",
            "region": Configuration.IndianMovies.region,
            "include_adult": "false"
        ]
        
        return networkManager.request(
            endpoint: Configuration.Endpoints.search,
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    // MARK: - Movie Details
    func getMovieDetails(id: Int) -> AnyPublisher<MovieDetails, NetworkError> {
        networkManager.request(
            endpoint: "\(Configuration.Endpoints.movieDetails)/\(id)",
            type: MovieDetails.self
        )
    }
    
    func getMovieCredits(id: Int) -> AnyPublisher<CreditsResponse, NetworkError> {
        networkManager.request(
            endpoint: "\(Configuration.Endpoints.movieDetails)/\(id)\(Configuration.Endpoints.credits)",
            type: CreditsResponse.self
        )
    }
    
    func getMovieVideos(id: Int) -> AnyPublisher<VideosResponse, NetworkError> {
        networkManager.request(
            endpoint: "\(Configuration.Endpoints.movieDetails)/\(id)\(Configuration.Endpoints.videos)",
            type: VideosResponse.self
        )
    }
    
    func getRecommendations(id: Int, page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        networkManager.request(
            endpoint: "\(Configuration.Endpoints.movieDetails)/\(id)\(Configuration.Endpoints.recommendations)",
            parameters: ["page": "\(page)"],
            type: MovieResponse.self
        )
    }
    
    func getSimilarMovies(id: Int, page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        networkManager.request(
            endpoint: "\(Configuration.Endpoints.movieDetails)/\(id)\(Configuration.Endpoints.similar)",
            parameters: ["page": "\(page)"],
            type: MovieResponse.self
        )
    }
    
    // MARK: - Indian Movies Specific
    func getBollywoodMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.hindiParameters
        parameters["page"] = "\(page)"
        
        return networkManager.request(
            endpoint: "/discover/movie",
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getSouthIndianMovies(page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.southIndianParameters
        parameters["page"] = "\(page)"
        
        return networkManager.request(
            endpoint: "/discover/movie",
            parameters: parameters,
            type: MovieResponse.self
        )
    }
    
    func getIndianMoviesByGenre(genreId: Int, page: Int = 1) -> AnyPublisher<MovieResponse, NetworkError> {
        var parameters = Configuration.IndianMovies.commonParameters
        parameters["page"] = "\(page)"
        parameters["with_genres"] = "\(genreId)"
        
        return networkManager.request(
            endpoint: "/discover/movie",
            parameters: parameters,
            type: MovieResponse.self
        )
    }
}
