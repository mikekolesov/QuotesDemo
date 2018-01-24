//
//  StatusViewController.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    let quoteProvider = QuoteProvider()
    var isScrolling = false
    var isChangingTools = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteProvider.delegate = self
        tableView.register(UINib(nibName: "QuoteHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "QuoteHeaderIdentifier")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isChangingTools {
            tableView.reloadData()
        }
        isChangingTools = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isChangingTools = true
    }
    
    @IBAction func editTapped(_ sender: Any) {
        editButton.title = tableView.isEditing ? "Edit" : "Done"
        isChangingTools = !tableView.isEditing
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

extension MainTableViewController: QuoteProviderDelegate {
    
    func quoteProviderDidUpdate(_ quoteIndexes: [Int]) {
        if isScrolling || isChangingTools {
            return
        }
        let indexPathsToUpdate = quoteIndexes.map { return IndexPath(row: $0, section: 0) }
        tableView.reloadRows(at: indexPathsToUpdate, with: .none)
    }
}

extension MainTableViewController {
    
    //MARK: Cells, header
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteProvider.numberOfQuotes
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteIdentifier", for: indexPath) as! QuoteCell
        if let quote = quoteProvider.quoteTick(at: indexPath.row) {
            cell.symbolLabel.text = quote.quote.symbolSlash()
            cell.bidAskLabel.text = quote.bid + " / " + quote.ask
            cell.spreadLabel.text = quote.spread
        }
        else {
            // should happend once pur quote
            cell.symbolLabel.text = "..."
            cell.bidAskLabel.text = "..."
            cell.spreadLabel.text = "..."
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "QuoteHeaderIdentifier") as! QuoteHeader
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 
    }
    
    //MARK: TableView editing
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
        return true
     }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        isChangingTools = true
    }
   
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        isChangingTools = false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let quoteToRemove = QuoteStorage.activeQuotes[indexPath.row]
            SubscriptionManager.shared.removeSubscription([quoteToRemove])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
       
    }
    
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var activeQuotes = QuoteStorage.activeQuotes
        activeQuotes.swapAt(fromIndexPath.row, to.row)
        QuoteStorage.activeQuotes = activeQuotes
     }
    
    
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
        return true
     }
    
    
}

extension MainTableViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolling = false
    }
}


