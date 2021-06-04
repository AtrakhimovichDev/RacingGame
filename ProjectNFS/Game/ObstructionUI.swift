//
//  Obstruction.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class ObstructionUI {

    let obstructionImageView = UIImageView()
           
    private let obstructionAnimationDelay: TimeInterval = 0
    private let obstructionAnimationOptions: UIView.AnimationOptions = [.curveLinear]
    private var obstructionAnimationDuration: TimeInterval = 0.06

    private var moovingObstructionAnimation: (() -> ())?
    private var moovingObstructionCompletion: ((Bool) -> ())?
    private var obstractionHeight: CGFloat = 80
    private var obstractionWidth:CGFloat = 40
    var deleteObstraction = false
    var stopAnimation = false
    
    func startAnimation() {
        if let moovingObstructionAnimation = self.moovingObstructionAnimation,
           let moovingObstructionCompletion = self.moovingObstructionCompletion {
            UIView.animate(withDuration: self.obstructionAnimationDuration, delay: self.obstructionAnimationDelay, options: self.obstructionAnimationOptions, animations: moovingObstructionAnimation, completion: moovingObstructionCompletion)
        }
    }
    
    func setObstractionSettings(mainViewHeight: CGFloat, roadViewFrame: CGRect) {
        setObstractionImageViewsSettings(mainViewHeight: mainViewHeight, roadViewFrame: roadViewFrame)
        setAnimationRules(mainViewHeight: mainViewHeight)
    }
    
    private func setObstractionImageViewsSettings(mainViewHeight: CGFloat, roadViewFrame: CGRect) {
        let xRandomPosition = getRandomObstractionSpot(roadViewFrame: roadViewFrame)
        let obstractionPoint = CGPoint(x: xRandomPosition, y: -obstractionHeight)
        let obstractionSize = CGSize(width: obstractionWidth, height: obstractionHeight)
        obstructionImageView.frame = CGRect(origin: obstractionPoint, size: obstractionSize)
        if Bool.random() {
            obstructionImageView.image = UIImage(named: "car2_icon")
        } else {
            obstructionImageView.image = UIImage(named: "car3_icon")
        }
    }
    
    private func getRandomObstractionSpot(roadViewFrame: CGRect) -> CGFloat {
        let minX = Int(roadViewFrame.minX)
        let maxX = Int(roadViewFrame.maxX) - 30
        return CGFloat(Int.random(in: minX...maxX))
    }
    
    private func setAnimationRules(mainViewHeight: CGFloat) {
        setMoovingObstractionAnimation()
        setMoovingObstractionCompletion(mainViewHeight: mainViewHeight)
    }
    
    private func setMoovingObstractionAnimation() {
        moovingObstructionAnimation = {
            self.obstructionImageView.frame.origin.y += 10
        }
    }
    
    private func setMoovingObstractionCompletion(mainViewHeight: CGFloat) {
        moovingObstructionCompletion = {(_) in
            if self.stopAnimation {
                return
            }
            if self.obstructionImageView.frame.origin.y <= mainViewHeight {
                self.startAnimation()
            } else {
                self.deleteObstraction = true
                self.obstructionImageView.removeFromSuperview()
            }
        }
    }
    
    
}
