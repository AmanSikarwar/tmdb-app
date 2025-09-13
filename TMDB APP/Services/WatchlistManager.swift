//
//  WatchlistManager.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - Watchlist Manager
class WatchlistManager: ObservableObject {
    static let shared = WatchlistManager()
    
    @Published var watchlist: [Movie] = []
    
    private let userDefaults = UserDefaults.standard
    private let watchlistKey = "TMDBWatchlist"
    
    init() {
        loadWatchlist()
    }
    
    // MARK: - Public Methods
    func addToWatchlist(_ movie: Movie) {
        guard !isInWatchlist(movie) else { return }
        watchlist.append(movie)
        saveWatchlist()
    }
    
    func removeFromWatchlist(_ movie: Movie) {
        watchlist.removeAll { $0.id == movie.id }
        saveWatchlist()
    }
    
    func toggleWatchlist(_ movie: Movie) {
        if isInWatchlist(movie) {
            removeFromWatchlist(movie)
        } else {
            addToWatchlist(movie)
        }
    }
    
    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlist.contains { $0.id == movie.id }
    }
    
    func clearWatchlist() {
        watchlist.removeAll()
        saveWatchlist()
    }
    
    // MARK: - Private Methods
    private func saveWatchlist() {
        do {
            let data = try JSONEncoder().encode(watchlist)
            userDefaults.set(data, forKey: watchlistKey)
        } catch {
            print("Failed to save watchlist: \(error)")
        }
    }
    
    private func loadWatchlist() {
        guard let data = userDefaults.data(forKey: watchlistKey) else { return }
        
        do {
            watchlist = try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            print("Failed to load watchlist: \(error)")
            watchlist = []
        }
    }
}
