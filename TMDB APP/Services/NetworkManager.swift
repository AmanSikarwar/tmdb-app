//
//  NetworkManager.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        parameters: [String: String] = [:],
        type: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = buildURL(endpoint: endpoint, parameters: parameters) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.serverError(0)
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.networkUnavailable
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - URL Builder
    private func buildURL(endpoint: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: Configuration.tmdbBaseURL + endpoint)
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "api_key", value: Configuration.tmdbAPIKey))
        
        queryItems.append(URLQueryItem(name: "language", value: "en-US"))
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
