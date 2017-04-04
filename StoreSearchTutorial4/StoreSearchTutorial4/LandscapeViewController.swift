//
//  LandscapeViewController.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 28.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    var search: Search!
    private var firstTime = true
    //tworzymy arreyke wszystklich downloadTasków aby byłomożna je w razie potrzeby szybko cancelować w deinit jeśli nie będziemy jednak już potrzebować ściągać obrazków z serwera
    private var downloadTasks = [URLSessionDownloadTask]()
    
//MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
//MARK: - VIEWS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Wyłączenie Auto Layout w tym VIEW
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        // ustawienie tła z obrazka ustawia obrazek jeden przy drugim jako kolor
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        // podział scrollView na strony i określenie liczby stron
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = 0
    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        // jeśli nie możemy jeszcze wypełnić statów poszczególnych to w case robimy break
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Actions
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                                    y: 0)
        },
        completion: nil)
        
    }
    
//MARK: - METHODS
    
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
            
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92

        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddinfVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var column = 0
        var x = marginX
        
        for (index, searchResult) in searchResults.enumerated() {
            
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddinfVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            scrollView.addSubview(button)
            
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            //dodanie ściągniętego obrazka
            downloadImage(for: searchResult, andPlaceOn: button)
            
            // buttony ida w kolumnach od gory do dołu, aż do momentu row == rowsPerPage wtedy dodaje sie += 1 column
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                // jak dojdziemy do ostatniej kolumny to dodajemy margines ostatni na jej stronie i pierwszy na kolejnej dlatego * 2
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        // dlatego +1 bo jak searchResults.count bedzie mniejszy niz buttons per Page to daloby wynik 0 stron
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth,
                                        height: scrollView.bounds.size.height)
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        print("Number of pages: \(numPages)")
        
    }
    
    //jako że buttony tworzyliśmy codem to segue tez musimy zorbić z programu czyli najpierw perform a nastepnie prepare for segue
    func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.artworkSmallURL) {
            let downloadTask = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
                if error == nil, let url = url,
                                 let data = try? Data(contentsOf: url),
                                 let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            downloadTask.resume()
            //dodajemy kolejno wszystkie zadania ściągnięcia obrazka do arreyki downloadTasków
            downloadTasks.append(downloadTask)
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        // spiner ma 37 punktów w: 37 h: 37 więc jak byśmy go wrzucili na środku to byłby np na x:265.5, y:141.5 to spowodowałoby że spiner byłby zamazany żeby tego uniknąć trzeba dodać pół punkta
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5,
                                 y: scrollView.bounds.midY + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "Nothing Found Label: text")
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        //dopasowanie rozmiaru labela do textu tak jak Win + = w storyboard
        label.sizeToFit()
        
        var rect = label.frame
        
        // ceil służy do zaokrąglania wartości jeśli label miałby w: 13 to dzielimy go na pół 6.5 zaokrąglamy do 7 i mnożymy x 2 wszystko to trzeba robic jak są to CGFloat bo mogą być ułamkiem w Int nie ma takiej potrzeby
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height/2) * 2
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX,
                               y: scrollView.bounds.midY)
        view.addSubview(label)
    }
    

    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //
    deinit {
        print("deinit \(self)")
        // w momencie deallokacji View który polecił ściągnięcie obrazków (np obrócenie obrazu w portret view) deint likwiduje wszsytkie taski z arrey donloadTaskS jeden po drugim
        for task in downloadTasks {
            task.cancel()
        }
    }
    
//MARK: - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                //zamiast otrzymania indexPath poprostu wyliczamy go sobie z button.tag pomniejszonego o wcześniej dodane 2000, teraz pozostało dodanie segue w storyboardzie
                let searchResult = list[(sender as! UIButton).tag - 2000]
                detailViewController.searchResult = searchResult
                // zeby popup View pojawiało się na iPhonach
                detailViewController.isPopUp = true
            }
        }
    }
    
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        //contentOffset.x określa index strony chyba liczone od 1
        let curentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControl.currentPage = curentPage
    }
}
