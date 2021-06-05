//
//  Game.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 24.05.21.
//

import UIKit

class GameUI {
    
    private let readyStadyGoImageView = UIImageView()
    //private let oneImage = UIImage(named: "one_icon")
    //private let twoImage = UIImage(named: "two_icon")
    //private let threeImage = UIImage(named: "three_icon")
    
    private let outsideCircleControlView = UIView()
    private let insideCircleControlView = UIView()
    
    private var firstStepNumbersAnimation: (() -> ())?
    private var secondStepNumbersAnimation: (() -> ())?
    private var firstStepNumbersComplition: ((Bool) -> ())?
    private var secondStepNumbersComplition: ((Bool) -> ())?
    private var lastStepNumbersComplition: ((Bool) -> ())?
    
    private var endAnimation = false
    
    func startAnimation(mainView: UIView, lastComplition: @escaping (Bool) -> ()) {
        if let firstStepNumbersAnimation = self.firstStepNumbersAnimation,
           let firstStepNumbersComplition = self.firstStepNumbersComplition {
            UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: firstStepNumbersAnimation, completion: firstStepNumbersComplition)
        }
        lastStepNumbersComplition = lastComplition
    }
    
    func setGameUISettings(mainView: UIView) {
        
        setStartAnimationSettings(mainView: mainView)
        
        outsideCircleControlView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        outsideCircleControlView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        outsideCircleControlView.layer.cornerRadius = 50
        outsideCircleControlView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        outsideCircleControlView.layer.borderWidth = 2
        outsideCircleControlView.alpha = 0.6
        outsideCircleControlView.isHidden = true

        insideCircleControlView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        insideCircleControlView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        insideCircleControlView.layer.cornerRadius = 25
        insideCircleControlView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        insideCircleControlView.layer.borderWidth = 1
        insideCircleControlView.alpha = 0.8
        insideCircleControlView.isHidden = true
        outsideCircleControlView.addSubview(insideCircleControlView)
               
        mainView.addSubview(outsideCircleControlView)

        setAnimationRules(mainView: mainView)
    }
        
    func setStartAnimationSettings(mainView: UIView) {
        endAnimation = false
        readyStadyGoImageView.frame = CGRect(x: mainView.frame.width, y: 350, width: 50, height: 70)
        readyStadyGoImageView.image = UIImage.getImage(named: .three)
        mainView.addSubview(readyStadyGoImageView)
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
                if let firstStepNumbersAnimation = self.firstStepNumbersAnimation,
                   let lastStepNumbersComplition = self.lastStepNumbersComplition {
                    UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: firstStepNumbersAnimation, completion: lastStepNumbersComplition)
                }
                self.readyStadyGoImageView.removeFromSuperview()
            }
        }
            
    }
    
    private func changeNumberImage() {
        if readyStadyGoImageView.image == UIImage.getImage(named: .three) {
            readyStadyGoImageView.image = UIImage.getImage(named: .two)
        } else if readyStadyGoImageView.image == UIImage.getImage(named: .two) {
            readyStadyGoImageView.image = UIImage.getImage(named: .one)
        } else {
            endAnimation = true
        }
    }
    
    func showPanGestureControlView(selectorLocation: CGPoint) {
        outsideCircleControlView.center = selectorLocation
        insideCircleControlView.center = CGPoint(x: outsideCircleControlView.frame.width / 2, y: outsideCircleControlView.frame.height / 2)
        insideCircleControlView.isHidden = false
        outsideCircleControlView.isHidden = false
    }
    
    func hidePanGestureControlView() {
        insideCircleControlView.isHidden = true
        outsideCircleControlView.isHidden = true
    }
    
    func moveInsideControlCircle(translation: CGPoint) {
        let newPositionControlCircle = getControlCircleNewPosition(translation: translation)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: newPositionControlCircle)
    }

    private func getControlCircleNewPosition(translation: CGPoint) -> () -> () {
        var newPosition: () -> ()
        let diagonalPosition = outsideCircleControlView.frame.width / 2 - CGFloat(sqrt(25 * 25 / 2))
        if translation.x < -25 {
            if translation.y < -25 {
                newPosition = {
                    self.insideCircleControlView.center.x = diagonalPosition
                    self.insideCircleControlView.center.y = diagonalPosition
                }
            } else if translation.y > 25 {
                newPosition = {
                    self.insideCircleControlView.center.x = diagonalPosition
                    self.insideCircleControlView.center.y = self.outsideCircleControlView.frame.height - diagonalPosition
                }
            } else {
                newPosition = {
                    self.insideCircleControlView.center.x = 25
                    self.insideCircleControlView.center.y = self.outsideCircleControlView.frame.height / 2
                }
            }
        } else if translation.x > 25 {
            if translation.y < -25 {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width - diagonalPosition
                    self.insideCircleControlView.center.y = diagonalPosition
                }
            } else if translation.y > 25 {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width - diagonalPosition
                    self.insideCircleControlView.center.y = self.outsideCircleControlView.frame.height - diagonalPosition
                }
            } else {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width - 25
                    self.insideCircleControlView.center.y = self.outsideCircleControlView.frame.height / 2
                }
            }
        } else {
            if translation.y < -25 {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width / 2
                    self.insideCircleControlView.center.y = 25
                }
            } else if translation.y > 25 {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width / 2
                    self.insideCircleControlView.center.y = self.outsideCircleControlView.frame.height - 25
                }
            } else {
                newPosition = {
                    self.insideCircleControlView.center.x = self.outsideCircleControlView.frame.width / 2
                    self.insideCircleControlView.center = CGPoint(x: self.outsideCircleControlView.frame.width / 2, y: self.outsideCircleControlView.frame.height / 2)
                }
            }
        }
        return newPosition
    }
    
}
