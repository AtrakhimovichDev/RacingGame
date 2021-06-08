//
//  GameBackground.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 31.05.21.
//

import UIKit

class GameBackgroundUI {
    
    let imageViewFirst = UIImageView()
    let imageViewSecond = UIImageView()
    private let animationDelay: TimeInterval = 0
    private let animationOptions: UIView.AnimationOptions = [.curveLinear]
    
    private var animationDuration: TimeInterval = 0.03
    private var gameBackgroundType: GameBackgroundType
    private var image: UIImage
    private var moovingBackgroundAnimation: (() -> ())?
    private var moovingBackgroundCompletion: ((Bool) -> ())?
    var stopAnimation = false
    
    init(gameBackgroundType: GameBackgroundType) {
        self.gameBackgroundType = gameBackgroundType
        self.image = gameBackgroundType.getImage()
    }
    
    func startAnimation() {
        if let moovingBackgroundAnimation = self.moovingBackgroundAnimation,
           let moovingBackgroundCompletion = self.moovingBackgroundCompletion {
            UIView.animate(withDuration: self.animationDuration, delay: self.animationDelay, options: self.animationOptions, animations: moovingBackgroundAnimation, completion: moovingBackgroundCompletion)
        }
    }
    
    func setBackgroundSettings(backgroundViewBounds: CGRect) {
        setBackgroundImageViewsSettings(backgroundViewBounds: backgroundViewBounds)
        setAnimationRules(backgroundViewBounds: backgroundViewBounds)
    }
    
    private func setBackgroundImageViewsSettings(backgroundViewBounds: CGRect) {
        imageViewFirst.frame = backgroundViewBounds
        imageViewFirst.image = image
        
        imageViewSecond.frame = backgroundViewBounds
        imageViewSecond.frame.origin.y = -backgroundViewBounds.height
        imageViewSecond.image = image
    }
    
    private func setAnimationRules(backgroundViewBounds: CGRect) {
        setMoovingBackgroundAnimation()
        setMoovingBackgroundCompletion(backgroundViewBounds: backgroundViewBounds)
    }
    
    private func setMoovingBackgroundAnimation() {
        moovingBackgroundAnimation = {
            self.imageViewFirst.frame.origin.y += 10
            self.imageViewSecond.frame.origin.y += 10
        }
    }
    
    private func setMoovingBackgroundCompletion(backgroundViewBounds: CGRect) {
        moovingBackgroundCompletion = {_ in
            if self.stopAnimation {
                return
            }
            if self.imageViewFirst.frame.origin.y >= backgroundViewBounds.height {
                self.imageViewFirst.frame.origin.y = 5
                self.imageViewSecond.frame.origin.y = -backgroundViewBounds.height + 5
            }
            self.startAnimation()
        }
    }
}
