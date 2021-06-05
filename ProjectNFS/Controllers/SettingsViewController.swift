//
//  SettingsViewController.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.05.21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var mainSettingsView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var difficultyPicker: UISegmentedControl!
    @IBOutlet weak var locationPicker: UISegmentedControl!
    @IBOutlet weak var immortalitySwitch: UISwitch!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var pickCarButton: UIButton!
    
    @IBOutlet weak var pickCarMainView: UIView!
    @IBOutlet weak var pickCarInnerView: UIView!
    @IBOutlet weak var carView: UIView!
    @IBOutlet weak var pickCarViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveSettingButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveSettingsButton: UIButton!
    
    private var carImageView = UIImageView()
    private var carImageViewSecond = UIImageView()
    private var curentCarImageView = UIImageView()
    private var hiddenCarImageView = UIImageView()
    
    private var gameDifficulty: GameDifficulty?
    private var gameLocation: GameLocation?
    private var carPickerIsShown = false
    private var carsArray: [(Car,UIImage?)] = []
    private var curentCarIndex = 0
    private let userDefaults = UserDefaults.standard
    
    private var racerName = "" {
        didSet {
            userNameLabel.text = racerName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillCarsArray()
        readUsedDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStartViewsSettings()
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func pickCarButtonAction(_ sender: Any) {
        animateCarPicker()
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Name", message: "Enter your name.", preferredStyle: .alert)
        alert.addTextField { _ in
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.racerName = alert.textFields?[0].text ?? ""
        }))
        present(alert, animated: true)
    }
    
    @IBAction func saveSettingsButtonAction(_ sender: Any) {
        userDefaults.setValue(racerName, forKey: UserDefaultsKeys.userName.rawValue)
        userDefaults.setValue(gameDifficulty?.rawValue, forKey: UserDefaultsKeys.gameDifficulty.rawValue)
        userDefaults.setValue(gameLocation?.rawValue, forKey: UserDefaultsKeys.gameLocation.rawValue)
        userDefaults.setValue(immortalitySwitch.isOn, forKey: UserDefaultsKeys.immortality.rawValue)
        userDefaults.setValue(carNameLabel.text, forKey: UserDefaultsKeys.userCar.rawValue)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func chooseCarButtonAction(_ sender: Any) {
        animateCarPicker()
        carNameLabel.text = carsArray[curentCarIndex].0.rawValue
    }
    
    @IBAction func slideLeftButtonAction(_ sender: Any) {
        setHiddenViewPosition(direction: .left)
        changeCurentCarIndex(direction: .left)
        setHiddenViewImage(direction: .left)
        moveImageView(direction: .left)
        changeHiddenView()
    }
    
    @IBAction func slideRightButtonAction(_ sender: Any) {
        setHiddenViewPosition(direction: .right)
        changeCurentCarIndex(direction: .right)
        setHiddenViewImage(direction: .right)
        moveImageView(direction: .right)
        changeHiddenView()
    }
    
    @IBAction func changeGameDifficultyAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gameDifficulty = .easy
        case 1:
            gameDifficulty = .medium
        case 2:
            gameDifficulty = .hard
        default:
            gameDifficulty = .easy
        }
    }
    
    @IBAction func changeGameLocation(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gameLocation = .city
        case 1:
            gameLocation = .town
        default:
            gameLocation = .city
        }
    }
    
    private func animateCarPicker() {
        if carPickerIsShown {
            UIView.animate(withDuration: 1) {
                self.pickCarViewLeadingConstraint.constant = self.pickCarMainView.frame.width
            }
            UIView.animate(withDuration: 1) {
                self.saveSettingButtonBottomConstraint.constant = 20
                self.pickCarMainView.layoutIfNeeded()
            }
        } else {
            setCurentCarImage()
            UIView.animate(withDuration: 1) {
                self.pickCarViewLeadingConstraint.constant = (self.pickCarMainView.frame.width - self.pickCarInnerView.frame.width) / 2
            }
            UIView.animate(withDuration: 1) {
                self.saveSettingButtonBottomConstraint.constant = -80
                self.pickCarMainView.layoutIfNeeded()
            }
        }
        carPickerIsShown = !carPickerIsShown
    }
    
    private func setHiddenViewPosition(direction: Direction) {
        switch direction {
        case .left:
            hiddenCarImageView.frame.origin.x = carView.frame.width
        case.right:
            hiddenCarImageView.frame.origin.x = -carView.frame.width
        }
    }
    
    private func changeCurentCarIndex(direction: Direction) {
        switch direction {
        case .left:
            if curentCarIndex + 1 < carsArray.count {
                curentCarIndex += 1
            } else {
                curentCarIndex = 0
            }
        case .right:
            if curentCarIndex - 1 >= 0 {
                curentCarIndex -= 1
            } else {
                curentCarIndex = carsArray.count - 1
            }
        }
    }
    
    private func setHiddenViewImage(direction: Direction) {
        hiddenCarImageView.image = carsArray[curentCarIndex].1
    }
    
    private func moveImageView(direction: Direction) {
        switch direction {
        case .left:
            UIView.animate(withDuration: 1) {
                self.curentCarImageView.frame.origin.x = -self.carView.frame.width
                self.hiddenCarImageView.frame.origin.x = 0
            }
        case .right:
            UIView.animate(withDuration: 1) {
                self.curentCarImageView.frame.origin.x = self.carView.frame.width
                self.hiddenCarImageView.frame.origin.x = 0
            }
        }
    }
    
    private func setCurentCarImage() {
        let curentCar = getCurrentCar()
        for carIndex in carsArray.indices {
            if carsArray[carIndex].0 == curentCar {
                carImageView.image = carsArray[carIndex].1
                curentCarIndex = carIndex
                break
            }
        }
    }
    
    private func changeHiddenView() {
        let view = hiddenCarImageView
        hiddenCarImageView = curentCarImageView
        curentCarImageView = view
    }

    private func getCurrentCar() -> Car {
        var car: Car?
        switch carNameLabel.text {
        case "Camaro":
            car = Car.camaro
        case "Police":
            car = Car.police
        default:
            car = Car.viper
        }
        return car!
    }
    
    private func fillCarsArray() {
        carsArray.append((Car.viper, UIImage.getImage(named: .car1_dmg0)))
        carsArray.append((Car.camaro, UIImage.getImage(named: .car3)))
        carsArray.append((Car.police, UIImage.getImage(named: .car2)))
    }
    
    private func readUsedDefaults() {
        racerName = userDefaults.value(forKey: UserDefaultsKeys.userName.rawValue) as? String ?? "User name"
        
        let gameDifString = userDefaults.value(forKey: UserDefaultsKeys.gameDifficulty.rawValue) as? String ?? "Easy"
        gameDifficulty = GameDifficulty(rawValue: gameDifString)
        switch gameDifficulty {
        case .medium:
            difficultyPicker.selectedSegmentIndex = 1
        case .hard:
            difficultyPicker.selectedSegmentIndex = 2
        default:
            difficultyPicker.selectedSegmentIndex = 0
        }
        
        let gameLocationString = userDefaults.value(forKey: UserDefaultsKeys.gameLocation.rawValue) as? String ?? "City"
        gameLocation = GameLocation(rawValue: gameLocationString)
        switch gameLocation {
        case .town:
            locationPicker.selectedSegmentIndex = 1
        default:
            locationPicker.selectedSegmentIndex = 0
        }
                
        immortalitySwitch.isOn = userDefaults.value(forKey: UserDefaultsKeys.immortality.rawValue) as? Bool ?? false
        carNameLabel.text = userDefaults.value(forKey: UserDefaultsKeys.userCar.rawValue) as? String ?? "Viper"
    }
    
    private func setStartViewsSettings() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2

        editNameButton.layer.borderWidth = 1
        editNameButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        editNameButton.layer.cornerRadius = 5
        
        pickCarButton.layer.borderWidth = 1
        pickCarButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        pickCarButton.layer.cornerRadius = 5
        
        saveSettingsButton.layer.borderWidth = 1
        saveSettingsButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        saveSettingsButton.layer.cornerRadius = 5
        
        pickCarViewLeadingConstraint.constant = pickCarMainView.frame.width
        pickCarInnerView.layer.cornerRadius = 10
        pickCarInnerView.layer.borderWidth = 1
        pickCarInnerView.layer.borderColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        carImageView.frame = carView.bounds
        carImageViewSecond.frame = carView.bounds
        carImageViewSecond.frame.origin.x = carView.frame.width
        
        curentCarImageView = carImageView
        hiddenCarImageView = carImageViewSecond
        
        carView.addSubview(carImageView)
        carView.addSubview(carImageViewSecond)
    }
}
