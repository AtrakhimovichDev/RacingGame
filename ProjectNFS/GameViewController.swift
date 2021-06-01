//
//  GameViewController.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.05.21.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var roadView: UIView!
    @IBOutlet weak var leftGrassView: UIView!
    @IBOutlet weak var rightGrassView: UIView!
    private let pauseButton = UIButton()

    let game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameSettings()

        pauseButton.frame = CGRect(x: 20, y: 20, width: 100, height: 50)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseGame), for: .touchDown)
        mainView.addSubview(pauseButton)
    }
   
    @objc func pauseGame() {
        game.pauseGame(mainView: mainView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationControllerSettings(animated: animated)
        game.startGame(mainView: mainView)
        startGameTimers()
    }
    
    private func startGameTimers() {
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.createObstruction()
                self.game.deleteObstractions(deleteAll: false)
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.game.checkCrush(mainViewMaxX: self.mainView.frame.maxX)
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
                self.openGameOverScreen()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.game.gameUI.score += 1
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
            }
        }
    }
    
    private func openGameOverScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameOverVC = storyboard.instantiateViewController(identifier: "GameOverViewController") as GameOverViewController
        gameOverVC.buttonResetPressed = {
            self.game.setGameStatus(newStatus: .start)
            self.game.gameUI.setStartAnimationSettings(mainView: self.mainView)
            self.game.deleteObstractions(deleteAll: true)
            //self.setNavigationControllerSettings(animated: animated)
            self.game.startGame(mainView: self.mainView)
            self.game.car.carImageView.frame.origin = CGPoint(x: self.mainView.frame.width / 2 - 30, y: self.mainView.bounds.height - 150 - 120)
            self.startGameTimers()
        }
        //gameOverVC.modalPresentationStyle = .fullScreen
        self.present(gameOverVC, animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func createObstruction() {
        let obstruction = game.createObstruction(mainViewHeight: mainView.frame.height, roadViewFrame: roadView.frame)
        mainView.addSubview(obstruction.obstructionImageView)
        obstruction.startAnimation()
    }
    
    private func setGameSettings() {
        setUIViewsSettings()
        createGameBackground()
        createGameCar()
        game.setGamingSettings(mainView: mainView)
        
    }
    
    private func createGameBackground() {
        let roadBackground = game.createBackground(backgroundType: .road, viewBounds: roadView.bounds)
        roadView.addSubview(roadBackground.imageViewFirst)
        roadView.addSubview(roadBackground.imageViewSecond)
        
        let leftGrassBackground = game.createBackground(backgroundType: .grass, viewBounds: leftGrassView.bounds)
        leftGrassView.addSubview(leftGrassBackground.imageViewFirst)
        leftGrassView.addSubview(leftGrassBackground.imageViewSecond)
        
        let rightGrassBackground = game.createBackground(backgroundType: .grass, viewBounds: rightGrassView.bounds)
        rightGrassView.addSubview(rightGrassBackground.imageViewFirst)
        rightGrassView.addSubview(rightGrassBackground.imageViewSecond)
    }
   
    private func createGameCar() {
        let car = game.createCar(mainViewSize: mainView.bounds.size)
        mainView.addSubview(car.carView)
    }
    
    private func setUIViewsSettings() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(changeCarPosition))
        mainView.addGestureRecognizer(panGesture)
        
        roadView.clipsToBounds = true
        mainView.clipsToBounds = true
    }
    
    @objc func changeCarPosition(selector: UIPanGestureRecognizer) {
        if game.getGameStatus() != .play {
            return
        }
        switch selector.state {
        case .began:
            game.gameUI.showPanGestureControlView(selectorLocation: selector.location(in: mainView))
        case .changed:
            game.car.setTranslationPosition(translationPosition: selector.translation(in: mainView))
            game.car.rotateCar()
            game.car.moveCar()
            game.gameUI.moveInsideControlCircle(translation: selector.translation(in: mainView))
        case .ended:
            game.gameUI.hidePanGestureControlView()
            game.car.changeCarMoovingStatus()
            game.car.rotateCar()
        default:
            break
        }
    }
    
    private func setNavigationControllerSettings(animated: Bool) {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
     
}
