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
            "anonymizationMode": settings.anonymizationMode.jsonString,
            "rejectVoidedIds": settings.rejectVoidedIds,
            "decodeBackOfEuropeDrivingLicense": settings.decodeBackOfEuropeanDrivingLicense,
            "rejectExpiredIds": settings.rejectExpiredIds,
            "rejectIdsExpiringIn": settings.rejectIdsExpiringIn?.json,
            "rejectNotRealIdCompliant": settings.rejectNotRealIdCompliant,
            "rejectForgedAamvaBarcodes": settings.rejectForgedAamvaBarcodes,
            "rejectInconsistentData": settings.rejectInconsistentData,
            "rejectHolderBelowAge": settings.rejectHolderBelowAge,
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


fileprivate extension Duration {
    var json: [String: Any] {
      return [
        "years": self.years,
        "months": self.months,
        "days": self.days
      ]
    }
}
