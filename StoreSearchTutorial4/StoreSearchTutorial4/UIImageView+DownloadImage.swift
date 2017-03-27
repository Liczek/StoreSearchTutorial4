//
//  UIImageView+DownloadImage.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 26.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // downloadTask sciaga pliki na dysk zamiast trzymac w pamięci, url to sciezka do miejsca na dysku gdzie sa zapisane, majac url mozna load Data i zrobic z niego obrazy UIImage  [weak self] jest istotny bo rozbija ownership cycle czyli zależnść która nie pozwala zabić obiektu 2x strong
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
        
            if error == nil, let url = url,
                             // sprawdzamy czy data istnieje czy nie jest to np error 404 strony czy jakis inny problem zly format danych itp
                             let data = try? Data(contentsOf: url),
                             //
                             let image = UIImage(data: data) {
                //mając obraz musisz go wrzucic do UIImageView a jako ze jest to UI to trzeba to zrobic w main thread w pierwszej kolejce - głównej
                DispatchQueue.main.async {
                    // ten if sprawdza czy w czasie jak pobieraly i tworzyly sie zdjecia użytkownik nie usunął UIImageView np wychodząc z danego UIView, wtedy nie byłoby gdzie wrzucić zrobionych UIImage i apka by sie crashnęła
                    if let strongSelf = self {
                        //strongSelf == UIImageView bo do tej classy robimy właśnie extension
                        strongSelf.image = image
                    }
                }
            }
        })
        // po stworzeniu dowload taska należy go uruchomić używając .resume
        downloadTask.resume()
        return downloadTask
    }
}
