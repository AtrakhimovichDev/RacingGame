//
//  SettingsViewController.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.05.21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.frame.origin = CGPoint(x: view.frame.maxX - backButton.frame.width, y: 30)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
