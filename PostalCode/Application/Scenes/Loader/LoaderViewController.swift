//
//  LoaderViewController.swift
//  PostalCode
//
//  Created by João Pedro on 29/08/2022.
//

import UIKit

class LoaderViewController: UIViewController {


    @IBOutlet weak var loaderLabel: UILabel! {
        didSet {
            loaderLabel.text = "Loading your available Postal Codes"
        }
    }
    
    @IBOutlet weak var loaderIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderIndicatorView.startAnimating()
    }
}
