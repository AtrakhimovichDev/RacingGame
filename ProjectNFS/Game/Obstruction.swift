//
//  Obstruction.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class Obstruction {
    //var obstructionType: ObstructionType?
    //duration = 30 / Double(self.roadView.frame.height)
    
    let obstructionImageView = UIImageView()
        
    private var obstructionAnimationDuration: TimeInterval = 0.06
    private let obstructionAnimationDelay: TimeInterval = 0
    private let obstructionAnimationOptions: UIView.AnimationOptions = [.curveLinear]
   
    private var moovingObstructionAnimation: (() -> ())?
    private var moovingObstructionCompletion: ((Bool) -> ())?
    var deleteObstraction = false
    
    func startAnimation() {
        if let moovingObstructionAnimation = self.moovingObstructionAnimation,
           let moovingObstructionCompletion = self.moovingObstructionCompletion {
            UIView.animate(withDuration: self.obstructionAnimationDuration, delay: self.obstructionAnimationDelay, options: self.obstructionAnimationOptions, animations: moovingObstructionAnimation, completion: moovingObstructionCompletion)
        }
    }
    
    func setObstractionSettings(mainView: UIView, roadView: UIView) {
        //obstructionAnimationDuration = TimeInterval(20 / roadView.frame.height)
        setObstractionImageViewsSettings(mainView: mainView, roadView: roadView)
        setAnimationRules(mainView: mainView)
    }
    
    private func setObstractionImageViewsSettings(mainView: UIView, roadView: UIView) {
        obstructionImageView.frame = CGRect(x: getRandomObstractionSpot(roadView: roadView), y: -30, width: 40, height: 80)
        if Bool.random() {
            obstructionImageView.image = UIImage(named: "car2_icon")
        } else {
            obstructionImageView.image = UIImage(named: "car3_icon")
        }
        mainView.addSubview(obstructionImageView)
    }
    
    private func getRandomObstractionSpot(roadView: UIView) -> CGFloat {
        let minX = Int(roadView.frame.minX)
        let maxX = Int(roadView.frame.maxX) - 30
        return CGFloat(Int.random(in: minX...maxX))
    }
    
    private func setAnimationRules(mainView: UIView) {
        setMoovingObstractionAnimation()
        setMoovingObstractionCompletion(mainView: mainView)
    }
    
    private func setMoovingObstractionAnimation() {
        moovingObstructionAnimation = {
            self.obstructionImageView.frame.origin.y = self.obstructionImageView.frame.origin.y + 10
        }
    }
    
    private func setMoovingObstractionCompletion(mainView: UIView) {
        moovingObstructionCompletion = {(_) in
            if self.obstructionImageView.frame.origin.y <= mainView.frame.height {
                self.startAnimation()
            } else {
                self.deleteObstraction = true
            }
        }
    }
    
    
}
