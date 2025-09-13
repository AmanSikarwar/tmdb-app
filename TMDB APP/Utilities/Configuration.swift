//
//  Configuration.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation
import SwiftUI

struct Configuration {
    static let tmdbAPIKey = "18c05d8a276b216d3c3d79bf09afcc50"
    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p"
    
    // Image sizes
    struct ImageSize {
        static let poster = "w500"
        static let backdrop = "w1280"
        static let profile = "w185"
        static let thumbnail = "w92"
    }
    
    // Endpoints
    struct Endpoints {
        static let nowPlaying = "/movie/now_playing"
        static let popular = "/movie/popular"
        static let topRated = "/movie/top_rated"
        static let upcoming = "/movie/upcoming"
        static let trending = "/trending/movie/day"
        static let search = "/search/movie"
        static let movieDetails = "/movie"
        static let recommendations = "/recommendations"
        static let similar = "/similar"
        static let credits = "/credits"
        static let videos = "/videos"
    }
    
    // MARK: - Indian Movies Configuration
    struct IndianMovies {
        static let region = "IN"  // India region code
        static let primaryLanguage = "hi"  // Hindi
        static let languages = ["hi", "te", "ta", "ml", "kn", "bn", "gu", "mr", "pa"]  // Indian languages
        static let defaultLanguages = "hi,te,ta,ml,kn,bn,gu,mr,pa,en"  // Include English for broader content
        
        static let commonParameters: [String: String] = [
            "region": region,
            "with_original_language": defaultLanguages,
            "sort_by": "popularity.desc"
        ]
        
        static let hindiParameters: [String: String] = [
            "region": region,
            "with_original_language": "hi",
            "sort_by": "popularity.desc"
        ]
        
        static let southIndianParameters: [String: String] = [
            "region": region,
            "with_original_language": "te,ta,ml,kn",
            "sort_by": "popularity.desc"
        ]
    }
    
    // MARK: - Liquid Glass TabBar Configuration
    struct TabBar {
        static let animationDuration: Double = 0.4
        static let springResponse: Double = 0.4
        static let springDampingFraction: Double = 0.75
        static let minimizeThreshold: CGFloat = 50.0
        static let hoverEffectDuration: Double = 0.3
        static let pulseEffectDuration: Double = 0.3
        
        static let tabItems: [TabItem] = [
            TabItem(
                id: "discover",
                icon: "film",
                iconFilled: "film.fill",
                title: "Discover",
                accessibilityLabel: "Discover movies"
            ),
            TabItem(
                id: "search",
                icon: "magnifyingglass",
                iconFilled: "magnifyingglass",
                title: "Search",
                accessibilityLabel: "Search movies"
            ),
            TabItem(
                id: "watchlist",
                icon: "bookmark",
                iconFilled: "bookmark.fill",
                title: "Watchlist",
                accessibilityLabel: "Your watchlist"
            )
        ]
        
        struct Animations {
            static let tabSelection = Animation.spring(
                response: springResponse,
                dampingFraction: springDampingFraction
            )
            
            static let buttonPress = Animation.spring(
                response: 0.3,
                dampingFraction: 0.6
            )
            
            static let minimizeTransition = Animation.spring(
                response: 0.5,
                dampingFraction: 0.8
            )
            
            static let glowEffect = Animation.easeInOut(duration: hoverEffectDuration)
        }
    }
}
