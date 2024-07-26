//
//  UserRepositoryProtocol.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import Combine
//
import Common

public protocol UserRepositoryProtocol {
    
    // MARK: - Utilities
    
    /// Emits actions related to the user repository, allowing listeners to react to changes.
    /// - Parameter filter: An array of actions to filter the output stream.
    /// - Returns: A publisher emitting user repository actions.
    func output(_ filter: [UserRepositoryOutputActions]) -> AnyPublisher<UserRepositoryOutputActions, Never>
    
    // MARK: - Properties
     
     /// The currently saved user, if available.
     var user: Model.User? { get }
     
     // MARK: - Methods
     
     /// Saves a user object to the repository.
     /// - Parameter user: The user object to be saved.
     func saveUser(user: Model.User)
     
     /// Saves user details to the repository.
     /// - Parameters:
     ///   - name: The name of the user.
     ///   - email: The email address of the user.
     ///   - dateOfBirth: The date of birth of the user.
     ///   - gender: The gender of the user.
     ///   - country: The country of the user.
     func saveUser(
         name: String,
         email: String,
         dateOfBirth: Date,
         gender: Gender,
         country: String
     )
}
