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
    
    let search = Search()
    
    var landscapeViewController: LandscapeViewController?
    
    // optional bo może być nil jeśli uruchomimy na iPhone
    weak var splitViewDetail: DetailViewController?
    
//MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        
        tableView.rowHeight = 80
        //ukrywanie klawiatury przy swipie
        tableView.keyboardDismissMode = .interactive
        // żeby wydobyć rowsy ukryte pod search barem i segment controlerem
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        //klawiatura sie pojawia na starcie
        
        //żeby na iPad nie było klawiatury na starcie
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
        
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
        
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) || // portrait
            (rect.width == 414 && rect.height == 736) { // landscape
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
        // WYJAŚNIENIE strona 171 bardzo istotne
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Table Views
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.resignFirstResponder()
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            //jako że nie można zrobić segue bezpośrednio z cellki bo cellka jest reusable a nie static jak we wcześniejszych tutorialach, to trzeba pociągnąć ją z całego View i zrobić perform segue przy tapie na row
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            
            // allVisible występuje tylko w landscape wtedy urchamiamy funkcje hideMasterPane
            if splitViewController!.displayMode != .allVisible {
                hideMasterPane()
            }
        }
    }
    
    // uniemożliwia wybranie wiersza gdy searchResults.count zwraca 0 po wyszukaniu
    // tapnięcie na row jest możliwe tylko jeśli state.results
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
            // nie trzeba przypisywac wartości search.result do niczego bo tu ta warość nie jest nam potrzebna
        case .results:
            return indexPath
        }
    }
    
//MARK: - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            
            //tu interesuje nas tylko case .results żeby nie byłotrzeba wypisywać wszystkich case to używamy if case statement
            
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                // tableViews didSelectRowFor perform segue
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                // poprzez indexPath.row ustalamy konkretny SsearchResult i implikujemy go do searchResult w DetailViewController
                detailViewController.searchResult = searchResult
                // zeby popup View pojawiało się na iPhonach
                detailViewController.isPopUp = true
            }
        }
    }
    
//MARK: - STRUCTS
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
//MARK: - RANDOM METHODS
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            //każdy split-view ma wbudowane opcje wyswietlania primaryHidden ukrywa masterViewPane
        self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: {_ in
            //completion powoduje przelaczenie sie mode do .automatic po zakonczeniu animacji, w momencie przekrecenia w landscape master view pane bedzie widoczny
        self.splitViewController!.preferredDisplayMode = .automatic
        })
    }
    
        
//MARK: - Landscape Mode
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeViewController == nil else { return }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            // przekazanie searchResults arrey do LandscapeViewController
            controller.search = search
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
                //ten if statement sprawdza, czy jest wyświetlony dodatkowy ViewControlle chodzi tu o DetailVC jeśli tak to go dissmisuje
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
}

//MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        search.performSearch(for: searchBar.text!, category: category, completion: { success in
            //sleep(Int) wrzuca aplikacje w sen na okreslony czas super do testowania
            sleep(2)
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
            // jeśli otrzymamy success w wyszukiwaniu to robimy reload SearchViewController.tableView lub jeśli w międzyczasie obruciliśmy ekran i mamy LandscapeVViewControler dlatego jest ? implikujemy searchResultsReceived który tworzy buttony
            self.landscapeViewController?.searchResultsReceived()
        })        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        }
    }
    
    
    //UIBarPositionDelegate ma możliwość połączenia się z innymi obiektami w tym wypadku z UISearchBarem
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whooops....", comment: "Error alert: title"), message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again", comment: "Error alert: message"), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm Action button: agree"), style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}
