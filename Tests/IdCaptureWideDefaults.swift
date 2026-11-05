/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

import Foundation
import ScanditFrameworksCore
import ScanditIdCapture

@testable import ScanditFrameworksId

/// Test-only *wide* defaults builder for the Id module.
///
/// Production only ever emits the narrow, dynamic payload
/// (`IdCaptureDefaults.toDynamicEncodable()`), so the wide `toEncodable()` graph - and the leaf
/// `IdCaptureOverlayDefaults` / `IdCaptureSettingsDefaults` builders reachable only through it -
/// lives here, in the test target only. It is the oracle `IdCaptureDefaultsDriftTests` compares
/// the SoT snapshot against: real SDK objects, dumped wide.
///
/// Named `IdCaptureWideDefaults` so it does not clash with the narrow production
/// `IdCaptureDefaults`, which the test target sees via `@testable import`.
///
/// The key strings are literals rather than `IdCaptureDefaults.Keys` references because that
/// enum is `private` in production - file-scoped, so `@testable import` cannot reach it.
struct IdCaptureWideDefaults: DefaultsEncodable {
    private let recommendedCameraSettings: CameraSettingsDefaults
    private let idCaptureFeedback: IdCaptureFeedback
    private let overlayDefaults: IdCaptureOverlayDefaults
    private let settingsDefaults: IdCaptureSettingsDefaults

    init(
        idCaptureFeedback: IdCaptureFeedback,
        recommendedCameraSettings: CameraSettingsDefaults,
        overlayDefaults: IdCaptureOverlayDefaults,
        settingsDefaults: IdCaptureSettingsDefaults
    ) {
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
            "IdCaptureSettings": settingsDefaults.toEncodable(),
            "defaultSuccessSound": IdCaptureFeedback.defaultSuccessSound.jsonString,
            "defaultFailureSound": IdCaptureFeedback.defaultFailureSound.jsonString,
        ]
    }

    static var shared: IdCaptureWideDefaults = {
        IdCaptureWideDefaults(
            idCaptureFeedback: .default,
            recommendedCameraSettings:
                CameraSettingsDefaults(
                    cameraSettings: IdCapture.recommendedCameraSettings
                ),
            overlayDefaults: .shared,
            settingsDefaults: IdCaptureSettingsDefaults(settings: IdCaptureSettings())
        )
    }()
}
