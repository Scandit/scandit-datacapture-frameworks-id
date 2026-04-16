/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

class IdCaptureDefaults: DefaultsEncodable {
    private let recommendedCameraSettings: CameraSettingsDefaults
    private let idCaptureFeedback: IdCaptureFeedback
    private let overlayDefaults: IdCaptureOverlayDefaults
    private let settingsDefaults: IdCaptureSettingsDefaults

    init(idCaptureFeedback: IdCaptureFeedback,
         recommendedCameraSettings: CameraSettingsDefaults,
         overlayDefaults: IdCaptureOverlayDefaults,
         settingsDefaults: IdCaptureSettingsDefaults) {
        self.recommendedCameraSettings = recommendedCameraSettings
        self.idCaptureFeedback = idCaptureFeedback
        self.overlayDefaults = overlayDefaults
        self.settingsDefaults = settingsDefaults
    }

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "IdCaptureFeedback": idCaptureFeedback.jsonString,
            "IdCaptureOverlay": overlayDefaults.toEncodable(),
            "IdCaptureSettings": settingsDefaults.toEncodable()
        ]
    }

    static var shared: IdCaptureDefaults = {
        IdCaptureDefaults(
            idCaptureFeedback: .default, recommendedCameraSettings:
                CameraSettingsDefaults(
                    cameraSettings: IdCapture.recommendedCameraSettings
                ),
            overlayDefaults: .shared,
            settingsDefaults: IdCaptureSettingsDefaults(settings: IdCaptureSettings())
        )
    }()
}
