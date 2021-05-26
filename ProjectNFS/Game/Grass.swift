//
//  Grass.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class Grass {
    private let leftGrassImageViewFirst = UIImageView()
    private let leftGrassImageViewSecond = UIImageView()
    private let rightGrassImageViewFirst = UIImageView()
    private let rightGrassImageViewSecond = UIImageView()
    
    private let grassAnimationDuration: TimeInterval = 3
    private let grassAnimationDelay: TimeInterval = 0
    private let grassAnimationOptions: UIView.AnimationOptions = [.curveLinear]
    private var moovingGrassAnimation: (() -> ())?
    private var moovingGrassCompletion: ((Bool) -> ())?
    
    func startAnimation() {
        if let moovingGrassAnimation = self.moovingGrassAnimation,
           let moovingGrassCompletion = self.moovingGrassCompletion {
            UIView.animate(withDuration: self.grassAnimationDuration, delay: self.grassAnimationDelay, options: self.grassAnimationOptions, animations: moovingGrassAnimation, completion: moovingGrassCompletion)
        }
    }
    
    func setGrassSettings(grassViewLeft: UIView, grassViewRight: UIView) {
        setGrassImageViewsSettings(grassViewLeft: grassViewLeft, grassViewRight: grassViewRight)
        setAnimationRules(grassViewLeft: grassViewLeft, grassViewRight: grassViewRight)
    }
    
    private func setGrassImageViewsSettings(grassViewLeft: UIView, grassViewRight: UIView) {
        setGrassImageViewSettings(grassImageViewFirst: leftGrassImageViewFirst, grassImageViewSecond: leftGrassImageViewSecond, grassView: grassViewLeft)
        setGrassImageViewSettings(grassImageViewFirst: rightGrassImageViewFirst, grassImageViewSecond: rightGrassImageViewSecond, grassView: grassViewRight)
    }
    
    private func setGrassImageViewSettings(grassImageViewFirst: UIImageView, grassImageViewSecond: UIImageView, grassView: UIView) {
        grassImageViewFirst.frame = grassView.bounds
        grassImageViewFirst.image = UIImage(named: "grass_icon")
        
        grassImageViewSecond.frame = grassView.bounds
        grassImageViewSecond.frame.origin.y = -grassView.frame.height
        grassImageViewSecond.image = UIImage(named: "grass_icon")
        
        grassView.addSubview(grassImageViewFirst)
        grassView.addSubview(grassImageViewSecond)
    }
    
    private func setAnimationRules(grassViewLeft: UIView, grassViewRight: UIView) {
        setMoovingGrassAnimation(grassViewLeft: grassViewLeft, grassViewRight: grassViewRight)
        setMoovingGrassCompletion(grassViewLeft: grassViewLeft, grassViewRight: grassViewRight)
    }
    
    private func setMoovingGrassAnimation(grassViewLeft: UIView, grassViewRight: UIView) {
        moovingGrassAnimation = {
            self.leftGrassImageViewFirst.frame.origin.y = grassViewLeft.frame.height
            self.leftGrassImageViewSecond.frame.origin.y = 0
            
            self.rightGrassImageViewFirst.frame.origin.y = grassViewRight.frame.height
            self.rightGrassImageViewSecond.frame.origin.y = 0
        }
    }
    
    private func setMoovingGrassCompletion(grassViewLeft: UIView, grassViewRight: UIView) {
        moovingGrassCompletion = {_ in
            self.leftGrassImageViewFirst.frame.origin.y = 0
            self.leftGrassImageViewSecond.frame.origin.y = -grassViewLeft.frame.height
            
            self.rightGrassImageViewFirst.frame.origin.y = 0
            self.rightGrassImageViewSecond.frame.origin.y = -grassViewRight.frame.height
            
            if let moovingGrassAnimation = self.moovingGrassAnimation,
               let moovingGrassCompletion = self.moovingGrassCompletion {
                UIView.animate(withDuration: self.grassAnimationDuration, delay: self.grassAnimationDelay, options: self.grassAnimationOptions, animations: moovingGrassAnimation, completion: moovingGrassCompletion)
            }
        }
    }
}
