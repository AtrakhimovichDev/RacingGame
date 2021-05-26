//
//  Game.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 24.05.21.
//

import UIKit

class GameInterface {
    private var endAnimation = false
    private let oneImage = UIImage(named: "one_icon")
    private let twoImage = UIImage(named: "two_icon")
    private let threeImage = UIImage(named: "three_icon")
    private let readyStadyGoImageView = UIImageView()
    private let scoreLabel = UILabel()
    var score = 0 {
        didSet {
            self.scoreLabel.text = "Score \(score)"
        }
    }
   
    private var firstStepNumbersAnimation: (() -> ())?
    private var secondStepNumbersAnimation: (() -> ())?
    private var firstStepNumbersComplition: ((Bool) -> ())?
    private var secondStepNumbersComplition: ((Bool) -> ())?
    
    func startAnimation(mainView: UIView) {
        if let firstStepNumbersAnimation = self.firstStepNumbersAnimation,
           let firstStepNumbersComplition = self.firstStepNumbersComplition {
            UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: firstStepNumbersAnimation, completion: firstStepNumbersComplition)
        }
    }
    
    func setGameUISettings(mainView: UIView) {
        scoreLabel.frame = CGRect(x: mainView.frame.width / 2 - 50, y: 10, width: 100, height: 30)
        scoreLabel.textColor = .white
        mainView.addSubview(scoreLabel)
        
        readyStadyGoImageView.frame = CGRect(x: mainView.frame.width, y: 350, width: 50, height: 70)
        readyStadyGoImageView.image = UIImage(named: "three_icon")
        mainView.addSubview(readyStadyGoImageView)

        let constX = NSLayoutConstraint(item: scoreLabel, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1, constant: 300)
        mainView.addConstraint(constX)
        
        setAnimationRules(mainView: mainView)
    }
    
    private func setAnimationRules(mainView: UIView) {
        firstStepNumbersAnimation = {
            self.readyStadyGoImageView.frame = CGRect(x: mainView.frame.width / 2 - 37, y: 350, width: 75, height: 105)
        }
        
        secondStepNumbersAnimation = {
            self.readyStadyGoImageView.frame = CGRect(x: -50, y: 350, width: 50, height: 70)
        }
        
        firstStepNumbersComplition = { _ in
            if let secondStepNumbersAnimation = self.secondStepNumbersAnimation,
               let secondStepNumbersComplition = self.secondStepNumbersComplition {
                UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: secondStepNumbersAnimation, completion: secondStepNumbersComplition)
            }
        }
        
        secondStepNumbersComplition = { _ in
            self.changeNumberImage()
            if !self.endAnimation {
                self.readyStadyGoImageView.frame.origin.x = mainView.frame.width
                if let firstStepNumbersAnimation = self.firstStepNumbersAnimation,
                   let firstStepNumbersComplition = self.firstStepNumbersComplition {
                    UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: firstStepNumbersAnimation, completion: firstStepNumbersComplition)
                }
            } else {
                self.readyStadyGoImageView.removeFromSuperview()
            }
        }
            
    }
    
    private func changeNumberImage() {
        if readyStadyGoImageView.image == threeImage {
            readyStadyGoImageView.image = twoImage
        } else if readyStadyGoImageView.image == twoImage {
            readyStadyGoImageView.image = oneImage
        } else {
            endAnimation = true
        }
    }
    
    
}
