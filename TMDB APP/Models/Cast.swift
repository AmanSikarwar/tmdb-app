//
//  Cast.swift
//  TMDB APP
//
//  Created by Aman Sikarwar on 11/09/25.
//

import Foundation

// MARK: - Credits Response
struct CreditsResponse: Codable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

// MARK: - Cast Member
struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let originalName: String?
    let character: String?
    let order: Int
    let profilePath: String?
    let popularity: Double?
    let knownForDepartment: String?
    let adult: Bool?
    let gender: Int?
    let creditId: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order, popularity, adult, gender
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case creditId = "credit_id"
    }
    
    var profileURL: URL? {
        guard let profilePath = profilePath else { return nil }
        return URL(string: "\(Configuration.tmdbImageBaseURL)/\(Configuration.ImageSize.profile)\(profilePath)")
    }
}

// MARK: - Crew Member
struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let originalName: String?
    let job: String
    let department: String
    let profilePath: String?
    let popularity: Double?
    let knownForDepartment: String?
    let adult: Bool?
    let gender: Int?
    let creditId: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department, popularity, adult, gender
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case creditId = "credit_id"
    }
    
    var profileURL: URL? {
        guard let profilePath = profilePath else { return nil }
        return URL(string: "\(Configuration.tmdbImageBaseURL)/\(Configuration.ImageSize.profile)\(profilePath)")
    }
}
