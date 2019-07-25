//
//  ActivityIndicator.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/24/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showActivityIndicator() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func dismissActivityIndicator() {
        dismiss(animated: false, completion: nil)
    }
}
