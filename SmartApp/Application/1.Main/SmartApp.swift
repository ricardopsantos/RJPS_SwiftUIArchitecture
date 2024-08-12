//
//  LaunchApp.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Common
import DesignSystem

// @main
struct SmartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    let appState: AppStateViewModel
    init() {
        SetupManager.shared.setup()
        let userService = DependenciesManager.Services.userService
        let sampleService = DependenciesManager.Services.sampleService
        let userRepository = DependenciesManager.Repository.userRepository
        let nonSecureAppPreferences = DependenciesManager.Repository.nonSecureAppPreferences
        let secureAppPreferences = DependenciesManager.Repository.secureAppPreferences
        let config: ConfigurationViewModel!

        let onTesting = UITestingManager.Options.onUITesting.enabled || Common_Utils.onUnitTests
        if onTesting {
            config = .init(
                userService: userService,
                weatherService: DependenciesManager.Services.weatherServiceMock,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAServiceMock,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        } else {
            config = .init(
                userService: userService,
                weatherService: DependenciesManager.Services.weatherService,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAService,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        }

        let model: ModelDto.GetWeatherResponse = .mockBigLoad!
        let key = "xxxxx"

        Common.CoreDataStack.shared.syncClearAll()

      //  Common.CoreDataStack.shared.syncStore(model, key: key, params: [])
/*
        print(Common.CoreDataStack.shared.syncRetrieve(
            ModelDto.GetWeatherResponse.self,
            key: key,
            params: []
        ))*/
        Task {
            
            await Common.CoreDataStack.shared.aSyncClearAll()

            await Common.CoreDataStack.shared.aSyncStore(model, key: key, params: [])
            
            if let record = await Common.CoreDataStack.shared.aSyncRetrieve(
                ModelDto.GetWeatherResponse.self,
                key: key,
                params: []
            ) {
                print(record.recordDate)
            } else {
                print("fail")
            }
            
            await Common.CoreDataStack.shared.aSyncClearAll()

            if let record = await Common.CoreDataStack.shared.aSyncRetrieve(
                ModelDto.GetWeatherResponse.self,
                key: key,
                params: []
            ) {
                print("fail")
            } else {
                print("sucess")
            }
            
        }

        /*
          let model: ModelDto.GetWeatherResponse = .mockBigLoad!
          let key = "xxxxx"
          Common.CoreDataStack.shared.syncStore(model, key: key, params: [])

          print(Common.CoreDataStack.shared.syncRetrieve(ModelDto.GetWeatherResponse.self,
                                                         key: key,
                                                         params: []))

         Common.CoreDataStack.shared.syncClearAll()

         print(Common.CoreDataStack.shared.syncRetrieve(ModelDto.GetWeatherResponse.self,
                                                        key: key,
                                                        params: []))
         */
        self.appState = .init()
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .onAppear(perform: {
                    InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
                })
                .environmentObject(appState)
                .environmentObject(configuration)
        }
    }
}
