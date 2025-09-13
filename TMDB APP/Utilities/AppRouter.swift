//
//  AppRouter.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import SwiftUI
import Combine

// MARK: - App Router
class AppRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedMovie: Movie?
    @Published var showingMovieDetail = false
    
    func navigateToMovie(_ movie: Movie) {
        selectedMovie = movie
        showingMovieDetail = true
    }
    
    func dismissMovieDetail() {
        showingMovieDetail = false
        selectedMovie = nil
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// MARK: - Navigation Extensions
extension View {
    func movieDetailNavigation(router: AppRouter) -> some View {
        self.modifier(MovieDetailNavigationModifier(router: router))
    }
}

struct MovieDetailNavigationModifier: ViewModifier {
    let router: AppRouter
    @EnvironmentObject private var watchlistManager: WatchlistManager
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(
                get: { router.showingMovieDetail },
                set: { _ in router.dismissMovieDetail() }
            )) {
                if let movie = router.selectedMovie {
                    MovieDetailView(movie: movie)
                        .environmentObject(router)
                        .environmentObject(watchlistManager)
                }
            }
    }
}

