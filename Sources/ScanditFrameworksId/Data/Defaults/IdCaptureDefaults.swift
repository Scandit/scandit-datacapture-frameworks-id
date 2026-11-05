/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

class IdCaptureDefaults {
    private let recommendedCameraSettings: CameraSettingsDefaults

    init(recommendedCameraSettings: CameraSettingsDefaults) {
        self.recommendedCameraSettings = recommendedCameraSettings
    }

    /// The residual set of ID defaults that a framework plugin cannot resolve statically: only the
    /// recommended camera settings, which the two platform wrappers derive differently. Every
    /// other ID default ships as a generated static file.
    func toDynamicEncodable() -> [String: Any?] {
        [Keys.recommendedCameraSettings: recommendedCameraSettings.toEncodable()]
    }

    private enum Keys {
        static let recommendedCameraSettings = "RecommendedCameraSettings"
    }

    static var shared: IdCaptureDefaults = {
        IdCaptureDefaults(
            recommendedCameraSettings:
                CameraSettingsDefaults(
                    cameraSettings: IdCapture.recommendedCameraSettings
                )
        )
    }()
}
