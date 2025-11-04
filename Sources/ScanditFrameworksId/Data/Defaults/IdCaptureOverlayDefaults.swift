/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

// Todo: Check this latest if we can use the native extensions that are deprecated
extension IdLayoutStyle {
    var stringValue: String {
        switch self {
        case .rounded:
            return "rounded"
        case .square:
            return "square"
        }
    }
}

// Todo: Check this latest if we can use the native extensions that are deprecated
extension IdLayoutLineStyle {
    var stringValue: String {
        switch self {
        case .bold:
            return "bold"
        case .light:
            return "light"
        }
    }
}

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
            "DefaultRejectedBrush": rejectedBrush.toEncodable(),
            "defaultIdLayoutStyle": IdCaptureOverlay.defaultIdLayoutStyle.stringValue,
            "defaultIdLayoutLineStyle": IdCaptureOverlay.defaultIdLayoutLineStyle.stringValue,
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
