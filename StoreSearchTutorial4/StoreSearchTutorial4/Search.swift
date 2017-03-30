//
//  Search.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 29.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation
import UIKit

//closure  aby search moglo mowic do searchVC ze skonczylo szukac,

typealias SearchComplete = (Bool) -> Void

class Search {
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: URLSessionDataTask? = nil
    
//MARK: - Enums
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
//MARK: - METHODS
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
     if !text.isEmpty {
        dataTask?.cancel()
        isLoading = true
        hasSearched = true
        searchResults = []
        
     // w celu stworzenia url w funkcje iTunesURL wrzucamy wartosci czyli wyszukiwany text i index segmentu ktory zostaje w funkcji iTunesURl przelozony na string okreslajacy kategorie
     let url = iTunesURL(searchText: text, category: category)
     
     let session = URLSession.shared
     
        dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
     
            var success = false
            
            if let error = error as? NSError, error.code == -999 {
                //return czyli nie wykonujemy searcha zostaje on anulowany
                return
            }
        
     if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
        let jsonData = data,
        let jsonDictionary = self.parse(json: jsonData) {
            self.searchResults = self.parse(dictionary: jsonDictionary)
            self.searchResults.sort(by: <)
     
               print ("Success!")
               self.isLoading = false
                //sukces dlatego true
               success = true
        }
            if !success {
                print("Failure! \(response)")
                // porażka dlatego nie zmianiamy success na true tylko pozostaje false
                self.hasSearched = false
                self.isLoading = false
            }
            // w sytuacji sukcesu zwracamy completion true, w sytuacji niepowodzenia pozostawiamy success jako false
            DispatchQueue.main.async {
                completion(success)
            }
        })
        dataTask?.resume()
     
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        
        //przypisanie do Segment Control indexów wrapperTypes z JSON
        let entityName = category.entityName
        //poniższa linijka jest po zeby było można spacje wyszukiwać
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        //&limit=200 ustawia z default limit = 50 na 200 wyników
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
        return url!
    }

//MARK: - PARSEs for JSON
    
        //dzielenie Dictionaries otrzymanych z apple (każdy disctionary to jeden wynik wyszukiwania)
        // tym parse dzielimy array na dictionary [String: Any]
    private func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    
        // tym parse wyszukujemy w elementach arrey results 2 pozycji wrapperType i kind
        // wrapperType: track - song, movie, music video, podcats, episod of a TV show
        //                    - audiobook
        //                    - software
    private func parse(dictionary: [String: Any]) -> [SearchResult] {
        //sprawdzasz czy to dictionary zawiera nazwę results i robisz arrey z niego
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            //zwracamy pustą array
            return []
        }
        
        var searchResults: [SearchResult] = []
        //robisz loop dla kazdego elementu arrey wykonujesz kolejny if
        for resultDict in array {
            
            if let resultDict = resultDict as? [String: Any] {
                // dla kazdego results (dictionary) wyszukujesz wartości wrapperType - on okresla czy to piosenka film ebook czy apliakcja
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                    // e-booki nie maja wrapperType więc trzeba odnieść się do kind i wyszukac kind == "ebook"
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    
    private func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        // price i genre czasem poprostu nie występują w JSON data
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        
        //audiobook nie ma kategorii kind wiec ustalamy ja samemu
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        // price i genre czasem poprostu nie występują w JSON data
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        // price i genre czasem poprostu nie występują w JSON data
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    
    private func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        // price i genre czasem poprostu nie występują w JSON data
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        //ebook nie ma jednego genre a arrey of genres wiec wypisujemy je wszystkie po przecinku: joined with separator
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }
    
}
