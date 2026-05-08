/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

public enum FrameworksIdCaptureEvent: String, CaseIterable {
    case didCaptureId = "IdCaptureListener.didCaptureId"
    case didLocalizeId = "IdCaptureListener.didLocalizeId"
    case didRejectId = "IdCaptureListener.didRejectId"
    case timeout = "IdCaptureListener.didTimeout"
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

open class FrameworksIdCaptureListener: NSObject, IdCaptureListener {
    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2
    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicBool()
    private let idCapturedEvent = EventWithResult<Bool>(event: Event(.didCaptureId),
                                                        timeout: defaultTimeoutInterval)
    private let idLocalizedEvent = EventWithResult<Bool>(event: Event(.didLocalizeId),
                                                        timeout: defaultTimeoutInterval)
    private let idRejectedEvent = EventWithResult<Bool>(event: Event(.didRejectId),
                                                        timeout: defaultTimeoutInterval)
    private let timeoutEvent = EventWithResult<Bool>(event: Event(.timeout),
                                                     timeout: defaultTimeoutInterval)

    public func finishDidCaptureId(enabled: Bool) {
        idCapturedEvent.unlock(value: enabled)
    }

    public func finishDidRejectId(enabled: Bool) {
        idRejectedEvent.unlock(value: enabled)
    }

    public func finishDidLocalizeId(enabled: Bool) {
        idLocalizedEvent.unlock(value: enabled)
    }

    public func finishTimeout(enabled: Bool) {
        timeoutEvent.unlock(value: enabled)
    }

    public func enableAsync() {
        [idCapturedEvent, idLocalizedEvent, idRejectedEvent, timeoutEvent].forEach {
            $0.timeout = Self.asyncTimeoutInterval
        }
    }

    public func disableAsync() {
        [idCapturedEvent, idLocalizedEvent, idRejectedEvent, timeoutEvent].forEach {
            $0.timeout = Self.defaultTimeoutInterval
        }
    }

    public func idCapture(_ idCapture: IdCapture,
                          didCaptureIn session: IdCaptureSession,
                          frameData: FrameData) {
        guard emitter.hasListener(for: .didCaptureId) else { return }
        emit(idCapturedEvent, data: frameData, session: session, mode: idCapture)
    }

    public func idCapture(_ idCapture: IdCapture,
                          didLocalizeIn session: IdCaptureSession,
                          frameData: FrameData) {
        guard emitter.hasListener(for: .didLocalizeId) else { return }
        emit(idLocalizedEvent, data: frameData, session: session, mode: idCapture)
    }

    public func idCapture(_ idCapture: IdCapture,
                          didRejectIn session: IdCaptureSession,
                          frameData: FrameData) {
        guard emitter.hasListener(for: .didRejectId) else { return }
        emit(idRejectedEvent, data: frameData, session: session, mode: idCapture)
    }

    public func idCapture(_ idCapture: IdCapture,
                          didTimeoutIn session:
                          IdCaptureSession, frameData: FrameData) {
        guard emitter.hasListener(for: .timeout) else { return }
        emit(timeoutEvent, data: frameData, session: session, mode: idCapture)
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
        idLocalizedEvent.reset()
        timeoutEvent.reset()
    }

    private func emit(_ event: EventWithResult<Bool>,
                      data: FrameData,
                      session: IdCaptureSession,
                      mode: IdCapture) {
        guard isEnabled.value else { return }
        defer { LastFrameData.shared.frameData = nil }
        LastFrameData.shared.frameData = data
        let payload = [
            "session": session.jsonString
        ]

        event.emit(on: emitter, payload: payload)
    }
}
