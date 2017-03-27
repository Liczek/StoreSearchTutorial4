//
//  SearchResult.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 22.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation


class SearchResult {
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    
    // słowniczek - kind na wyświetlany kind
    //nie trzeba tworzyć kind w nawiasie (_ kind: String) bo już mamy kind property w SearchResult class
    func kindForDisplay() -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "AudioBook"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-vide": return "Music Vide"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }

    
    
}
// < oznacza, że jesli search result po lwej stronie jest mniejszy niz po prawej stronie to zwraca true, a jako żę sortujemy rosnąco to te co daja true wskoczą na początek listy
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
