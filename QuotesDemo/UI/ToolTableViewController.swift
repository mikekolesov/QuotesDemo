//
//  ToolTableViewController.swift
//  QuotesDemo
//
//  Created by MKolesov on 23/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import UIKit

class ToolTableViewController: UITableViewController {

    var activeQuotes:[Quote] = []
    var originalActiveQuotes:[Quote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // local copy
        activeQuotes = QuoteStorage.activeQuotes
        originalActiveQuotes = activeQuotes
    }

    @IBAction func closeTapped(_ sender: Any) {
        
        QuoteStorage.activeQuotes = activeQuotes
        
        let toSubscribe = activeQuotes.filter { (quoteType) -> Bool in
            return !originalActiveQuotes.contains(quoteType)
        }
        SubscriptionManager.shared.addSubscriptions(toSubscribe)
        
        let toUnSubscribe = originalActiveQuotes.filter { (quoteType) -> Bool in
            return !activeQuotes.contains(quoteType)
        }
        SubscriptionManager.shared.removeSubscription(toUnSubscribe)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func isQuoteActive(_ quoteType: Quote) ->Bool {
        return activeQuotes.contains(quoteType)
    }
}

extension ToolTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Quote.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolCell", for: indexPath)
        
        let quoteType = Quote.all[indexPath.row]
        cell.textLabel?.text = quoteType.symbol()
        cell.accessoryType = isQuoteActive(quoteType) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quoteType = Quote.all[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            let isCurrenlyActive = isQuoteActive(quoteType)
            if isCurrenlyActive {
                if let index = activeQuotes.index(of: quoteType) {
                    activeQuotes.remove(at: index)
                }
                cell.accessoryType = .none
            } else {
                activeQuotes.append(quoteType)
                cell.accessoryType = .checkmark
            }
        }
        
    }

}
