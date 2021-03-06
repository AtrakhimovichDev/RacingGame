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
    
    private var userSettings: UserSettings?
    
    private var carPickerIsShown = false
    private var carsArray: [(Car,UIImage?)] = []
    private var currentCarIndex = 0
    private let userDefaults = UserDefaults.standard
    
    private var racerName = "" {
        didSet {
            userNameLabel.text = racerName
            userSettings?.name = racerName
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
        if let userSettings = self.userSettings {
            let userSettingsData = try? JSONEncoder().encode(userSettings)
            userDefaults.setValue(userSettingsData, forKey: UserDefaultsKeys.userSettings.rawValue)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func chooseCarButtonAction(_ sender: Any) {
        animateCarPicker()
        carNameLabel.text = carsArray[currentCarIndex].0.rawValue
        userSettings?.car = carsArray[currentCarIndex].0
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
        case 1:
            userSettings?.difficulty = .medium
        case 2:
            userSettings?.difficulty = .hard
        default:
            userSettings?.difficulty = .easy
        }
    }
    
    @IBAction func changeGameLocation(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            userSettings?.location = .town
        default:
            userSettings?.location = .city
        }
    }
    
    @IBAction func immortalitySwitchAction(_ sender: Any) {
        userSettings?.immortality = immortalitySwitch.isOn
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
            if currentCarIndex + 1 < carsArray.count {
                currentCarIndex += 1
            } else {
                currentCarIndex = 0
            }
        case .right:
            if currentCarIndex - 1 >= 0 {
                currentCarIndex -= 1
            } else {
                currentCarIndex = carsArray.count - 1
            }
        }
    }
    
    private func setHiddenViewImage(direction: Direction) {
        hiddenCarImageView.image = carsArray[currentCarIndex].1
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
                currentCarIndex = carIndex
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
        carsArray.append((Car.viper, UIImage.getImage(named: .viper_dmg0)))
        carsArray.append((Car.camaro, UIImage.getImage(named: .camaro_dmg0)))
        carsArray.append((Car.police, UIImage.getImage(named: .police_dmg0)))
    }
    
    private func readUsedDefaults() {
        if let userSettingsData = userDefaults.value(forKey: .userSettings) as? Data {
            do {
                let userSettings = try JSONDecoder().decode(UserSettings.self, from: userSettingsData)
                self.userSettings = userSettings
                fillUserSettingsData()
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
            let userSettings = UserSettings(name: racerName, difficulty: .easy, location: .city, immortality: false, car: .viper)
            self.userSettings = userSettings
        }
    }
    
    private func fillUserSettingsData() {
        racerName = userSettings?.name ?? "Street racer"
        switch userSettings?.difficulty {
        case .medium:
            difficultyPicker.selectedSegmentIndex = 1
        case .hard:
            difficultyPicker.selectedSegmentIndex = 2
        default:
            difficultyPicker.selectedSegmentIndex = 0
        }
        switch userSettings?.location {
        case .town:
            locationPicker.selectedSegmentIndex = 1
        default:
            locationPicker.selectedSegmentIndex = 0
        }
        immortalitySwitch.isOn = userSettings?.immortality ?? false
        carNameLabel.text = userSettings?.car.rawValue
        
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
