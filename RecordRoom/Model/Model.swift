//
//  Model.swift
//  RecordRoom
//
//  Created by Alison Ryan on 6/30/23.
//

import Foundation

struct Album: Hashable, Codable, Identifiable {
    let id: String
    let name: String
  let images: [Images]
  let artists: [Artist]

    // Add other properties as needed
}

struct Artist: Hashable, Codable, Identifiable {
  let id: String
  let name: String
}

struct Images: Hashable, Codable {
  let url: String
    // Add other properties as needed
}

struct SearchResponse: Codable {
    let albums: AlbumItems

    struct AlbumItems: Codable {
        let items: [Album]
    }
}

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    // Add other properties as needed
}

struct Track: Codable, Identifiable {
    let id: String
    let name: String
    // Add any other properties you need for the track

    // CodingKeys in case the property names differ from the API response
    enum CodingKeys: String, CodingKey {
        case id
        case name
        // Add coding keys for other properties if needed
    }
}

struct TrackResponse: Codable {
    let tracks: [Track]
}

