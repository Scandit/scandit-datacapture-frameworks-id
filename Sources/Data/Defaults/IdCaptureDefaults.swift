/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

class IdCaptureDefaults: DefaultsEncodable {
    private let recommendedCameraSettings: CameraSettingsDefaults
    private let overlayDefaults: IdCaptureOverlayDefaults
    private let settingsDefaults: IdCaptureSettingsDefaults

    init(recommendedCameraSettings: CameraSettingsDefaults,
         overlayDefaults: IdCaptureOverlayDefaults,
         settingsDefaults: IdCaptureSettingsDefaults) {
        self.recommendedCameraSettings = recommendedCameraSettings
        self.overlayDefaults = overlayDefaults
        self.settingsDefaults = settingsDefaults
    }

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "IdCaptureOverlay": overlayDefaults.toEncodable(),
            "IdCaptureSettings": settingsDefaults.toEncodable()
        ]
    }

    static var shared: IdCaptureDefaults = {
        IdCaptureDefaults(
            recommendedCameraSettings:
                CameraSettingsDefaults(
                    cameraSettings: IdCapture.recommendedCameraSettings
                ),
            overlayDefaults: .shared,
            settingsDefaults: IdCaptureSettingsDefaults(settings: IdCaptureSettings())
        )
    }()
}
