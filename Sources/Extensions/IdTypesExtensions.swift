/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditIdCapture

extension RejectionReason {
    var jsonString: String {
        switch self {
        case .timeout:
            return "timeout"
        case .notAcceptedDocumentType:
            return "notAcceptedDocumentType"
        case .invalidFormat:
            return "invalidFormat"
        case .documentVoided:
            return "documentVoided"
        }
    }
}
