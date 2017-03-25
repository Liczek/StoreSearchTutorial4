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
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
//MARK: - STRUCTS
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
//MARK: - RANDOM METHODS
    
    func iTunesURL(searchText: String) -> URL {
        //poniższa linijka jest po zeby było można spacje wyszukiwać
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
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
    func parse(dictionary: [String: Any]) {
        //sprawdzasz czy to dictionary zawiera nazwę results i robisz arrey z niego
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return
        }
        //robisz loop dla kazdego elementu arrey wykonujesz kolejny if
        for resultDict in array {
            
            if let resultDict = resultDict as? [String: Any] {
                // dla kazdego results (dictionary) wyszukujesz wartości wrapperType - on okresla czy to piosenka film ebook czy apliakcja
                if let wrapperType = resultDict["wrapperType"] as? String,
                let kind = resultDict["kind"] as? String {
                    print("wrapperType: \(wrapperType), kind: \(kind)")
                }
            }
        }
    }


}

//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: '\(url)'")
            if let jsonString = performStoreRequest(with: url) {
                print("Received JSON string '\(jsonString)'")
                
                if let jsonDictionary = parse(json: jsonString) {
                    print("Dictionary \(jsonDictionary)")
                    
                    parse(dictionary: jsonDictionary)
                    
                    tableView.reloadData()
                    return
                }
            }
            showNetworkError()
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
        
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "SearchResultCell"
//        
//        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
//        
//        if cell ==  nil {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
//        }
        
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            cell.artistNameLabel!.text = searchResult.artistName
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
