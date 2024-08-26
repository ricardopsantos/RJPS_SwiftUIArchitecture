//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

// swiftlint:disable logs_rule_1

//
// MARK: - CoreLocationManagerV2ViewModel
//

public extension Common {
    final class BasicLocationManagerViewModel: NSObject, ObservableObject {
        public struct Coordinate: Hashable, Equatable {
            public let latitude: Double
            public let longitude: Double
        }

        @Published public private(set) var coordinates: Coordinate?
        public static var lastKnowLocation: (coordinates: Coordinate, date: Date)?
        private let locationManager = CLLocationManager()
        override public init() {
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }

        public func stop() {
            Common_Logs.debug("\(Self.self) stoped")
            locationManager.stopUpdatingLocation()
        }

        public func start() {
            Common_Logs.debug("\(Self.self) started")
            locationManager.startUpdatingLocation()
        }
    }
}

extension Common.BasicLocationManagerViewModel: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinates = .init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        if let coordinates = coordinates {
            Common.BasicLocationManagerViewModel.lastKnowLocation = (coordinates, Date())
        }
    }
}

//
// MARK: - CoreLocationManagerV1ViewModel
//

public extension Common {
    final class SharedLocationManagerViewModel: ObservableObject, Equatable {
        public static func == (
            lhs: Common.SharedLocationManagerViewModel,
            rhs: Common.SharedLocationManagerViewModel
        ) -> Bool {
            lhs.coordinates == rhs.coordinates &&
                lhs.locationIsAuthorized == rhs.locationIsAuthorized
        }

        public struct Coordinate: Hashable, Equatable {
            public let latitude: Double
            public let longitude: Double
        }

        private init() {}

        public static var shared = SharedLocationManagerViewModel()
        @Published public private(set) var locationIsAuthorized: Bool = true
        @Published public private(set) var coordinates: Coordinate?
        public func stop() {
            Common_Logs.debug("\(Self.self) stoped")
            SharedLocationManager.shared.stopUpdatingLocation()
        }

        public func start() {
            Common_Logs.debug("\(Self.self) started")
            let onLocationLost = { [weak self] in
                self?.coordinates = nil
            }
            SharedLocationManager.shared.startUpdatingLocation { [weak self] in
                self?.locationIsAuthorized = SharedLocationManager.shared.locationIsAuthorized
            } onDidUpdateLocation: { [weak self] location in
                self?.locationIsAuthorized = SharedLocationManager.shared.locationIsAuthorized
                if let location {
                    self?.coordinates = Coordinate(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                } else {
                    onLocationLost()
                }
            } onLocationLost: { [weak self] in
                self?.locationIsAuthorized = SharedLocationManager.shared.locationIsAuthorized
                onLocationLost()
            }
        }
    }
}

//
// MARK: - CoreLocationManager
//

public extension Common {
    class SharedLocationManager: NSObject {
        public static var shared = SharedLocationManager()
        @PWThreadSafe private var locationManager: CLLocationManager?
        @PWThreadSafe private static var lastAuthorizationStatus: CLAuthorizationStatus?
        @PWThreadSafe private static var lastKnowLocation: (CLLocation, Date)?
        @PWThreadSafe private var onDidUpdateLocation: ((CLLocation?) -> Void)?
        @PWThreadSafe private var onLocationLost: (() -> Void)?
        @PWThreadSafe private var onLocationAuthorized: (() -> Void)?
    }
}

//
// MARK: - Private
//

fileprivate extension Common.SharedLocationManager {
    var isConfigured: Bool {
        if onDidUpdateLocation == nil || onLocationLost == nil || onLocationAuthorized == nil {
            return false
        }
        return true
    }

    func evalAndPerformAccordingToLocationManagerStatus() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        switch Self.lastAuthorizationStatus ?? .notDetermined {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .restricted: // This application is not authorized to use location services.
            ()
        case .denied: // User has explicitly denied authorization for this application
            stopUpdatingLocation()
        case .authorizedAlways: // User has granted authorization to use their location at any time.
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse: // User has granted authorization to use their location only while they are using your app
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        @unknown default:
            ()
        }
    }
}

