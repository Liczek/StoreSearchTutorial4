//
//  SearchResultCell.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 22.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    var downloadTask: URLSessionDownloadTask?
    
//MARK: - OUTLETS
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
        
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist name label: name")
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        
        // załadowanie obrazka do UIImageView
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
        
    }
    
    // skrolujac table view moze byc sytuacja ze cellka moze sciagac obrazek pomimo ze juz w jego miejsce ma sie wrzucic inny obrazek nowszy, dlatego trzeba w takiej sytuacji cancelowac sciaganie pierwszego obrazka ta czynnosc robi prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
    }


}
