//
//  UIImage+enum.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.06.21.
//

import UIKit

extension UIImage {
    static func getImage(named: Images) -> UIImage? {
        return UIImage(named: named.rawValue)
    }
}
