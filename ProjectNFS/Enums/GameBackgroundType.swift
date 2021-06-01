//
//  GameBackgroundType.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 31.05.21.
//

import UIKit

enum GameBackgroundType {
    case road
    case grass
    
    func getImage() -> UIImage {
        switch self {
        case .road:
            return UIImage(named: "road_icon") ?? UIImage()
        case .grass:
            return UIImage(named: "grass_icon") ?? UIImage()
        }
    }
}
