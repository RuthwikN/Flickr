//
//  MyImage.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct MyImage: View {
    
    let url: URL?
    var body: some View {
        KFImage.url(url)
          .loadDiskFileSynchronously()
          .cacheMemoryOnly()
          .fade(duration: 0.25)
          .onProgress { receivedSize, totalSize in  }
          .onSuccess { result in  }
          .onFailure { error in }
    }
}
