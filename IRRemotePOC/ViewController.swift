//
//  ViewController.swift
//  IRRemotePOC
//
//  Created by Tilak Kumar on 24/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectBarButton: UIBarButtonItem!
    fileprivate var viewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel = MainViewModel()
        viewModel?.viewModelDelegate = self
        self.viewModel?.setup()
        
        self.tableView.delegate = self.viewModel
        self.tableView.dataSource = self.viewModel
    }
    
    @IBAction func connectClicked(_ sender: Any) {
        self.viewModel?.connectToDevice()
    }
}

extension ViewController: MainViewModelDelegate {
    func showError(message: String) {
        let alertVC = UIAlertController.init(title: "BLE", message:message, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func changeConnectButton(state: Bool) {
        self.connectBarButton.isEnabled = state
    }
    
    func updateTitle(text: String) {
        self.title = text
    }
}

