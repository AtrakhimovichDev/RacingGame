//
//  UsedDefaults+enum.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 6.06.21.
//

import Foundation

extension UserDefaults {
    func value(forKey key: UserDefaultsKeys) -> Any? {
        return self.value(forKey: key.rawValue)
    }
}
