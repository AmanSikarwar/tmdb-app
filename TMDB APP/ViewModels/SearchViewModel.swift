//
//  SearchViewModel.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import Combine

// MARK: - Search View Model
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Movie] = []
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var errorMessage: String?
    
    private let tmdbService = TMDBService.shared
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if !searchText.isEmpty {
                    self?.searchMovies(query: searchText)
                } else {
                    self?.clearSearch()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func searchMovies(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearSearch()
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        searchCancellable?.cancel()
        
        searchCancellable = tmdbService.searchMovies(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSearching = false
                    self?.hasSearched = true
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.searchResults = response.results
                }
            )
    }
    
    func clearSearch() {
        searchResults = []
        isSearching = false
        hasSearched = false
        errorMessage = nil
        searchCancellable?.cancel()
    }
    
    func retrySearch() {
        if !searchText.isEmpty {
            searchMovies(query: searchText)
        }
    }
}
