//
//  String+Extension.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
import SwiftUI

extension String {

    public var url: URL? {
        URL(string: self)
    }
    
    public var html: NSAttributedString {
        if let attributedString = try? NSAttributedString(data:  Data(self.utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            return attributedString
        } else {
            return NSAttributedString(string: self)
        }
    }
    
    public var isBlank: Bool {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
    public var containsWhitespace: Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    public var trimmed: String {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    public var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
}
