//
//  UIFont+Custom.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 27.05.21.
//

import UIKit

extension UIFont {
    static func jerseySharp(of size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "JerseySharp", size: size) else { return UIFont.systemFont(ofSize: size) }
        return font
    }
    
}
