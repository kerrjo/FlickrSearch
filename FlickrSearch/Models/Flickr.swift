//
//  Flickr.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
//   let flickr = try? newJSONDecoder().decode(Flickr.self, from: jsonData)

// let modified: String   let modified: Date

// MARK: - Flickr
struct Flickr: Codable {
    let title: String
    let link: String
    let flickrDescription: String
    let modified: String
    let generator: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case title, link
        case flickrDescription = "description"
        case modified, generator, items
    }
}

// MARK: - Item
struct Item: Codable {
    let title: String
    let link: String
    let media: Media
    let dateTaken: String
    let itemDescription: String
    let published: String
    let author, authorID, tags: String

    enum CodingKeys: String, CodingKey {
        case title, link, media
        case dateTaken = "date_taken"
        case itemDescription = "description"
        case published, author
        case authorID = "author_id"
        case tags
    }
}

// MARK: - Media
struct Media: Codable {
    let m: String
}
