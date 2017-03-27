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
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    //presentationTransitionWIllBegin method is invoked kiedy nowy view controller ma sie pojawić
    override func presentationTransitionWillBegin() {
        // tworzymy nowy view controller tak duży jak containerView
        dimmingView.frame = containerView!.bounds
        //wrzucamy ten widok za wszystkie inne poprzez okreslenie indexu 0
        containerView!.insertSubview(dimmingView, at: 0)
    }
}
