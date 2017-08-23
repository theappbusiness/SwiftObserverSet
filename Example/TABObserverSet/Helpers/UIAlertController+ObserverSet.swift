//
//  UIAlertController+ObserverSet.swift
//  TABObserverSet
//
//  Created by Luqman Fauzi on 20/08/2017.
//  Copyright © 2017 The App Business. All rights reserved.
//

import UIKit
import TABObserverSet

extension UIAlertController {

    typealias Grocery = (String, Int)

    func presentGroceryInput<T: UIViewController>(_ target: T, observer: ObserverSet<Grocery>) {

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let add = UIAlertAction(title: "Add", style: .default) { (_) in

            let textInput = self.textFields?[0].text ?? ""
            let indexInput = self.textFields?[1].text ?? ""

            let grocery = (textInput, Int(indexInput) ?? 0)

            /// Broadcast the observee which contains a tuple value of string & integer.
            observer.notify(grocery)
        }

        self.addTextField { (textField) in
            textField.placeholder = "Enter name"
        }

        self.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter amount"
        }

        self.addAction(add)
        self.addAction(cancel)

        target.present(self, animated: true, completion: nil)
    }
}
