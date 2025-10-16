/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

public enum FrameworksIdCaptureEvent: String, CaseIterable {
    case didCaptureId = "IdCaptureListener.didCaptureId"
    case didRejectId = "IdCaptureListener.didRejectId"
}

fileprivate extension Event {
    init(_ event: FrameworksIdCaptureEvent) {
        self.init(name: event.rawValue)
    }
}

fileprivate extension Emitter {
    func hasListener(for event: FrameworksIdCaptureEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

fileprivate extension IdImages {
    func toJson() -> [String: Any?] {
        return [
            "front": [
                "face": self.face?.toFileString(),
                "frame": self.frame(for: .front)?.toFileString(),
                "croppedDocument": self.croppedDocument(for: .front)?.toFileString()
            ],
            "back": [
                "croppedDocument": self.croppedDocument(for: .back)?.toFileString(),
                "frame": self.frame(for: .back)?.toFileString()
            ]
        ]
    }
}

fileprivate extension UIImage {
    func toFileString() -> String? {
        return LastFrameData.shared.saveImageToFile(image: self)
    }
}

open class FrameworksIdCaptureListener: NSObject, IdCaptureListener {
    private let emitter: Emitter
    private let modeId: Int

    public init(emitter: Emitter, modeId: Int) {
        self.emitter = emitter
        self.modeId = modeId
    }

    private var isEnabled = AtomicValue<Bool>()
    private let idCapturedEvent = EventWithResult<Bool>(event: Event(.didCaptureId))
    private let idRejectedEvent = EventWithResult<Bool>(event: Event(.didRejectId))

    public func finishDidCaptureId(enabled: Bool) {
        idCapturedEvent.unlock(value: enabled)
    }

    public func finishDidRejectId(enabled: Bool) {
        idRejectedEvent.unlock(value: enabled)
    }


    public func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        guard emitter.hasModeSpecificListenersForEvent(modeId, for: FrameworksIdCaptureEvent.didCaptureId.rawValue) else { return }

        var payload: [String: Any?]
        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload = [
                "id": capturedId.jsonStringWithoutImages,
                "imageInfo": capturedId.images.toJson(),
                "frontReviewImage": capturedId.verificationResult.dataConsistency?.frontReviewImage?.toFileString(),
            ]
        } else {
             payload = [
                "id":  capturedId.jsonString
            ]
        }
        payload["modeId"] = modeId

        idCapturedEvent.emit(on: emitter, payload: payload)
    }

    public func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason rejectionReason: RejectionReason) {
        guard emitter.hasModeSpecificListenersForEvent(modeId, for: FrameworksIdCaptureEvent.didRejectId.rawValue) else { return }

        var payload: [String: Any?] = [
            "rejectionReason": rejectionReason.jsonString
        ]

        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload["id"] = capturedId?.jsonStringWithoutImages
            payload["imageInfo"] = capturedId?.images.toJson()
            payload["frontReviewImage"] = capturedId?.verificationResult.dataConsistency?.frontReviewImage?.toFileString()
        } else {
            payload["id"] = capturedId?.jsonString
        }
        payload["modeId"] = modeId

        idRejectedEvent.emit(on: emitter, payload: payload)
    }


    public func reset() {
        idCapturedEvent.reset()
        idRejectedEvent.reset()
    }
}


