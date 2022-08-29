//
//  UIViewController+Extensions.swift
//  PostalCode
//
//  Created by João Pedro on 28/08/2022.
//

import UIKit

extension UIViewController {

    func getLoaderViewController() -> UIViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "LoaderViewController")
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
}