//
// MARK: - Public
//

public extension Common.SharedLocationManager {
    var lastKnowLocation: (location: CLLocation, date: Date)? {
        let result = Self.lastKnowLocation
        if result == nil, locationIsAuthorized, Common_Utils.onSimulator {
            // On simulator, if the developer forgot to turn on location, will return nil.
            let random = CLLocationCoordinate2D.lisbon
            Common_Logs.warning("Turn on 'Simulator Location' for simulator! Returned random value...")
            return (.init(latitude: random.latitude, longitude: random.longitude), .now)
        }
        return result
    }

    var locationIsExplicitlyDenied: Bool {
        Self.lastAuthorizationStatus == .denied
    }

    var locationIsAuthorized: Bool {
        Self.lastAuthorizationStatus?.locationIsAuthorized ?? false
    }

    func startUpdatingLocation(
        onLocationAuthorized: @escaping (() -> Void),
        onDidUpdateLocation: @escaping ((CLLocation?) -> Void),
        onLocationLost: @escaping (() -> Void)
    ) {
        if isConfigured {
            if let locationIsAuthorized = Self.lastAuthorizationStatus?.locationIsAuthorized, locationIsAuthorized {
                // If we are calling [startUpdatingLocation], and we have already configured, and we have authorisation, then
                // lets call the [onLocationAuthorized]
                self.onLocationAuthorized?()
                if let lastKnowLocation = lastKnowLocation?.location {
                    onDidUpdateLocation(lastKnowLocation)
                }
            }
        } else {
            self.onLocationAuthorized = onLocationAuthorized
            self.onDidUpdateLocation = onDidUpdateLocation
            self.onLocationLost = onLocationLost
        }
        evalAndPerformAccordingToLocationManagerStatus()
    }

    func resumeUpdatingLocation() {
        if !isConfigured {
            fatalError("Not configured. Use \(String(describing: startUpdatingLocation))")
        }
        evalAndPerformAccordingToLocationManagerStatus()
    }

    func stopUpdatingLocation() {
        onLocationLost?()
        onDidUpdateLocation?(nil)
        locationManager?.stopUpdatingLocation()
    }
}

//
// MARK: - CLLocationManagerDelegate
//

extension Common.SharedLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let lastStatusWasAuthorized = Self.lastAuthorizationStatus?.locationIsAuthorized ?? false
        let newStatusIsAuthorized = status.locationIsAuthorized
        let newStatusIsNotAuthorized = !newStatusIsAuthorized
        Self.lastAuthorizationStatus = status
        if newStatusIsAuthorized {
            onLocationAuthorized?()
            evalAndPerformAccordingToLocationManagerStatus()
        } else if lastStatusWasAuthorized, newStatusIsNotAuthorized {
            stopUpdatingLocation()
            evalAndPerformAccordingToLocationManagerStatus()
        } else if status == .notDetermined {
            evalAndPerformAccordingToLocationManagerStatus()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            Self.lastKnowLocation = (location, Date.userDate)
            onDidUpdateLocation?(location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !Common_Utils.onSimulator else {
            return
        }
    }
}

//
// MARK: - CLAuthorizationStatus extension
//

extension CLAuthorizationStatus {
    var locationIsAuthorized: Bool {
        switch self {
        case .authorizedAlways,
             .authorizedWhenInUse: true
        case .denied,
             .notDetermined,
             .restricted: false
        default: false
        }
    }
}

//
// MARK: - CLAuthorizationStatus extension
//
private extension Common.SharedLocationManager {
    static func sampleUsage() {
        Common.SharedLocationManager.shared.startUpdatingLocation {
            Common_Logs.debug("User location start updating")
        } onDidUpdateLocation: { location in
            if let location {
                Common_Logs.debug("User location updated to \(location)")
            } else {
                Common_Logs.debug("User location lost?")
            }
        } onLocationLost: {
            Common_Logs.debug("User location lost")
        }
    }
}

// swiftlint:enable logs_rule_1
