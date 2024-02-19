//
//  ImageCardView.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
import SwiftUI

struct ImageCardView: View {

    let item: Item
    var body: some View {
        GroupBox {
            MyImage(url: item.media.m.url)
                .scaledToFill()
                .frame(height: 150)
                .clipped()
            VStack {
                VStack {
                    Text(item.title)
                        .font(.title2)
                        .bold()
                    Spacer()
                    AttributedText(item.description.html)
                        .font(.subheadline)
                }
                .padding(.bottom, 1)
            }
            .padding(.horizontal, 15)
        }
        .groupBoxStyle(CardGroupBoxStyle())
    }
}
