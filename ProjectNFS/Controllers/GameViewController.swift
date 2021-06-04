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
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var scoreLabelView: UIView!
    @IBOutlet weak var firstNumberScoreView: UIView!
    @IBOutlet weak var secondNumberScoreView: UIView!
    @IBOutlet weak var thirdNumberScoreView: UIView!
    @IBOutlet weak var fourthNumberScoreView: UIView!
    @IBOutlet weak var hpView: UIView!
    @IBOutlet weak var armorView: UIView!
    @IBOutlet weak var firstHPView: UIView!
    @IBOutlet weak var secondHPView: UIView!
    @IBOutlet weak var thirdHPView: UIView!
    @IBOutlet weak var firstArmorView: UIView!
    @IBOutlet weak var secondArmorView: UIView!
    
    private var createObstructionTimer: Timer?
    private var countScoreTimer: Timer?
    private var checkCrushTimer: Timer?
    private var afterCrushStatusTimer: Timer?
    
    private let menuButton = UIButton()
    private let menuView = UIView()
    private let menuImageView = UIImageView()
    private let resumeButton = UIButton()
    private let exitButton = UIButton()
    private let restartButton = UIButton()
    
    private let scoreImageView = UIImageView()
    private let firstScoreNumber = UIImageView()
    private let secondScoreNumber = UIImageView()
    private let thirdScoreNumber = UIImageView()
    private let fourthScoreNumber = UIImageView()
    
    private let hpImageView = UIImageView()
    private let armorImageView = UIImageView()
   
    private lazy var hpArray: [UIImageView] = []
    private lazy var armorArray: [UIImageView] = []
    
    private var needToResetAfterCrush = true
    private var currentArmor = 2
    private var currentHp = 3
    private var score = 0 {
        didSet {
            changeScoreView()
        }
    }
    
    private let game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationControllerSettings(animated: animated)
        startGameTimers()
        game.startGame(mainView: mainView)
    }
    
    private func setNavigationControllerSettings(animated: Bool) {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }
    private func startGameTimers() {
        
        createObstructionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            switch self.game.getGameStatus() {
            case .play:
                self.createObstruction()
                self.game.deleteObstractions(deleteAll: false)
                self.mainView.bringSubviewToFront(self.scoreView)
                self.mainView.bringSubviewToFront(self.hpView)
                self.mainView.bringSubviewToFront(self.armorView)
            case .gameOver:
                timer.invalidate()
            default:
                break
            }
        }
        
        checkCrushTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.game.checkCrush(mainViewMaxX: self.mainView.frame.maxX)
                self.checkHPAndArmor()
                if self.game.car.afterCrash {
                    if self.needToResetAfterCrush {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.game.car.afterCrash = false
                            self.needToResetAfterCrush = true
                        }
                        self.needToResetAfterCrush = false
                    }
                }
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
                self.game.stopBackgroundAnimation()
                self.openGameOverScreen()
            }
        }
      
        countScoreTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.score += 1
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
            }
        }
    }
    
    private func stopGameTimers() {
        createObstructionTimer?.invalidate()
        checkCrushTimer?.invalidate()
        countScoreTimer?.invalidate()
    }
    
    private func checkHPAndArmor() {
        let armorAmount = game.getArmor()
        if armorAmount != currentArmor {
            currentArmor = armorAmount
            armorArray[currentArmor].image = UIImage.createImage(named: .armorZero)
        } else {
            let hpAmount = game.getHP()
            if hpAmount != currentHp {
                currentHp = hpAmount
                hpArray[currentHp].image = UIImage.createImage(named: .hpZero)
            }
        }
    }
    
    private func openGameOverScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameOverVC = storyboard.instantiateViewController(identifier: "GameOverViewController") as GameOverViewController
        gameOverVC.buttonResetPressed = {
            self.restartGame()
        }
        self.present(gameOverVC, animated: true)
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
    
    private func setUIViewsSettings() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(changeCarPosition))
        mainView.addGestureRecognizer(panGesture)
        
        roadView.clipsToBounds = true
        mainView.clipsToBounds = true
        
        setMenuButtonSettings()
        setMenuViewSettings()
        setScoreSettings()
        setHPViewSettings()
        setArmorViewSettings()
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
    
    private func setMenuButtonSettings() {
        menuButton.frame = CGRect(x: mainView.frame.width - 55, y: 15, width: 50, height: 50)
        menuButton.setBackgroundImage(UIImage.createImage(named: .settingsButton), for: .normal)
        menuButton.tintColor = UIColor.white
        menuButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchDown)
        mainView.addSubview(menuButton)
    }
    
    private func setMenuViewSettings() {
        menuView.frame = CGRect(x: 20, y: -mainView.frame.height / 2 - 45, width: mainView.frame.width - 40, height: mainView.frame.height / 2)
        menuView.layer.cornerRadius = 15
        menuView.backgroundColor = .white
        
        menuImageView.frame = menuView.bounds
        menuImageView.image = UIImage.createImage(named: .menuBackground)
        
        exitButton.frame = CGRect(x: menuView.frame.width - 75, y: 13, width: 40, height: 40)
        exitButton.setBackgroundImage(UIImage.createImage(named: .clouseButton), for: .normal)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchDown)
        
        restartButton.frame = CGRect(x: 30, y: menuView.frame.height - 90, width: 70, height: 70)
        restartButton.setBackgroundImage(UIImage.createImage(named: .replayButton), for: .normal)
        restartButton.addTarget(self, action: #selector(restartAction), for: .touchDown)
        
        resumeButton.frame = CGRect(x: menuView.frame.width - 100, y: menuView.frame.height - 90, width: 70, height: 70)
        resumeButton.setBackgroundImage(UIImage.createImage(named: .playButton), for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeAction), for: .touchDown)
        
        menuView.addSubview(menuImageView)
        menuView.addSubview(exitButton)
        menuView.addSubview(resumeButton)
        menuView.addSubview(restartButton)
        
        mainView.addSubview(menuView)
    }
    
    private func setScoreSettings() {
        
        scoreImageView.frame = scoreLabelView.bounds
        scoreImageView.image = UIImage.createImage(named: .scoreLabel)
        scoreLabelView.addSubview(scoreImageView)
        
        firstScoreNumber.frame = firstNumberScoreView.bounds
        firstScoreNumber.image = UIImage.createImage(named: .zero)
        firstNumberScoreView.addSubview(firstScoreNumber)
        
        secondScoreNumber.frame = secondNumberScoreView.bounds
        secondScoreNumber.image = UIImage.createImage(named: .zero)
        secondNumberScoreView.addSubview(secondScoreNumber)
        
        thirdScoreNumber.frame = thirdNumberScoreView.bounds
        thirdScoreNumber.image = UIImage.createImage(named: .zero)
        thirdNumberScoreView.addSubview(thirdScoreNumber)
        
        fourthScoreNumber.frame = fourthNumberScoreView.bounds
        fourthScoreNumber.image = UIImage.createImage(named: .zero)
        fourthNumberScoreView.addSubview(fourthScoreNumber)
        
    }
    
    private func setHPViewSettings() {
        hpImageView.frame = hpView.bounds
        hpImageView.image = UIImage.createImage(named: .hpBar)
        
        hpView.addSubview(hpImageView)
        
        createHealthArmorImageView(parentView: firstHPView, image: .hpFull, isHealth: true)
        createHealthArmorImageView(parentView: secondHPView, image: .hpFull, isHealth: true)
        createHealthArmorImageView(parentView: thirdHPView, image: .hpFull, isHealth: true)
        
        hpView.bringSubviewToFront(firstHPView)
        hpView.bringSubviewToFront(secondHPView)
        hpView.bringSubviewToFront(thirdHPView)
    }
   
    private func setArmorViewSettings() {
        armorImageView.frame = armorView.bounds
        armorImageView.image = UIImage.createImage(named: .armorBar)
        
        armorView.addSubview(armorImageView)
        
        createHealthArmorImageView(parentView: firstArmorView, image: .armorFull, isHealth: false)
        createHealthArmorImageView(parentView: secondArmorView, image: .armorFull, isHealth: false)
        
        armorView.bringSubviewToFront(firstArmorView)
        armorView.bringSubviewToFront(secondArmorView)
    }
    
    private func createHealthArmorImageView(parentView: UIView, image: Images, isHealth: Bool){
        let imageView = UIImageView()
        imageView.frame = parentView.bounds
        imageView.image = UIImage.createImage(named: image)
        parentView.addSubview(imageView)
        if isHealth {
            hpArray.append(imageView)
        } else {
            armorArray.append(imageView)
        }
    }
    
    @objc func exitAction() {
        showExitAlert { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func resumeAction() {
        pauseUnpauseGame()
    }
    
    @objc func restartAction() {
        restartGame()
    }
    
   @objc func settingsButtonPressed() {
       pauseUnpauseGame()
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
    
    private func pauseUnpauseGame() {
        let gameStatus = game.getGameStatus()
        if gameStatus == .play {
            game.pauseGame(mainView: mainView)
            animateMenuView(moveTo: 80) { _ in }
        } else if gameStatus == .pause {
            animateMenuView(moveTo: -self.mainView.frame.height / 2 - 45) { _ in
                self.game.pauseGame(mainView: self.mainView)
            }
        }
    }
    
    private func restartGame() {
        stopGameTimers()
        game.setGameStatus(newStatus: .start)
        game.restartGame(mainViewSize: mainView.frame.size)
        setStartHPArmorImages()
        animateMenuView(moveTo: -self.mainView.frame.height / 2 - 45) { _ in }
        game.gameUI.setStartAnimationSettings(mainView: self.mainView)
        game.startGame(mainView: self.mainView)
        startGameTimers()
    }
    
    private func setStartHPArmorImages() {
        for hpImageView in hpArray {
            hpImageView.image = UIImage.createImage(named: .hpFull)
        }
        for armorImageView in armorArray {
            armorImageView.image = UIImage.createImage(named: .armorFull)
        }
        currentArmor = 2
        currentHp = 3
    }
    
    private func animateMenuView(moveTo: CGFloat, completion: @escaping ((Bool) -> ())) {
        mainView.bringSubviewToFront(menuView)
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.menuView.frame.origin.y = moveTo
        }, completion: completion)
    }
    
    private func changeScoreView() {
        changeScoreImage(number: score % 10, imageView: fourthScoreNumber)
        if score / 10 != 0 {
            changeScoreImage(number: score / 10 % 10, imageView: thirdScoreNumber)
        }
        if score / 100 != 0 {
            changeScoreImage(number: score / 100 % 10, imageView: secondScoreNumber)
        }
        if score / 1000 != 0 {
            changeScoreImage(number: score / 1000 % 10, imageView: firstScoreNumber)
        }
    }
    
    private func changeScoreImage(number: Int, imageView: UIImageView) {
        var imageName: Images?
        switch number {
        case 0:
            imageName = Images.zero
        case 1:
            imageName = Images.one
        case 2:
            imageName = Images.two
        case 3:
            imageName = Images.three
        case 4:
            imageName = Images.four
        case 5:
            imageName = Images.five
        case 6:
            imageName = Images.six
        case 7:
            imageName = Images.seven
        case 8:
            imageName = Images.eight
        case 9:
            imageName = Images.nine
        default:
            break
        }
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName.rawValue)
        }
    }
}
