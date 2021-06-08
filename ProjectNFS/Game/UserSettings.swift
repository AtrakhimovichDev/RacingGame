//
//  UserSettings.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 8.06.21.
//

import Foundation

class UserSettings: Codable {
    var name: String
    var difficulty: GameDifficulty
    var location: GameLocation
    var immortality: Bool
    var car: Car
    
    internal init(name: String, difficulty: GameDifficulty, location: GameLocation, immortality: Bool, car: Car) {
        self.name = name
        self.difficulty = difficulty
        self.location = location
        self.immortality = immortality
        self.car = car
    }
}
