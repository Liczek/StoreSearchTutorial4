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
    
    var searchResults = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // żeby wydobyć rowsy ukryte pod search barem
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //za każdym razem gdy odpala się funkcję tworzony jest nowa arrey searchResult jeśli istniała wcześniej to stara zostaje usunięta i powstaje nowa pusta, którą napełniamy poprzez append
        searchResults = []
        
        for i in 0...2 {
            // %d - placeholder for ints, %f - placeholder for floatings z miejscem po przecinku, %@ - placeholder dla wszystkich pozostałych objektów np. Sting
            // Tworzenie string w miejsce % wstawia pierwszy obiekt po przecinku, w miejsce drugiego % kolejny po przecinku itd.
            searchResults.append(String(format: "Fake Result %d for '%@'", i, searchBar.text!))
        }
        
        tableView.reloadData()
        
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell ==  nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel!.text = searchResults[indexPath.row]
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
