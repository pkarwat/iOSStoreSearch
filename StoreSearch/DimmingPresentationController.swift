//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Patryk on 08.12.2016.
//  Copyright © 2016 Patryk. All rights reserved.
//

import Foundation
import UIKit

//animation for Detail popup
class DimmingPresentationController: UIPresentationController {
    
    lazy var dimingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        dimingView.frame = containerView!.bounds
        containerView!.insertSubview(dimingView, at: 0)
        
        //animation
        dimingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimingView.alpha = 1
            }, completion: nil)
        }
    }
    
    //animation
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimingView.alpha = 0
            }, completion: nil)
        }
    }
    
}
