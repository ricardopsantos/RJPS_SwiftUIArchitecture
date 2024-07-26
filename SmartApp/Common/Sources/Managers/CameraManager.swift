//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public extension Common {
    class CameraManager: NSObject {
        public static var shared = CameraManager()

        private var onCameraAccessDenied: (() -> Void)?
        private var onCameraAccessAuthorized: (() -> Void)?

        public func requestAccess(
            for mediaType: AVMediaType = .video,
            onCameraAccessDenied: @escaping (() -> Void),
            onCameraAccessAuthorized: @escaping (() -> Void)
        ) {
            self.onCameraAccessDenied = onCameraAccessDenied
            self.onCameraAccessAuthorized = onCameraAccessAuthorized
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { [weak self] accessGranted in
                Common_Utils.executeInMainTread { [weak self] in
                    guard let self else {
                        return
                    }
                    if accessGranted {
                        self.onCameraAccessAuthorized!()
                    } else {
                        self.onCameraAccessDenied!()
                    }
                }
            })
        }

        /// If there is no access, will display alert to take user to iPhone Settings
        public func requestAccess(
            for mediaType: AVMediaType = .video,
            from: UIViewController,
            onCameraAccessAuthorized: @escaping (() -> Void)
        ) {
            self.onCameraAccessAuthorized = onCameraAccessAuthorized
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { [weak self] accessGranted in
                guard let self else {
                    return
                }
                Common_Utils.executeInMainTread { [weak self] in
                    if accessGranted {
                        self?.onCameraAccessAuthorized!()
                    } else {
                        self?.presentAlertCameraAccessNeeded(for: mediaType, from: from)
                    }
                }
            })
        }

        /// If there is no access, will display alert to take user to iPhone Settings
        public func presentAlertCameraAccessNeeded(
            for mediaType: AVMediaType = .video,
            from: UIViewController,
            title: String = "Need Camera Access",
            message: String = "Camera access is required to make full use of this app.",
            cancelOption: String = "Cancel",
            goToSettings: String = "Open app Settings"
        ) {
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { accessGranted in
                Common_Utils.executeInMainTread {
                    if !accessGranted {
                        let alert = UIAlertController(
                            title: title,
                            message: message,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(
                            title: cancelOption,
                            style: .default,
                            handler: nil
                        ))
                        alert.addAction(UIAlertAction(
                            title: goToSettings,
                            style: .cancel,
                            handler: { _ in
                                UIApplication.openAppSettings()
                            }
                        ))
                        from.present(alert, animated: true)
                    }
                }
            })
        }
    }
}
