//
//  Video.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation

// MARK: - Videos Response
struct VideosResponse: Codable {
    let id: Int
    let results: [Video]
}

// MARK: - Video
struct Video: Codable, Identifiable {
    let id: String
    let name: String
    let key: String
    let site: String
    let type: String
    let official: Bool
    let publishedAt: String?
    let size: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, key, site, type, official, size
        case publishedAt = "published_at"
    }
    
    var isTrailer: Bool {
        type.lowercased() == "trailer"
    }
    
    var youTubeURL: URL? {
        guard site.lowercased() == "youtube" else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
    
    var thumbnailURL: URL? {
        guard site.lowercased() == "youtube" else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }
}
