//
//  AppDelegate.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Run Subscription service
        SubscriptionManager.shared.renewSubscription()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        print("Going to background. Cancel all subscriptions")
        SubscriptionManager.shared.cancelSubscription()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        print("Going back to foreground. Set up previous subscriptions")
        SubscriptionManager.shared.renewSubscription()
    }

}

