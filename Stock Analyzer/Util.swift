//
//  Util.swift
//  Stock Analyzer
//
//  Created by CAN on 2021/2/11.
//

import Foundation
import UIKit

func showConfirmAlert(root: UIViewController, title: String? = nil, msg: String? = nil, style: UIAlertAction.Style = UIAlertAction.Style.default) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: style, handler: nil))
        root.present(alert, animated: true, completion: nil)
    }
}
