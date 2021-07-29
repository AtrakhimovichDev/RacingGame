//
//  UserScore.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 10.06.21.
//

import Foundation

class UserScore: Codable {
    var userName: String
    var date: String
    var score: Int
    
    internal init(userName: String, date: String, score: Int) {
        self.userName = userName
        self.date = date
        self.score = score
    }
}
