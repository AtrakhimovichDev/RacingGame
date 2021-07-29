//
//  Obstruction.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 20.05.21.
//

import UIKit

class ObstructionUI {

    let obstructionImageView = UIImageView()
    private var obstractionType: ObstructionType
    
    private let obstructionAnimationDelay: TimeInterval = 0
    private let obstructionAnimationOptions: UIView.AnimationOptions = [.curveLinear]
    private var obstructionAnimationDuration: TimeInterval = 0.05

    private var moovingObstructionAnimation: (() -> ())?
    private var moovingObstructionCompletion: ((Bool) -> ())?
    private var obstructionHeight: CGFloat = 80
    private var obstructionWidth:CGFloat = 40
    var deleteObstraction = false
    var stopAnimation = false
    
    init(obstractionType: ObstructionType) {
        self.obstractionType = obstractionType
    }
    
    func startAnimation() {
        if let moovingObstructionAnimation = self.moovingObstructionAnimation,
           let moovingObstructionCompletion = self.moovingObstructionCompletion {
            UIView.animate(withDuration: self.obstructionAnimationDuration, delay: self.obstructionAnimationDelay, options: self.obstructionAnimationOptions, animations: moovingObstructionAnimation, completion: moovingObstructionCompletion)
        }
    }
    
    func setObstractionSettings(mainViewFrame: CGRect, roadViewFrame: CGRect, roadsideViewFrame: CGRect) {
        setObstractionImageViewsSettings(mainViewFrame: mainViewFrame, roadViewFrame: roadViewFrame, roadsideViewFrame: roadsideViewFrame)
        setAnimationRules(mainViewFrame: mainViewFrame)
    }
    
    private func setObstractionImageViewsSettings(mainViewFrame: CGRect, roadViewFrame: CGRect, roadsideViewFrame: CGRect) {
        switch obstractionType {
        case .leftRoadSide:
            obstructionAnimationDuration = 0.03
            obstructionHeight = roadsideViewFrame.width
            obstructionWidth = roadsideViewFrame.width
            let obstractionPoint = CGPoint(x: 0, y: -obstructionHeight)
            let obstractionSize = CGSize(width: obstructionWidth, height: obstructionHeight)
            obstructionImageView.frame = CGRect(origin: obstractionPoint, size: obstractionSize)
            obstructionImageView.image = UIImage.getImage(named: .bush)
        case .oncomingCar:
            obstructionAnimationDuration = 0.01
            obstructionWidth = roadViewFrame.width / 2 * 0.4
            obstructionHeight = obstructionWidth * 2
            let xRandomPosition = getRandomObstractionSpot(roadViewFrame: roadViewFrame, mainViewFrame: mainViewFrame)
            let obstractionPoint = CGPoint(x: xRandomPosition, y: -obstructionHeight)
            let obstractionSize = CGSize(width: obstructionWidth, height: obstructionHeight)
            obstructionImageView.frame = CGRect(origin: obstractionPoint, size: obstractionSize)
            if Bool.random() {
                let image = UIImage.getImage(named: .camaro_dmg0)
                obstructionImageView.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: .downMirrored)
            } else {
                let image = UIImage.getImage(named: .police_dmg0)
                obstructionImageView.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: .downMirrored)
            }
        case .car:
            obstructionWidth = roadViewFrame.width / 2 * 0.4
            obstructionHeight = obstructionWidth * 2
            let xRandomPosition = getRandomObstractionSpot(roadViewFrame: roadViewFrame, mainViewFrame: mainViewFrame)
            let obstractionPoint = CGPoint(x: xRandomPosition, y: -obstructionHeight)
            let obstractionSize = CGSize(width: obstructionWidth, height: obstructionHeight)
            obstructionImageView.frame = CGRect(origin: obstractionPoint, size: obstractionSize)
            if Bool.random() {
                obstructionImageView.image = UIImage.getImage(named: .camaro_dmg0)
            } else {
                obstructionImageView.image = UIImage.getImage(named: .police_dmg0)
            }
        case .rightRoadSide:
            obstructionAnimationDuration = 0.03
            obstructionHeight = roadsideViewFrame.width
            obstructionWidth = roadsideViewFrame.width
            let obstractionPoint = CGPoint(x: mainViewFrame.width - roadsideViewFrame.width, y: -roadsideViewFrame.width)
            let obstractionSize = CGSize(width: roadsideViewFrame.width, height: roadsideViewFrame.width)
            obstructionImageView.frame = CGRect(origin: obstractionPoint, size: obstractionSize)
            obstructionImageView.image = UIImage.getImage(named: .bush)
        }
       
    }
    
    private func getRandomObstractionSpot(roadViewFrame: CGRect, mainViewFrame: CGRect) -> CGFloat {
        var minX = 0
        var maxX = 0
        switch obstractionType {
        case .car:
            minX = Int(mainViewFrame.width / 2 + 10)
            maxX = Int(roadViewFrame.maxX) - Int(obstructionWidth) - 40
        case .oncomingCar:
            minX = Int(roadViewFrame.minX) + 40
            maxX = Int(mainViewFrame.width / 2) - Int(obstructionWidth) - 10
        default:
            break
        }
        return CGFloat(Int.random(in: minX...maxX))
    }
    
    private func setAnimationRules(mainViewFrame: CGRect) {
        setMoovingObstractionAnimation()
        setMoovingObstractionCompletion(mainViewFrame: mainViewFrame)
    }
    
    private func setMoovingObstractionAnimation() {
        moovingObstructionAnimation = {
            self.obstructionImageView.frame.origin.y += 10
        }
    }
    
    private func setMoovingObstractionCompletion(mainViewFrame: CGRect) {
        moovingObstructionCompletion = {(_) in
            if self.stopAnimation {
                return
            }
            if self.obstructionImageView.frame.origin.y <= mainViewFrame.height {
                self.startAnimation()
            } else {
                self.deleteObstraction = true
                self.obstructionImageView.removeFromSuperview()
            }
        }
    }
    
    
}
