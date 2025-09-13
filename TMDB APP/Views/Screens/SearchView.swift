//
//  SearchView.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI

// MARK: - Search View
struct SearchView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @EnvironmentObject private var watchlistManager: WatchlistManager
    @State private var searchText = ""
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Results
                searchResults
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
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search movies..."
            )
            .onSubmit(of: .search) {
                performSearch()
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    searchViewModel.clearSearch()
                } else if newValue.count > 2 {
                    // Debounced search
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        if searchText == newValue {
                            searchViewModel.searchMovies(query: newValue)
                        }
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        searchViewModel.searchMovies(query: searchText)
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        Group {
            if searchViewModel.isSearching {
                searchingView
            } else if !searchViewModel.hasSearched {
                initialSearchView
            } else if searchViewModel.searchResults.isEmpty {
                noResultsView
            } else {
                resultsListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100) // Space for tab bar
    }
    
    // MARK: - Searching View
    private var searchingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primary)
            
            Text("Searching...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Initial Search View
    private var initialSearchView: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.accentColor.opacity(0.6))
                        .symbolEffect(
                            .pulse,
                            options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                        )
                    
                    VStack(spacing: 8) {
                        Text("Discover Movies")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Search for your favorite movies and discover new ones")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Popular Searches")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(popularSearches, id: \.self) { search in
                            Button {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                searchText = search
                                searchViewModel.searchMovies(query: search)
                            } label: {
                                Text(search)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        if reduceTransparency {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.background.opacity(0.8))
                                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.clear)
                                                .glassEffect(.regular.interactive())
                                        }
                                    }
                            }
                            .accessibilityLabel("Search for \(search)")
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
                .symbolEffect(
                    .pulse,
                    options: reduceMotion ? .nonRepeating.speed(0) : .repeating
                )
            
            Text("No Results Found")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text("Try adjusting your search terms or explore popular searches")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Results List View
    private var resultsListView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Results header
                HStack {
                    Text("\(searchViewModel.searchResults.count) Results")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Results grid
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                    spacing: 20
                ) {
                    ForEach(searchViewModel.searchResults) { movie in
                        MovieCard(movie: movie, cardSize: .medium)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .scrollIndicators(.visible)
    }
    
    // MARK: - Popular Searches
    private let popularSearches = [
        "Marvel", "DC Comics", "Action", "Comedy",
        "Horror", "Romance", "Sci-Fi", "Drama"
    ]
}

// MARK: - Preview
#Preview {
    SearchView()
        .environmentObject(WatchlistManager.shared)
}