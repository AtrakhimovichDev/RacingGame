//
//  Car.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class Car {
    let carView = UIView()
    let carImageView = UIImageView()
    
    private let carSpeed: CGFloat = 5
    private let carRotateSpeed: TimeInterval = 0.2
    private let rotationAngel: CGFloat = 10 * .pi / 180
    private let carAnimationDuration: TimeInterval = 0.05
    private let carAnimationDelay: TimeInterval = 0
    private let carAnimationOptions: UIView.AnimationOptions = [.curveLinear]
   
    private var moovingCarAnimation: (() -> ())?
    private var moovingCarCompletion: ((Bool) -> ())?
    private var translationPosition: CGPoint = .zero
    private var carIsMooving = false
    
    func moveCar() {
        if !carIsMooving {
            if let moovingCarAnimation =  moovingCarAnimation ,
                  let moovingCarCompletion = moovingCarCompletion {
                UIView.animate(withDuration: self.carAnimationDuration, delay: self.carAnimationDelay, options: self.carAnimationOptions, animations: moovingCarAnimation, completion: moovingCarCompletion)
                carIsMooving = !carIsMooving
            }
        }
    }
    
    func rotateCar() {
        var rotateAngel: CGFloat = 0
        if carIsMooving {
            if self.translationPosition.x < 0 {
                rotateAngel = -self.rotationAngel
            } else {
                rotateAngel = self.rotationAngel
            }
        }
        UIView.animate(withDuration: carRotateSpeed, delay: 0, options: [.curveLinear]) {
            self.carImageView.transform = CGAffineTransform(rotationAngle: rotateAngel)
        } completion: { _ in }
    }
    
    func setTranslationPosition(translationPosition: CGPoint) {
        self.translationPosition = translationPosition
    }
    
    func setCarSettings(mainView: UIView) {
        setCarImageViewSettings(mainView: mainView)
        setAnimationRules(mainView: mainView)
    }
    
    func changeCarMoovingStatus() {
        carIsMooving = !carIsMooving
    }
    
    private func setCarImageViewSettings(mainView: UIView) {
        carView.frame.origin = CGPoint(x: mainView.frame.width / 2 - 30, y: mainView.bounds.height - 150 - 120)
        carView.frame.size = CGSize(width: 40, height: 80)
        
        carImageView.image = UIImage(named: "car_icon")
        carImageView.frame = carView.bounds
        
        carView.addSubview(carImageView)
        mainView.addSubview(carView)
    }
    
    private func setAnimationRules(mainView: UIView) {
        setMoovingCarAnimation(mainView: mainView)
        setMoovingCarCompletion(mainView: mainView)
    }
    
    private func setMoovingCarAnimation(mainView: UIView) {
        moovingCarAnimation = {
            if self.translationPosition.x < 0 {
                if self.carView.frame.origin.x >= 0 {
                    self.carView.frame.origin.x = self.carView.frame.origin.x - self.carSpeed
                }
            } else {
                if self.carView.frame.origin.x + 40 <= mainView.frame.width {
                    self.carView.frame.origin.x = self.carView.frame.origin.x + self.carSpeed
                }
            }
            if self.translationPosition.y > 0 {
                if self.carView.frame.maxY < mainView.frame.height {
                    self.carView.frame.origin.y = self.carView.frame.origin.y + self.carSpeed
                }
            } else {
                if self.carView.frame.origin.y > 0 {
                    self.carView.frame.origin.y = self.carView.frame.origin.y - self.carSpeed
                }
            }
        }
    }
    
    private func setMoovingCarCompletion(mainView: UIView) {
        moovingCarCompletion = {_ in
            if self.carIsMooving {
                if let moovingCarAnimation = self.moovingCarAnimation,
                   let moovingCarCompletion = self.moovingCarCompletion {
                UIView.animate(withDuration: self.carAnimationDuration, delay: self.carAnimationDelay, options: self.carAnimationOptions, animations: moovingCarAnimation, completion: moovingCarCompletion)
                }
            }
        }
    }
    
    
}
