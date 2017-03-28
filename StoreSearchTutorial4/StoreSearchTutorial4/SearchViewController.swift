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
    @IBOutlet weak var segmentedControl: UISegmentedControl!

//MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
//MARK: - Variables and constants
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    var dataTask: URLSessionDataTask?
    
    var landscapeViewController: LandscapeViewController?
    
//MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        //ukrywanie klawiatury przy swipie
        tableView.keyboardDismissMode = .interactive
        // żeby wydobyć rowsy ukryte pod search barem i segment controlerem
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // WYJAŚNIENIE strona 171 bardzo istotne
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Table Views
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //jako że nie można zrobić segue bezpośrednio z cellki bo cellka jest reusable a nie static jak we wcześniejszych tutorialach, to trzeba pociągnąć ją z całego View i zrobić perform segue przy tapie na row
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    // uniemożliwia wybranie wiersza gdy searchResults.count zwraca 0 po wyszukaniu
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
//MARK: - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
//MARK: - STRUCTS
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
//MARK: - RANDOM METHODS
    
    func iTunesURL(searchText: String, category: Int) -> URL {
        
        //przypisanie do Segment Control indexów wrapperTypes z JSON
        let entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        //poniższa linijka jest po zeby było można spacje wyszukiwać
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        //&limit=200 ustawia z default limit = 50 na 200 wyników
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
        return url!
    }
    
//MARK: - Landscape Mode
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeViewController == nil else { return }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            // przekazanie searchResults arrey do LandscapeViewController
            controller.searchResults = searchResults
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { _ in
            controller.view.alpha = 1
            self.searchBar.resignFirstResponder()
                // presented View Controller sprawdza czy istnieje pop-up view
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
            controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
            controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    

//MARK: - PARSEs for JSON
    
    //dzielenie Dictionaries otrzymanych z apple (każdy disctionary to jeden wynik wyszukiwania)
    // tym parse dzielimy array na dictionary [String: Any]
    func parse(json data: Data) -> [String: Any]? {
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }


}

//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            // w celu stworzenia url w funkcje iTunesURL wrzucamy wartosci czyli wyszukiwany text i index segmentu ktory zostaje w funkcji iTunesURl przelozony na string okreslajacy kategorie
            let url = self.iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            
            let session = URLSession.shared
            
            // opcja 1
//            let dataTask = session.dataTask(with: url, completionHandler: {
//                (data: Data?, response: URLResponse? , error: Error?) in
            // opcja 2
            dataTask = session.dataTask(with: url) {
                data, response, error in
                print("On main thread?" + (Thread.current.isMainThread ? "Yes" : "No"))
                if let error = error as? NSError, error.code == -999 {
                    print("Failure! \(error)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data, let jsonDictionary = self.parse(json: data) {
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                
            }
            
            dataTask?.resume()
            
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
            cell.configure(for: searchResult)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
