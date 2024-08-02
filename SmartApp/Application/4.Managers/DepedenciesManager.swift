//
//  CoreProtocolsResolved.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
//
import Domain
import Core
import Common

public class DependenciesManager {
    private init() {}
    enum Services {
        public static var dataUSAService: DataUSAServiceProtocol { DataUSAService.shared }
    }
}
