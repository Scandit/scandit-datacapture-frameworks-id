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
    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2
    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicValue<Bool>()
    private let idCapturedEvent = EventWithResult<Bool>(event: Event(.didCaptureId),
                                                        timeout: defaultTimeoutInterval)
    private let idRejectedEvent = EventWithResult<Bool>(event: Event(.didRejectId),
                                                        timeout: defaultTimeoutInterval)

    public func finishDidCaptureId(enabled: Bool) {
        idCapturedEvent.unlock(value: enabled)
    }

    public func finishDidRejectId(enabled: Bool) {
        idRejectedEvent.unlock(value: enabled)
    }

    public func enableAsync() {
        [idCapturedEvent, idRejectedEvent].forEach {
            $0.timeout = Self.asyncTimeoutInterval
        }
        enable()
    }

    public func disableAsync() {
        disable()
        [idCapturedEvent, idRejectedEvent].forEach {
            $0.timeout = Self.defaultTimeoutInterval
        }
    }

    public func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        guard emitter.hasListener(for: .didCaptureId) else { return }
        guard isEnabled.value else { return }

        let payload: [String: Any?]
        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload = [
                "id": capturedId.jsonStringWithoutImages,
                "imageInfo": capturedId.images.toJson()
            ]
        } else {
             payload = [
                "id":  capturedId.jsonString
            ]
        }

        idCapturedEvent.emit(on: emitter, payload: payload)
    }

    public func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason rejectionReason: RejectionReason) {
        guard emitter.hasListener(for: .didRejectId) else { return }
        guard isEnabled.value else { return }

        var payload: [String: Any?] = [
            "rejectionReason": rejectionReason.jsonString
        ]

        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload["id"] = capturedId?.jsonStringWithoutImages
            payload["imageInfo"] = capturedId?.images.toJson()
        } else {
            payload["id"] = capturedId?.jsonString
        }

        idRejectedEvent.emit(on: emitter, payload: payload)
    }

    public func enable() {
        if !isEnabled.value {
            isEnabled.value = true
        }
    }

    public func disable() {
        if isEnabled.value {
            isEnabled.value = false
        }
        idCapturedEvent.reset()
        idRejectedEvent.reset()
    }
}


