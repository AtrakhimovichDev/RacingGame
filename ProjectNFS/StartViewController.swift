//
//  ViewController.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.05.21.
//

import UIKit

class ViewController: UIViewController {

    let startButton = UIButton()
    let scoreButton = UIButton()
    let settingsButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newImageView = UIImageView()
        newImageView.frame = view.bounds
        newImageView.image = UIImage(named: "start_background1")
        view.addSubview(newImageView)
        
        startButton.frame = CGRect(x: 500, y: 270, width: 150, height: 50)
        startButton.titleLabel?.font = UIFont(name: "DIN Alternate", size: 25)
        startButton.setTitleColor(#colorLiteral(red: 0.8666666667, green: 0.07058823529, blue: 0.4823529412, alpha: 1), for: .normal)
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 5
        startButton.layer.shadowColor = UIColor.white.cgColor
        startButton.layer.shadowOffset = .zero
        startButton.layer.shadowOpacity = 1
        startButton.layer.shadowRadius = 20
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchDown)
        startButton.titleLabel?.font = UIFont.jerseySharp(of: 25)
        view.addSubview(startButton)
        
        scoreButton.frame = CGRect(x: 500, y: 370, width: 150, height: 50)
        scoreButton.titleLabel?.font = UIFont(name: "DIN Alternate", size: 25)
        scoreButton.setTitleColor(#colorLiteral(red: 0.8666666667, green: 0.07058823529, blue: 0.4823529412, alpha: 1), for: .normal)
        scoreButton.setTitle("Score", for: .normal)
        scoreButton.backgroundColor = .white
        scoreButton.layer.cornerRadius = 5
        scoreButton.layer.shadowColor = UIColor.white.cgColor
        scoreButton.layer.shadowOffset = .zero
        scoreButton.layer.shadowOpacity = 1
        scoreButton.layer.shadowRadius = 20
        scoreButton.titleLabel?.font = UIFont.jerseySharp(of: 25)
        scoreButton.addTarget(self, action: #selector(scoreButtonPressed), for: .touchDown)
        
        settingsButton.frame = CGRect(x: 500, y: 470, width: 150, height: 50)
        settingsButton.titleLabel?.font = UIFont(name: "DIN Alternate", size: 25)
        settingsButton.setTitleColor(#colorLiteral(red: 0.8666666667, green: 0.07058823529, blue: 0.4823529412, alpha: 1), for: .normal)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.backgroundColor = .white
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.shadowColor = UIColor.white.cgColor
        settingsButton.layer.shadowOffset = .zero
        settingsButton.layer.shadowOpacity = 1
        settingsButton.layer.shadowRadius = 20
        settingsButton.titleLabel?.font = UIFont.jerseySharp(of: 25)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchDown)
        
        view.addSubview(startButton)
        view.addSubview(scoreButton)
        view.addSubview(settingsButton)
        UIView.animate(withDuration: 1, delay: 0, options: []) {
            self.startButton.frame.origin.x = 230
        }
        UIView.animate(withDuration: 1, delay: 0.2, options: []) {
            self.scoreButton.frame.origin.x = 230
        }
        UIView.animate(withDuration: 1, delay: 0.4, options: []) {
            self.settingsButton.frame.origin.x = 230
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func startButtonPressed() {
        UIView.animate(withDuration: 1, delay: 0, options: []) {
            self.settingsButton.frame.origin.y = self.view.frame.height + 50
        }
        UIView.animate(withDuration: 1, delay: 0.2, options: []) {
            self.scoreButton.frame.origin.y = self.view.frame.height + 50
        }
        UIView.animate(withDuration: 1, delay: 0.4, options: []) {
            self.startButton.frame.origin.y = self.view.frame.height + 50
        } completion: { _ in
            self.openGameScreen()
        }
    }
    
    private func openGameScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewController(identifier: "gameViewController")
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    @objc func scoreButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scoreVC = storyboard.instantiateViewController(identifier: "scoreViewController")
        navigationController?.pushViewController(scoreVC, animated: true)
    }
    
    @objc func settingsButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(identifier: "settingsViewController")
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    
}

