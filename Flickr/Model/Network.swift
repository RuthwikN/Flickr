//
//  Network.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
import SwiftUI
import Combine

class Network: ObservableObject {
    
    @Published var items: [Item] = []
    @Published var strErrorMessage: String? = nil
    @Published var searchText: String = "" 
    
    func getItems(tags: String) {
        
        var arrQueryItems = [URLQueryItem]()
        arrQueryItems.append(URLQueryItem(name: "format", value: "json"))
        arrQueryItems.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        arrQueryItems.append(URLQueryItem(name: "tags", value: tags))
        let endPoint = Endpoint.endpoint("services/feeds/photos_public.gne", arrQueryItems)
        
        ApiClient.performCall(endpoint: endPoint, responseType: SearchData.self) { result in
            switch result {
            case .success(_, let obj):
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.items = obj.items
                }
            case .failure(_, let error):
                self.strErrorMessage = error.localizedDescription
            }
        }
    }
}
