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
    private let panGesture = UIPanGestureRecognizer()
    
    private var createObstructionTimer: Timer?
    private var countScoreTimer: Timer?
    private var checkCrushTimer: Timer?
    private var afterCrushStatusTimer: Timer?
    
    private let menuView = UIView()
    private let menuButton = UIButton()
    private let resumeButton = UIButton()
    private let exitButton = UIButton()
    private let restartButton = UIButton()
   
    private var scoreNumbersArray: [UIImageView] = []
    private var hpArray: [UIImageView] = []
    private var armorArray: [UIImageView] = []
    
    private var userSettings = UserSettings(name: "Street racer", difficulty: .easy, location: .city, immortality: false, car: .viper)
    private var userDefaults = UserDefaults.standard
    private var needToResetAfterCrush = true
    private var currentArmor = 2
    private var currentHp = 3
    private var score = 0 {
        didSet {
            changeScoreView()
        }
    }

    private lazy var game = Game(userSettings: userSettings)
    private let gameUI = GameUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readUserSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setGameSettings()
        setNavigationControllerSettings(animated: animated)
        gameUI.startAnimation(mainView: mainView) { _ in
            self.game.setGameStatus(newStatus: .play)
        }
        game.startBackgroundAnimation()
        startGameTimers()
    }
    
    private func pauseUnpauseGame() {
        let gameStatus = game.getGameStatus()
        if gameStatus == .play || gameStatus == .gameOver {
            game.pauseGame()
            animateMenuView(moveTo: 80) { _ in }
        } else if gameStatus == .pause {
            animateMenuView(moveTo: -self.mainView.frame.height / 2 - 45) { _ in
                self.game.pauseGame()
            }
        }
    }
    
    private func restartGame() {
        stopGameTimers()
        game.setGameStatus(newStatus: .start)
        game.restartGame(mainViewSize: mainView.frame.size)
        setStartHPArmorImages()
        animateMenuView(moveTo: -self.mainView.frame.height / 2 - 45) { _ in }
        gameUI.setStartAnimationSettings(mainView: self.mainView)
        gameUI.startAnimation(mainView: mainView) { _ in
            self.game.setGameStatus(newStatus: .play)
        }
        game.startBackgroundAnimation()
        score = 0
        setRestartScoreSettings()
        game.car.carDmgLvl = 0
        game.car.changeCarImage()
        startGameTimers()
    }
    
    private func stopGame() {
        game.stopBackgroundAnimation()
        saveScore()
        openGameOverScreen()
    }
    
    private func animateMenuView(moveTo: CGFloat, completion: @escaping ((Bool) -> ())) {
        mainView.bringSubviewToFront(menuView)
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.menuView.frame.origin.y = moveTo
        }, completion: completion)
    }
    
    
    // MARK: - buttons Actions
  
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
            selector.state = .ended
            gameUI.hidePanGestureControlView()
            game.car.setCarMoovingStatus(carIsMooving: false)
            game.car.rotateCar()
            return
        }
        switch selector.state {
        case .began:
            gameUI.showPanGestureControlView(selectorLocation: selector.location(in: mainView))
        case .changed:
            game.car.setTranslationPosition(translationPosition: selector.translation(in: mainView))
            game.car.rotateCar()
            game.car.moveCar()
            gameUI.moveInsideControlCircle(translation: selector.translation(in: mainView))
        case .ended:
            gameUI.hidePanGestureControlView()
            game.car.setCarMoovingStatus(carIsMooving: false)
            game.car.rotateCar()
        default:
            break
        }
    }
    
    
    
    
    /* MARK: Начальные настройки игры:
        - setStartViewsSettings - назначает PanGesture, который отвечает за перемещение машины.
            И минимальные настроек backgroundView.
        - createGameBackground - создает объекты класса GameBackgroundUI. Объекты содержат в себе настроенные UIImageView и правила по которым анимируется фон.
        - createGameCar - создает объект класса CarUI. Объект содержит в себе настроенный UIImageView и правила анимации машины.
        - setMenuButtonSettings - устанавливает оформление и привязывает действие к кнопке Меню.
        - setMenuViewSettings - отвечает за формление и функциональность menuView.
        - setScoreSettings - устанавливает необходимые UIImageView для блока Score, т.к. все реализовано через картинки.
        - setHPViewSettings & setArmorViewSettings - устанавливает оформление и картинки для HP & Armor bar.
        - gameUI.setGameUISettings(mainView: mainView) - GameUI отвечает за 2 вещи: за колесо управления машиной и стартовую анимацию обратного отсчета.
     */
    
    private func readUserSettings() {
        if let userSettingsData = userDefaults.value(forKey: .userSettings) as? Data {
            do {
                let userSettings = try JSONDecoder().decode(UserSettings.self, from: userSettingsData)
                self.userSettings = userSettings
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func setGameSettings() {
        setStartViewsSettings()
        createGameBackground()
        createGameCar()
        setMenuButtonSettings()
        setMenuViewSettings()
        setScoreSettings()
        setHPViewSettings()
        setArmorViewSettings()
        gameUI.setGameUISettings(mainView: mainView)
    }
    
    private func setStartViewsSettings() {
        panGesture.addTarget(self, action: #selector(changeCarPosition))
        mainView.addGestureRecognizer(panGesture)
        
        roadView.clipsToBounds = true
        mainView.clipsToBounds = true
    }
    
    private func createGameBackground() {
        var backgroundTypeMain: GameBackgroundType?
        var backgroundType: GameBackgroundType?
        switch userSettings.location {
        case .city:
            backgroundTypeMain = .road
            backgroundType = .grass
        default:
            backgroundTypeMain = .offroad
            backgroundType = .mud
        }
        let roadBackground = game.createBackground(backgroundType: backgroundTypeMain!, viewBounds: roadView.bounds)
        roadView.addSubview(roadBackground.imageViewFirst)
        roadView.addSubview(roadBackground.imageViewSecond)
        
        let leftGrassBackground = game.createBackground(backgroundType: backgroundType!, viewBounds: leftGrassView.bounds)
        leftGrassView.addSubview(leftGrassBackground.imageViewFirst)
        leftGrassView.addSubview(leftGrassBackground.imageViewSecond)
        
        let rightGrassBackground = game.createBackground(backgroundType: backgroundType!, viewBounds: rightGrassView.bounds)
        rightGrassView.addSubview(rightGrassBackground.imageViewFirst)
        rightGrassView.addSubview(rightGrassBackground.imageViewSecond)
    }
    
    private func createGameCar() {
        let car = game.createCar(mainViewSize: mainView.bounds.size, roadViewFrame: roadView.frame)
        mainView.addSubview(car.carView)
    }
    
    private func setMenuButtonSettings() {
        menuButton.frame = CGRect(x: mainView.frame.width - 55, y: 15, width: 50, height: 50)
        menuButton.setBackgroundImage(UIImage.getImage(named: .settingsButton), for: .normal)
        menuButton.tintColor = UIColor.white
        menuButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchDown)
        mainView.addSubview(menuButton)
    }
    
    private func setMenuViewSettings() {
        menuView.frame = CGRect(x: 20, y: -mainView.frame.height / 2 - 45, width: mainView.frame.width - 40, height: mainView.frame.height / 2)
        menuView.layer.cornerRadius = 15
        menuView.backgroundColor = .white
        
        let menuImageView = UIImageView()
        menuImageView.frame = menuView.bounds
        menuImageView.image = UIImage.getImage(named: .menuBackground)
        
        exitButton.frame = CGRect(x: menuView.frame.width - 75, y: 13, width: 40, height: 40)
        exitButton.setBackgroundImage(UIImage.getImage(named: .clouseButton), for: .normal)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchDown)
        
        restartButton.frame = CGRect(x: 30, y: menuView.frame.height - 90, width: 70, height: 70)
        restartButton.setBackgroundImage(UIImage.getImage(named: .replayButton), for: .normal)
        restartButton.addTarget(self, action: #selector(restartAction), for: .touchDown)
        
        resumeButton.frame = CGRect(x: menuView.frame.width - 100, y: menuView.frame.height - 90, width: 70, height: 70)
        resumeButton.setBackgroundImage(UIImage.getImage(named: .playButton), for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeAction), for: .touchDown)
        
        menuView.addSubview(menuImageView)
        menuView.addSubview(exitButton)
        menuView.addSubview(resumeButton)
        menuView.addSubview(restartButton)
        
        mainView.addSubview(menuView)
    }
    
    private func setScoreSettings() {
        let scoreImageView = UIImageView()
        scoreImageView.frame = scoreLabelView.bounds
        scoreImageView.image = UIImage.getImage(named: .scoreLabel)
        scoreLabelView.addSubview(scoreImageView)
        
        scoreNumbersArray.append(createImageView(parentView: firstNumberScoreView, image: .zero))
        scoreNumbersArray.append(createImageView(parentView: secondNumberScoreView, image: .zero))
        scoreNumbersArray.append(createImageView(parentView: thirdNumberScoreView, image: .zero))
        scoreNumbersArray.append(createImageView(parentView: fourthNumberScoreView, image: .zero))
    }
    
    private func setRestartScoreSettings() {
        for numberImage in scoreNumbersArray {
            numberImage.image = UIImage.getImage(named: .zero)
        }
    }
    
    private func setHPViewSettings() {
        let hpImageView = UIImageView()
        hpImageView.frame = hpView.bounds
        hpImageView.image = UIImage.getImage(named: .hpBar)
        
        hpView.addSubview(hpImageView)
        
        hpArray.append(createImageView(parentView: firstHPView, image: .hpFull))
        hpArray.append(createImageView(parentView: secondHPView, image: .hpFull))
        hpArray.append(createImageView(parentView: thirdHPView, image: .hpFull))
        
        hpView.bringSubviewToFront(firstHPView)
        hpView.bringSubviewToFront(secondHPView)
        hpView.bringSubviewToFront(thirdHPView)
    }
   
    private func setArmorViewSettings() {
        let armorImageView = UIImageView()
        armorImageView.frame = armorView.bounds
        armorImageView.image = UIImage.getImage(named: .armorBar)
        
        armorView.addSubview(armorImageView)

        armorArray.append(createImageView(parentView: firstArmorView, image: .armorFull))
        armorArray.append(createImageView(parentView: secondArmorView, image: .armorFull))
        
        armorView.bringSubviewToFront(firstArmorView)
        armorView.bringSubviewToFront(secondArmorView)
    }
    
    private func setStartHPArmorImages() {
        for hpImageView in hpArray {
            hpImageView.image = UIImage.getImage(named: .hpFull)
        }
        for armorImageView in armorArray {
            armorImageView.image = UIImage.getImage(named: .armorFull)
        }
        currentArmor = 2
        currentHp = 3
    }
    
    private func setNavigationControllerSettings(animated: Bool) {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }
    
    
    
    
    /* MARK: - Таймеры:
        - startGameTimers & stopGameTimers - функции запуска и остановки всех таймеров
        - startObstructionsCreateTimer - таймер генерирующий новые препятвия и удаляющий
            те, которые уже вышли за пределы экрана
        - startCheckCrushTimer - таймер проверяющий соприкосновения с препятсвиями и краями экрана.
            Если игра находится в статусе GameOver, открывается соответсвующий экран. Так же таймер управляет свойством afterCrash. Это свойство - время в течение котрого машина не реагирует на столкновения. Свойство активируется в момент аварии.
        - startCountScoreTimer - таймер подсчитывает очки с течением времени
    */
    
    private func startGameTimers() {
        startObstructionsCreateTimer()
        startCheckCrushTimer()
        startCountScoreTimer()
    }
    
    private func stopGameTimers() {
        createObstructionTimer?.invalidate()
        checkCrushTimer?.invalidate()
        countScoreTimer?.invalidate()
    }
    
    private func startObstructionsCreateTimer() {
        createObstructionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            switch self.game.getGameStatus() {
            case .play:
                self.createObstructions()
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
    }
    
    private func startCheckCrushTimer() {
        checkCrushTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.game.checkCrush(mainViewMaxX: self.mainView.frame.maxX)
                self.checkHPAndArmorView()
                if self.game.car.afterCrash {
                    if self.needToResetAfterCrush {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.game.car.afterCrash = false
                            self.needToResetAfterCrush = true
                        }
                        Animations.requireUserAtencion(on: self.mainView)
                        self.game.car.carDmgLvl += 1
                        self.game.car.changeCarImage()
                        self.game.car.crashAnimate()
                        self.needToResetAfterCrush = false
                    }
                }
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
                self.stopGame()
            }
        }
    }
    
    private func startCountScoreTimer() {
        countScoreTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.game.getGameStatus() == .play {
                self.score += 1
            } else if self.game.getGameStatus() == .gameOver {
                timer.invalidate()
            }
        }
    }
    
    private func checkHPAndArmorView() {
        let armorAmount = game.getArmor()
        if armorAmount != currentArmor {
            currentArmor = armorAmount
            armorArray[currentArmor].image = UIImage.getImage(named: .armorZero)
        } else {
            let hpAmount = game.getHP()
            if hpAmount != currentHp {
                currentHp = hpAmount
                hpArray[currentHp].image = UIImage.getImage(named: .hpZero)
            }
        }
    }
    
    private func createObstructions() {
        let obstructionsArray = game.createObstructions(mainViewFrame: mainView.frame, roadViewFrame: roadView.frame, roadsideViewFrame: leftGrassView.frame)
        for obstruction in obstructionsArray {
            mainView.addSubview(obstruction.obstructionImageView)
            obstruction.startAnimation()
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

    private func changeScoreView() {
        changeScoreImage(number: score % 10, imageView: scoreNumbersArray[3])
        if score / 10 != 0 {
            changeScoreImage(number: score / 10 % 10, imageView: scoreNumbersArray[2])
        }
        if score / 100 != 0 {
            changeScoreImage(number: score / 100 % 10, imageView: scoreNumbersArray[1])
        }
        if score / 1000 != 0 {
            changeScoreImage(number: score / 1000 % 10, imageView: scoreNumbersArray[0])
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
    
    
    // MARK: Additional functions
    
    private func createImageView(parentView: UIView, image: Images) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = parentView.bounds
        imageView.image = UIImage.getImage(named: image)
        parentView.addSubview(imageView)
        return imageView
    }
    
    private func saveScore() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        let userScore = UserScore(userName: userSettings.name, date: dateFormatter.string(from: Date()), score: score)
        var userScoreArray = getUserScores()
        userScoreArray.append(userScore)
        let userScoreData = try? JSONEncoder().encode(userScoreArray)
        userDefaults.setValue(userScoreData, forKey: UserDefaultsKeys.userScore.rawValue)
    }
    
    private func getUserScores() -> [UserScore] {
        var userScoreArray: [UserScore] = []
        if let userScoreData = userDefaults.value(forKey: .userScore) as? Data {
            do {
                userScoreArray = try JSONDecoder().decode([UserScore].self, from: userScoreData)
            } catch {
                print(error.localizedDescription)
            }
        }
        return userScoreArray
    }
    
}
