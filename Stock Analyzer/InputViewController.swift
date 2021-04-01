//
//  InputViewController.swift
//  Stock Analyzer
//
//  Created by CAN on 2021/1/28.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet weak var inputStock: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onConfirmInputStock(_ sender: Any) {
        var stockTicker: String = inputStock.text ?? "";
        stockTicker = stockTicker.trimmingCharacters(in: CharacterSet.whitespaces);
        if (stockTicker.isEmpty) {
            showConfirmAlert(root: self, msg: "Please input stock ticker.")
        } else{
            let homeView = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
            homeView.stockTicker = stockTicker
            homeView.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(homeView, animated: true)
        }
    }
}

