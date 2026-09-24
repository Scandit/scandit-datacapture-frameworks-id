/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

struct IdCaptureOverlayDefaults: DefaultsEncodable {
    private let capturedBrush: EncodableBrush
    private let localizedBrush: EncodableBrush
    private let rejectedBrush: EncodableBrush

    init(capturedBrush: EncodableBrush,
         localizedBrush: EncodableBrush,
         rejectedBrush: EncodableBrush) {
        self.capturedBrush = capturedBrush
        self.localizedBrush = localizedBrush
        self.rejectedBrush = rejectedBrush
    }

    func toEncodable() -> [String: Any?] {
        [
            "DefaultCapturedBrush": capturedBrush.toEncodable(),
            "DefaultLocalizedBrush": localizedBrush.toEncodable(),
            "DefaultRejectedBrush": rejectedBrush.toEncodable()
        ]
    }

    static var shared: IdCaptureOverlayDefaults = {
        IdCaptureOverlayDefaults(
            capturedBrush: EncodableBrush(brush: IdCaptureOverlay.defaultCapturedBrush),
            localizedBrush: EncodableBrush(brush: IdCaptureOverlay.defaultLocalizedBrush),
            rejectedBrush: EncodableBrush(brush: IdCaptureOverlay.defaultRejectedBrush)
        )
    }()
}
