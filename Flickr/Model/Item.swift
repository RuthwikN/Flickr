//
//  Item.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation

struct SearchData: Codable {
    
    let title: String
    let link: String
    let description: String
    let modified: Date
    let generator: String
    let items: [Item]
}


// MARK: - Item
struct Item: Codable, Identifiable {
    var id: String? {
        UUID().uuidString
    }
    
   
    let title: String
    let link: String
    let media: Media
    let dateTaken, description: String
    let published: String
    let author, authorID, tags: String

    enum CodingKeys: String, CodingKey {
        case title, link, media
        case dateTaken = "date_taken"
        case description, published, author
        case authorID = "author_id"
        case tags
    }
}

// MARK: - Media
struct Media: Codable {
    let m: String
}
