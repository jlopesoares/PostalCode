//
//  UIViewController+Extensions.swift
//  PostalCode
//
//  Created by João Pedro on 28/08/2022.
//

import UIKit

extension UIViewController {

    func getLoaderViewController() -> UIViewController {
        
        let viewController = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: .main).instantiateViewController(withIdentifier: Constants.loaderViewControllerIdentifier)
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
}

private struct Constants {
    
    static let mainStoryboardIdentifier = "Main"
    static let loaderViewControllerIdentifier = "LoaderViewController"
}
