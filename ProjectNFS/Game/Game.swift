//
//  Game.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 24.05.21.
//

import UIKit

class Game {
    let gameUI: GameInterface = GameInterface()
    let road: Road = Road()
    let grass: Grass = Grass()
    let car: Car = Car()
   
    //private var gameIsStarting = false
    private var gameOver = false
    private var obstructionsArray: [Obstruction] = []
    
    func startGame(mainView: UIView) {
        gameUI.startAnimation(mainView: mainView) { _ in
           // self.road.startAnimation()
           // self.grass.startAnimation()
        }
        road.startAnimation()
        grass.startAnimation()
    }
    
    func setGamingSettings(mainView: UIView, roadView: UIView, grassViewLeft: UIView, grassViewRight: UIView) {
        road.setRoadSettings(roadView: roadView)
        grass.setGrassSettings(grassViewLeft: grassViewLeft, grassViewRight: grassViewRight)
        car.setCarSettings(mainView: mainView)
        gameUI.setGameUISettings(mainView: mainView)
    }
    
    func createObstruction(mainView: UIView, roadView: UIView) {
        let obstraction = Obstruction()
        obstraction.setObstractionSettings(mainView: mainView, roadView: roadView)
        obstraction.startAnimation()
        obstructionsArray.append(obstraction)
    }
    
    func deleteObstractions() {
        obstructionsArray = obstructionsArray.filter{ !$0.deleteObstraction }
    }
    
    func checkCrush(mainView: UIView) {
        checkAwayFromRoadCrush(mainView: mainView)
        checkObstructionCrash()
    }
    
    func getGameOverStatus() -> Bool {
        return gameOver
    }
    
    private func checkAwayFromRoadCrush(mainView: UIView) {
        if car.carView.frame.minX <= 0 || car.carView.frame.maxX >= mainView.frame.maxX {
            gameOver = true
        }
    }
    
    private func checkObstructionCrash() {
        for obstruct in obstructionsArray {
            if car.carView.frame.intersects(obstruct.obstructionImageView.frame) {
                gameOver = true
                break
            }
        }
    }
}
