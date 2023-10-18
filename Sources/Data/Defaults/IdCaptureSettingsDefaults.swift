/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

struct IdCaptureSettingsDefaults: DefaultsEncodable {
    private let settings: IdCaptureSettings

    init(settings: IdCaptureSettings) {
        self.settings = settings
    }

    func toEncodable() -> [String: Any?] {
        [
            "anonymizationMode": settings.anonymizationMode.jsonString
        ]
    }
}

fileprivate extension IdAnonymizationMode {
    var jsonString: String {
        switch self {
        case .none:
            return "none"
        case .fieldsOnly:
            return "fieldsOnly"
        case .imagesOnly:
            return "imagesOnly"
        case .fieldsAndImages:
            return "fieldsAndImages"
        }
    }
}
