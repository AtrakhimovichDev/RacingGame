//
//  Game.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 24.05.21.
//

import UIKit

class Game {
    let gameUI: GameInterface = GameInterface()
    var car: Car = Car()
   
    private var gameStatus: GameStatus = .start
    private var obstructionsArray: [Obstruction] = []
    private var backgroundsArray: [GameBackground] = []
    
    
    func startGame(mainView: UIView) {
        gameUI.startAnimation(mainView: mainView) { _ in
            self.gameStatus = .play
        }
        for gameBackground in backgroundsArray {
            gameBackground.startAnimation()
        }
    }
    
    func pauseGame(mainView: UIView) {
        if gameStatus != .pause {
            gameStatus = .pause
            //mainView.bringSubviewToFront(gameUI.blurEffect)
            UIView.animate(withDuration: 1) {
                self.gameUI.blurEffect.alpha = 1
            }
            for background in backgroundsArray {
                background.stopAnimation = true
            }
            for obstruction in obstructionsArray {
                obstruction.stopAnimation = true
            }
        } else {
            gameStatus = .play
            UIView.animate(withDuration: 1) {
                self.gameUI.blurEffect.alpha = 0
            }
            for background in backgroundsArray {
                background.stopAnimation = false
                background.startAnimation()
            }
            for obstruction in obstructionsArray {
                obstruction.stopAnimation = false
                obstruction.startAnimation()
            }
        }
    }
    
    func setGamingSettings(mainView: UIView) {
       
        gameUI.setGameUISettings(mainView: mainView)
    }
    
    func createBackground(backgroundType: GameBackgroundType, viewBounds: CGRect) -> GameBackground {
        let background = GameBackground(gameBackgroundType: backgroundType)
        background.setBackgroundSettings(backgroundViewBounds: viewBounds)
        backgroundsArray.append(background)
        return background
    }
    
    func createObstruction(mainViewHeight: CGFloat, roadViewFrame: CGRect) -> Obstruction {
        let obstraction = Obstruction()
        obstraction.setObstractionSettings(mainViewHeight: mainViewHeight, roadViewFrame: roadViewFrame)
        obstructionsArray.append(obstraction)
        return obstraction
    }
    
    func createCar(mainViewSize: CGSize) -> Car {
        let car = Car()
        car.setCarSettings(mainViewSize: mainViewSize)
        self.car = car
        return car
    }
    
    func deleteObstractions(deleteAll: Bool) {
        if deleteAll {
            obstructionsArray = []
        } else {
            obstructionsArray = obstructionsArray.filter{ !$0.deleteObstraction }
        }
    }
    
    func checkCrush(mainViewMaxX: CGFloat) {
        checkAwayFromRoadCrush(mainViewMaxX: mainViewMaxX)
        checkObstructionCrash()
    }
    
    func setGameStatus(newStatus: GameStatus) {
        gameStatus = newStatus
    }
    
    func getGameStatus() -> GameStatus {
        return gameStatus
    }
    
    private func checkAwayFromRoadCrush(mainViewMaxX: CGFloat) {
        if car.carView.frame.minX <= 0 || car.carView.frame.maxX >= mainViewMaxX {
            gameStatus = .gameOver
        }
    }
    
    private func checkObstructionCrash() {
        for obstruct in obstructionsArray {
            if car.carView.frame.intersects(obstruct.obstructionImageView.frame) {
                gameStatus = .gameOver
                break
            }
        }
    }
}
