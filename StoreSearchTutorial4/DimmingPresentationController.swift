//
//  DimmingPresentationController.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 26.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation
import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
