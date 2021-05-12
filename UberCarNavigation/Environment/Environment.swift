//
//  EnvironmentManager.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//

import Foundation
import UIKit

public enum Environment {
    // MARK: - Keys
    
    enum Keys {
        enum Plist {
            static let GOOGLE_SERVICES_API = "GOOGLE_SERVICES_API"
        }
    }
    
    // MARK: - Plist
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    /**
        Google services API key
     */
    static let GOOGLE_SERVICES_API: String = {
        guard let api = Environment.infoDictionary[Keys.Plist.GOOGLE_SERVICES_API] as? String else{
            fatalError("GOOGLE_SERVICES_API error")
        }
        return api
    }()
}

