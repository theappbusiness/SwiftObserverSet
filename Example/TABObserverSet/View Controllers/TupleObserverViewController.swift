//
//  TupleObserverViewController.swift
//  TABObserverSet
//
//  Created by Luqman Fauzi on 20/08/2017.
//  Copyright © 2017 Kin + Carta. All rights reserved.
//

import UIKit
import TABObserverSet

fileprivate let reuseIdentifier = "TupleObserverCell"
fileprivate typealias Grocery = (String, Int)

final class TupleObserverViewController: UITableViewController {

    fileprivate let inputObserver = ObserverSet<Grocery>()
    fileprivate var groceries: [Grocery] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        inputObserver.add(self, TupleObserverViewController.addNewItem)
    }

    @IBAction fileprivate func addButtonItemDidTap(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Add Grocery",
            message: "Please insert a new grocery.",
            preferredStyle: .alert
        )

        alertController.presentGroceryInput(self, observer: inputObserver)
    }

    /// Handle the observer event callback
    fileprivate func addNewItem(_ grocery: Grocery) {
        tableView.beginUpdates()
        groceries.insert(grocery, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        tableView.endUpdates()
    }
}

extension TupleObserverViewController {

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let name: String = groceries[indexPath.row].0
        let amount: Int = groceries[indexPath.row].1

        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "Amount: \(amount)"

        return cell
    }
}
