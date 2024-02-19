//
//  Helper.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation

enum BaseUrl {
    case baseUrl
}
extension BaseUrl {
    var baseUrlString : String {
        switch self {
        case .baseUrl: return "https://api.flickr.com"
        }
    }
}
