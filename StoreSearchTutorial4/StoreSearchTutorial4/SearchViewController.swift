//
//  ViewController.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 22.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
//MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
//MARK: - Variables and constants
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        //ukrywanie klawiatury przy swipie
        tableView.keyboardDismissMode = .interactive
        // żeby wydobyć rowsy ukryte pod search barem
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        //klawiatura sie pojawia na starcie
        searchBar.becomeFirstResponder()
        
        
        //Cell NIB register IMPORTANT
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Table Views
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // uniemożliwia wybranie wiersza gdy searchResults.count zwraca 0 po wyszukaniu
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
//MARK: - STRUCTS
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
//MARK: - RANDOM METHODS
    
    func iTunesURL(searchText: String) -> URL {
        //poniższa linijka jest po zeby było można spacje wyszukiwać
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        //&limit=200 ustawia z default limit = 50 na 200 wyników
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    // zapytanie do strony precyzujące ze odpowiedz ma być w utf-8
    func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download  Error: \(error)")
            return nil
        }
    }

//MARK: - PARSEs for JSON
    
    //dzielenie Dictionaries otrzymanych z apple (każdy disctionary to jeden wynik wyszukiwania)
    // tym parse dzielimy array na dictionary [String: Any]
    func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }
        
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
    func parse(dictionary: [String: Any]) -> [SearchResult] {
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
    
    
    func parse(track dictionary: [String: Any]) -> SearchResult {
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
    
    func parse(audiobook dictionary: [String: Any]) -> SearchResult {
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
    
    func parse(software dictionary: [String: Any]) -> SearchResult {
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

    
    func parse(ebook dictionary: [String: Any]) -> SearchResult {
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


    
    // słowniczek - kind na wyświetlany kind
    func kindForDisplay(_ kind: String) -> String {
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

//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let queue = DispatchQueue.global()
            
            queue.async {
                let url = self.iTunesURL(searchText: searchBar.text!)
                
                if let jsonString = self.performStoreRequest(with: url), let jsonDictionary = self.parse(json: jsonString) {
                    
                    self.searchResults = self.parse(dictionary: jsonDictionary)
                    // sortowanie wyniku alfabetycznie
                    self.searchResults.sort(by: <)
                    
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        print("Downloading Data, Parsing and Sorting DONE!")
                        }
                    return
                }
                DispatchQueue.main.async {
                    self.showNetworkError()
                    print("ERROR! - with data, parsing or sorting")
                }                
            }
        }
    }
    
    
    //UIBarPositionDelegate ma możliwość połączenia się z innymi obiektami w tym wypadku z UISearchBarem
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whooops....", message: "There was an error reading from the iTunes Store. Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //jeśli nie szukaliśmy nic tabela zwraca 0 rows jak szukalismy i nie znalezlismy tabela zwrac 1 row z informacja, else return .count
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            //jakby nie bylo w JSON artisName to Unknown jak będzie to artistName i kind
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text! = "Unknown"
            } else {
                cell.artistNameLabel.text! = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
