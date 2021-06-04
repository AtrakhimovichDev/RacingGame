//
//  Car.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class CarUI {
    let carView = UIView()
    let carImageView = UIImageView()
    
    private let carSpeed: CGFloat = 6
    private let carRotateSpeed: TimeInterval = 0.2
    private let rotationAngel: CGFloat = 10 * .pi / 180
    private let carAnimationDuration: TimeInterval = 0.05
    private let carAnimationDelay: TimeInterval = 0
    private let carAnimationOptions: UIView.AnimationOptions = [.curveLinear]
   
    private var moovingCarAnimation: (() -> ())?
    private var moovingCarCompletion: ((Bool) -> ())?
    private var translationPosition: CGPoint = .zero
    private var carHeight: CGFloat = 80
    private var carWidth: CGFloat = 40
    private var controlAllowance: CGFloat = 25
    private var carIsMooving = false
    
    var afterCrash = false
    
    func setStartPosition(mainViewSize: CGSize) {
        carView.frame.origin = CGPoint(x: mainViewSize.width / 2 - carWidth / 2, y: mainViewSize.height - carHeight - 100)
    }
    
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
            if self.translationPosition.x < -self.controlAllowance {
                rotateAngel = -self.rotationAngel
            } else if self.translationPosition.x > self.controlAllowance {
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
    
    func setCarSettings(mainViewSize: CGSize) {
        setCarImageViewSettings(mainViewSize: mainViewSize)
        setAnimationRules(mainViewSize: mainViewSize)
    }
    
    func changeCarMoovingStatus() {
        carIsMooving = !carIsMooving
    }
    
    private func setCarImageViewSettings(mainViewSize: CGSize) {
        carView.frame.origin = CGPoint(x: mainViewSize.width / 2 - carWidth / 2, y: mainViewSize.height - carHeight - 100)
        carView.frame.size = CGSize(width: carWidth, height: carHeight)
        carImageView.image = UIImage(named: "car_icon")
        carImageView.frame = carView.bounds

        carView.addSubview(carImageView)
    }
    
    private func setAnimationRules(mainViewSize: CGSize) {
        setMoovingCarAnimation(mainViewSize: mainViewSize)
        setMoovingCarCompletion()
    }
    
    private func setMoovingCarAnimation(mainViewSize: CGSize) {
        moovingCarAnimation = {
            if self.translationPosition.x < -self.controlAllowance {
                if self.carView.frame.origin.x >= 0 {
                    self.carView.frame.origin.x -= self.carSpeed
                }
            } else if self.translationPosition.x > self.controlAllowance {
                if self.carView.frame.origin.x + self.carWidth <= mainViewSize.width {
                    self.carView.frame.origin.x += self.carSpeed
                }
            }
            if self.translationPosition.y > self.controlAllowance {
                if self.carView.frame.maxY < mainViewSize.height {
                    self.carView.frame.origin.y += self.carSpeed
                }
            } else if self.translationPosition.y < -self.controlAllowance {
                if self.carView.frame.origin.y > 0 {
                    self.carView.frame.origin.y -= self.carSpeed
                }
            }
        }
    }
    
    private func setMoovingCarCompletion() {
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
