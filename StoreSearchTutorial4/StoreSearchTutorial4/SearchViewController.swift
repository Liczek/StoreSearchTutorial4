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
        tableView.keyboardDismissMode = .interactive
        // żeby wydobyć rowsy ukryte pod search barem
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Table Views
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    



}



//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        //za każdym razem gdy odpala się funkcję tworzony jest nowa arrey searchResult jeśli istniała wcześniej to stara zostaje usunięta i powstaje nowa pusta, którą napełniamy poprzez append
        searchResults = []
        
        if searchBar.text! != "justin bieber" {
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake Result %d for", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
            
            // %d - placeholder for ints, %f - placeholder for floatings z miejscem po przecinku, %@ - placeholder dla wszystkich pozostałych objektów np. Sting
            // Tworzenie string w miejsce % wstawia pierwszy obiekt po przecinku, w miejsce drugiego % kolejny po przecinku itd.
            //searchResults.append(String(format: "Fake Result %d for '%@'", i, searchBar.text!))
            }
        }
        hasSearched = true
        tableView.reloadData()
        
    }
    
    //UIBarPositionDelegate ma możliwość połączenia się z innymi obiektami w tym wypadku z UISearchBarem
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell ==  nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = "(justin bieber not exist in iTunes)"
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
