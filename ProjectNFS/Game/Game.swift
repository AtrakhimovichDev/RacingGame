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
    private var obstractionTypesForCreste: [ObstructionType] = []
    
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
    
    func createObstructions(mainViewFrame: CGRect, roadViewFrame: CGRect, roadsideViewFrame: CGRect) -> [ObstructionUI] {
        obstractionTypesForCreste = []
        genereteObstractionTypesArrayForCreating(probabilityOfCreating: 50, obstructionNumber: 0)
        var currentObstractionsArray: [ObstructionUI] = []
        for obstractionType in obstractionTypesForCreste {
            let obstraction = ObstructionUI(obstractionType: obstractionType)
            obstraction.setObstractionSettings(mainViewFrame: mainViewFrame, roadViewFrame: roadViewFrame, roadsideViewFrame: roadsideViewFrame)
            obstructionsArray.append(obstraction)
            currentObstractionsArray.append(obstraction)
        }
        return currentObstractionsArray
    }
    
    private func genereteObstractionTypesArrayForCreating(probabilityOfCreating: Int, obstructionNumber: Int) {
        var probabilityOfCreatingChenged = probabilityOfCreating
        let randomNumber = Int.random(in: 0...19)
        switch probabilityOfCreating {
        case 100:
            addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
        case 80:
            if randomNumber <= 15 {
                addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
                probabilityOfCreatingChenged -= 15
            } else {
                probabilityOfCreatingChenged += 20
            }
        case 65:
            if randomNumber <= 12 {
                addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
                probabilityOfCreatingChenged -= 15
            } else {
                probabilityOfCreatingChenged += 15
            }
        case 50:
            if randomNumber <= 9 {
                addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
                probabilityOfCreatingChenged -= 15
            } else {
                probabilityOfCreatingChenged += 15
            }
        case 35:
            if randomNumber <= 6 {
                addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
                probabilityOfCreatingChenged -= 15
            } else {
                probabilityOfCreatingChenged += 15
            }
        case 20:
            if randomNumber <= 3 {
                addObstractionTypeToCreate(obstructionNumber: obstructionNumber)
                probabilityOfCreatingChenged -= 15
            } else {
                probabilityOfCreatingChenged += 15
            }
        default:
            break
        }
        if obstructionNumber < 4 {
            genereteObstractionTypesArrayForCreating(probabilityOfCreating: probabilityOfCreatingChenged, obstructionNumber: obstructionNumber + 1)
        }
        
    }
    
    private func addObstractionTypeToCreate(obstructionNumber: Int) {
        switch obstructionNumber {
        case 0:
            obstractionTypesForCreste.append(.leftRoadSide)
        case 1:
            obstractionTypesForCreste.append(.oncomingCar)
        case 2:
            obstractionTypesForCreste.append(.car)
        case 3:
            obstractionTypesForCreste.append(.rightRoadSide)
        default:
            break
        }
    }
    
    func createCar(mainViewSize: CGSize, roadViewFrame: CGRect) -> CarUI {
        car.setCarSettings(mainViewSize: mainViewSize, roadViewFrame: roadViewFrame)
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
