//
//  ViewController+Alert.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 3.06.21.
//

import UIKit

extension GameViewController {
    func showExitAlert(handler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Quit game", message: "Are you realy want to quit the game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: handler))
        alert.addAction(UIAlertAction(title: "Resume", style: .default))
        present(alert, animated: true)
    }
}
