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
    func toSchemaType() -> SchemaTypes.ImageInfo {
        SchemaTypes.ImageInfo(
            front: SchemaTypes.SideImages(
                face: self.face?.toFileString(),
                croppedDocument: self.croppedDocument(for: .front)?.toFileString(),
                frame: self.frame(for: .front)?.toFileString()
            ),
            back: SchemaTypes.SideImages(
                croppedDocument: self.croppedDocument(for: .back)?.toFileString(),
                frame: self.frame(for: .back)?.toFileString()
            )
        )
    }
}

fileprivate extension UIImage {
    func toFileString() -> String? {
        LastFrameData.shared.saveImageToFile(image: self)
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
        guard emitter.hasModeSpecificListenersForEvent(modeId, for: FrameworksIdCaptureEvent.didCaptureId.rawValue)
        else { return }

        let payload: SchemaTypes.IdCaptureListenerDidCaptureId
        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload = SchemaTypes.IdCaptureListenerDidCaptureId(
                id: capturedId.jsonStringWithoutImages,
                imageInfo: capturedId.images.toSchemaType(),
                frontReviewImage: capturedId.verificationResult.dataConsistency?.frontReviewImage?.toFileString(),
                modeId: modeId,
                event: FrameworksIdCaptureEvent.didCaptureId.rawValue
            )
        } else {
            payload = SchemaTypes.IdCaptureListenerDidCaptureId(
                id: capturedId.jsonString,
                modeId: modeId,
                event: FrameworksIdCaptureEvent.didCaptureId.rawValue
            )
        }

        idCapturedEvent.emit(on: emitter, payload: payload.toDictionary())
    }

    public func idCapture(
        _ idCapture: IdCapture,
        didReject capturedId: CapturedId?,
        reason rejectionReason: RejectionReason
    ) {
        guard emitter.hasModeSpecificListenersForEvent(modeId, for: FrameworksIdCaptureEvent.didRejectId.rawValue)
        else { return }

        let payload: SchemaTypes.IdCaptureListenerDidRejectId
        if LastFrameData.shared.isFileSystemCacheEnabled {
            payload = SchemaTypes.IdCaptureListenerDidRejectId(
                rejectionReason: rejectionReason.jsonString,
                id: capturedId?.jsonStringWithoutImages,
                imageInfo: capturedId?.images.toSchemaType(),
                frontReviewImage: capturedId?.verificationResult.dataConsistency?.frontReviewImage?.toFileString(),
                modeId: modeId,
                event: FrameworksIdCaptureEvent.didRejectId.rawValue
            )
        } else {
            payload = SchemaTypes.IdCaptureListenerDidRejectId(
                rejectionReason: rejectionReason.jsonString,
                id: capturedId?.jsonString,
                modeId: modeId,
                event: FrameworksIdCaptureEvent.didRejectId.rawValue
            )
        }

        idRejectedEvent.emit(on: emitter, payload: payload.toDictionary())
    }

    public func reset() {
        idCapturedEvent.reset()
        idRejectedEvent.reset()
    }
}
