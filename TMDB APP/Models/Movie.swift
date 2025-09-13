//
//  Movie.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation

// MARK: - Movie Response
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Movie
struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool
    let video: Bool
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
    }
    
    // MARK: - Computed Properties
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "\(Configuration.tmdbImageBaseURL)/\(Configuration.ImageSize.poster)\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "\(Configuration.tmdbImageBaseURL)/\(Configuration.ImageSize.backdrop)\(backdropPath)")
    }
    
    var thumbnailURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "\(Configuration.tmdbImageBaseURL)/\(Configuration.ImageSize.thumbnail)\(posterPath)")
    }
    
    var formattedReleaseDate: String {
        guard let releaseDate = releaseDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    var ratingPercentage: Double {
        voteAverage * 10
    }
}

// MARK: - Movie Details
struct MovieDetails: Codable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool
    let video: Bool
    let runtime: Int?
    let budget: Int?
    let revenue: Int?
    let status: String?
    let tagline: String?
    let homepage: String?
    let imdbId: String?
    let genres: [Genre]?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let spokenLanguages: [SpokenLanguage]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video, runtime, budget, revenue, status, tagline, homepage, genres
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case imdbId = "imdb_id"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
    }
}

// MARK: - Supporting Models
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct ProductionCompany: Codable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

struct ProductionCountry: Codable {
    let iso3166_1: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

struct SpokenLanguage: Codable {
    let iso639_1: String
    let name: String
    let englishName: String?
    
    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case name
        case englishName = "english_name"
    }
}
