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
        
        // gradient z alpha 0 zmienia sie w alpha 1
        dimmingView.alpha = 0
                                        // transitionCoordinator powinien byc zawsze przy animacjach gdzie pojawia sie nowy view itp kontorluje on gładkie animacje - płynne, animacje powinny być zawsze umieszczone w alongsideTransition
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
            }, completion: nil)
        }
        
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                    self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
