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

    let game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameSettings()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationControllerSettings(animated: animated)
        game.startGame(mainView: mainView)
        startGameTimers()
    }
    
    private func startGameTimers() {
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            if !self.game.getGameOverStatus() {
                self.game.createObstruction(mainView: self.mainView, roadView: self.roadView)
                self.game.deleteObstractions()
            } else {
                timer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !self.game.getGameOverStatus() {
                self.game.checkCrush(mainView: self.mainView)
            } else {
                timer.invalidate()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let gameOverVC = storyboard.instantiateViewController(identifier: "GameOverViewController")
                self.present(gameOverVC, animated: true)
                //self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !self.game.getGameOverStatus() {
                self.game.gameUI.score += 1
            }
        }
    }
    
    private func setGameSettings() {
        setUIViewsSettings()
        game.setGamingSettings(mainView: mainView, roadView: roadView, grassViewLeft: leftGrassView, grassViewRight: rightGrassView)
        
    }
    
    private func setUIViewsSettings() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(changeCarPosition))
        mainView.addGestureRecognizer(panGesture)
        
        roadView.clipsToBounds = true
        mainView.clipsToBounds = true
    }
    
    @objc func changeCarPosition(selector: UIPanGestureRecognizer) {
        switch selector.state {
        case .began:
            game.gameUI.showPanGestureControlView(selectorLocation: selector.location(in: mainView))
        case .changed:
            game.car.setTranslationPosition(translationPosition: selector.translation(in: mainView))
            game.car.rotateCar()
            game.car.moveCar()
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
    
    private func addPanGestureControllView() {
        
    }
    
}
