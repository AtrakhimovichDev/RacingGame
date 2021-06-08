//
//  Game.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 24.05.21.
//

import Foundation
import CoreGraphics

class Game {
    lazy var car = CarUI(car: userSettings.car)
    
    private var gameStatus: GameStatus = .start
    private var obstructionsArray: [ObstructionUI] = []
    private var backgroundsArray: [GameBackgroundUI] = []
    private var hpAmount = 3
    private var armorAmount = 2
    private var userSettings: UserSettings
    private var userDefaults = UserDefaults.standard
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func startBackgroundAnimation() {
        for gameBackground in backgroundsArray {
            gameBackground.stopAnimation = false
            gameBackground.startAnimation()
        }
    }
       
    func stopBackgroundAnimation() {
        for background in backgroundsArray {
            background.stopAnimation = true
        }
    }
    
    func startObstructionsAnimation() {
        for obstruction in obstructionsArray {
            obstruction.stopAnimation = false
            obstruction.startAnimation()
        }
    }
    
    func stopObstructionsAnimation() {
        for obstruction in obstructionsArray {
            obstruction.stopAnimation = true
        }
    }
    
    func pauseGame() {
        if gameStatus != .pause {
            gameStatus = .pause
            stopBackgroundAnimation()
            stopObstructionsAnimation()
        } else {
            gameStatus = .play
            startBackgroundAnimation()
            startObstructionsAnimation()
        }
    }
    
    func restartGame(mainViewSize: CGSize) {
        deleteObstractions(deleteAll: true)
        car.setStartPosition(mainViewSize: mainViewSize)
        hpAmount = 3
        armorAmount = 2
    }
    
    
    func setGameStatus(newStatus: GameStatus) {
        gameStatus = newStatus
    }
    
    func getGameStatus() -> GameStatus {
        return gameStatus
    }
    
    func getArmor() -> Int {
        return armorAmount
    }
    
    func getHP() -> Int {
        return hpAmount
    }
    
    func createBackground(backgroundType: GameBackgroundType, viewBounds: CGRect) -> GameBackgroundUI {
        let background = GameBackgroundUI(gameBackgroundType: backgroundType)
        background.setBackgroundSettings(backgroundViewBounds: viewBounds)
        backgroundsArray.append(background)
        return background
    }
    
    func createObstruction(mainViewHeight: CGFloat, roadViewFrame: CGRect) -> ObstructionUI {
        let obstraction = ObstructionUI()
        obstraction.setObstractionSettings(mainViewHeight: mainViewHeight, roadViewFrame: roadViewFrame)
        obstructionsArray.append(obstraction)
        return obstraction
    }
    
    func createCar(mainViewSize: CGSize) -> CarUI {
        //let car = CarUI(car: userSettings.car)
        car.setCarSettings(mainViewSize: mainViewSize)
        //self.car = car
        return car
    }
    
    func deleteObstractions(deleteAll: Bool) {
        if deleteAll {
            for obstraction in obstructionsArray {
                obstraction.obstructionImageView.removeFromSuperview()
            }
            obstructionsArray = []
        } else {
            obstructionsArray = obstructionsArray.filter{ !$0.deleteObstraction }
        }
    }
    
    func checkCrush(mainViewMaxX: CGFloat) {
        if !userSettings.immortality {
            if !car.afterCrash {
                checkAwayFromRoadCrush(mainViewMaxX: mainViewMaxX)
                checkObstructionCrash()
            }
        }
    }

    private func checkAwayFromRoadCrush(mainViewMaxX: CGFloat) {
        if car.carView.frame.minX <= 0 || car.carView.frame.maxX >= mainViewMaxX {
           checkHPAndArmor()
        }
    }
    
    private func checkObstructionCrash() {
        for obstruct in obstructionsArray {
            if car.carView.frame.intersects(obstruct.obstructionImageView.frame) {
                checkHPAndArmor()
                break
            }
        }
    }
    
    private func checkHPAndArmor() {
        if armorAmount > 0 {
            armorAmount -= 1
        } else {
            hpAmount -= 1
            if hpAmount == 0 {
                gameStatus = .gameOver
            }
        }
        car.afterCrash = true
    }
}
