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
    case offroad
    case mud
    
    func getImage() -> UIImage {
        switch self {
        case .road:
            return UIImage.getImage(named: .road)!
        case .grass:
            return UIImage.getImage(named: .grass)!
        case .offroad:
            return UIImage.getImage(named: .offroad)!
        case .mud:
            return UIImage.getImage(named: .mud)!
        }
    }
}
