//
//  LandscapeViewController.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 28.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    private var firstTime = true
    
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
        // bardzo ważne żeby to ustawić określa to rozmiar widoku w scrollView dzieki czemu jest co skrolowac
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        print("deinit \(self)")
    }
    
}
