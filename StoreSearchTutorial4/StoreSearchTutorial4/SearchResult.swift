//
//  SearchResult.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 22.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation

// tworzymy dictionary z [key : kind]
private let displayNamesForKind = [
"album": NSLocalizedString("Album", comment: "Localized kind: Album"),
"audiobook": NSLocalizedString("AudioBook", comment: "Localized kind: Audio Book"),
"book": NSLocalizedString("Book", comment: "Localized kind: Book"),
"ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
"feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Feature Movie"),
"music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
"podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
"software": NSLocalizedString("App", comment: "Localized kind: Software"),
"song": NSLocalizedString("Song", comment: "Localized kind: Song"),
"tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode"),]

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
        //dictionary zawsze jest optional w sytuacji jak nie znajdzie key (czyli kind z JSON) i nie moze podac wyniku to poprostu zróci key czyli kind z JSON
        return displayNamesForKind[kind] ?? kind
    }

    
    
}
// < oznacza, że jesli search result po lwej stronie jest mniejszy niz po prawej stronie to zwraca true, a jako żę sortujemy rosnąco to te co daja true wskoczą na początek listy
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
