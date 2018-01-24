//
//  GlobalAlert.swift
//  QuotesDemo
//
//  Created by MKolesov on 24/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    private static var alertController: UIAlertController?
    private static var isDisplaying = false
    
    class func show(with title: String, and message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { action in
                alertController.dismiss(animated: true, completion: {
                    Alert.isDisplaying = false
                })
            })
            alertController.addAction(actionOK)
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                Alert.isDisplaying = true
                Alert.alertController = alertController
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    class func dissmiss() {
        if Alert.isDisplaying, let alertController = Alert.alertController {
            alertController.dismiss(animated: true, completion: {
                Alert.isDisplaying = false
            })
        }
    }
}
