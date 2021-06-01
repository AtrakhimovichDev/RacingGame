//
//  Road.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class Road {
    private let roadImageViewFirst = UIImageView()
    private let roadImageViewSecond = UIImageView()
    private let roadAnimationDuration: TimeInterval = 0.01
    private let roadAnimationDelay: TimeInterval = 0
    private let roadAnimationOptions: UIView.AnimationOptions = [.curveLinear]
   
    private var moovingRoadAnimation: (() -> ())?
    private var moovingRoadCompletion: ((Bool) -> ())?
    var stopAnimation = false
    
    func startAnimation() {
        if let moovingRoadAnimation = self.moovingRoadAnimation,
           let moovingRoadCompletion = self.moovingRoadCompletion {
            UIView.animate(withDuration: self.roadAnimationDuration, delay: self.roadAnimationDelay, options: self.roadAnimationOptions, animations: moovingRoadAnimation, completion: moovingRoadCompletion)
        }
    }
    
    func setRoadSettings(roadView: UIView) {
        setRoadImageViewsSettings(roadView: roadView)
        setAnimationRules(roadView: roadView)
    }
    
    private func setRoadImageViewsSettings(roadView: UIView) {
        roadImageViewFirst.frame = roadView.bounds
        roadImageViewFirst.image = UIImage(named: "road_icon")
        
        roadImageViewSecond.frame = roadView.bounds
        roadImageViewSecond.frame.origin.y = -roadView.frame.height
        roadImageViewSecond.image = UIImage(named: "road_icon")
        
        roadView.addSubview(roadImageViewFirst)
        roadView.addSubview(roadImageViewSecond)
    }
    
    private func setAnimationRules(roadView: UIView) {
        setMoovingRoadAnimation(roadView: roadView)
        setMoovingRoadCompletion(roadView: roadView)
    }
    
    private func setMoovingRoadAnimation(roadView: UIView) {
        moovingRoadAnimation = {
            self.roadImageViewFirst.frame.origin.y = self.roadImageViewFirst.frame.origin.y + 10
            self.roadImageViewSecond.frame.origin.y = self.roadImageViewSecond.frame.origin.y + 10
        }
    }
    
    private func setMoovingRoadCompletion(roadView: UIView) {
        moovingRoadCompletion = {_ in
            if self.stopAnimation {
                return
            }
            if self.roadImageViewFirst.frame.origin.y >= roadView.frame.height {
                self.roadImageViewFirst.frame.origin.y = 0
                self.roadImageViewSecond.frame.origin.y = -roadView.frame.height
            }
            self.startAnimation()
        }
    }
}
