//
//  SearchListView.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
import SwiftUI

struct SearchListView: View {
    
    @StateObject var viewModel = Network()
    
    var body: some View {
        NavigationStack {
            HStack {
                TextField("Search", text: $viewModel.searchText) { isEditing in
                    if !isEditing {
                        self.viewModel.getItems(tags: viewModel.searchText.trimmed)
                    }
                }.border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                Button(action: {
                    self.viewModel.getItems(tags: viewModel.searchText.trimmed)
                }) {
                    Text("Search")
                }
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Text("Clear")
                }
            }.padding()
            List {
                ForEach(viewModel.items) { item in
                   ImageCardView(item: item)
                }
                .listRowSeparator(.hidden, edges: .all)
            }
            .listStyle(.plain)
            .navigationTitle("Find Image from Flickr")
        }
    }
}
