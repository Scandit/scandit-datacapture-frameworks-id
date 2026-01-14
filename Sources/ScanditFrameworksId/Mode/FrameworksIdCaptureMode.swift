/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2025- Scandit AG. All rights reserved.
 */

import ScanditIdCapture
import ScanditFrameworksCore

public class FrameworksIdCaptureMode: FrameworksBaseMode {
    private let listener: FrameworksIdCaptureListener
    private let captureContext: DefaultFrameworksCaptureContext
    private let deserializer: IdCaptureDeserializer

    private var _modeId: Int = -1
    private var _parentId: Int? = nil
    private var isListenerAdded: Bool = false

    public var modeId: Int {
        return _modeId
    }

    public var parentId: Int? {
        return _parentId
    }

    public private(set) var mode: IdCapture!

    public var isEnabled: Bool {
        get {
            return mode.isEnabled
        }
        set {
            mode.isEnabled = newValue
        }
    }

    public init(
        listener: FrameworksIdCaptureListener,
        captureContext: DefaultFrameworksCaptureContext,
        deserializer: IdCaptureDeserializer
    ) {
        self.listener = listener
        self.captureContext = captureContext
        self.deserializer = deserializer
    }

    private func deserializeMode(
        dataCaptureContext: DataCaptureContext,
        creationData: IdCaptureModeCreationData
    ) throws {
        mode = try deserializer.mode(fromJSONString: creationData.modeJson, with: dataCaptureContext)
        _modeId = creationData.modeId
        _parentId = creationData.parentId

        captureContext.addMode(mode: mode)

        if creationData.hasListener {
            mode.addListener(listener)
            isListenerAdded = true
        }

        mode.isEnabled = creationData.isEnabled
    }

    public func dispose() {
        listener.reset()
        if isListenerAdded {
            mode.removeListener(listener)
            isListenerAdded = false
        }
        captureContext.removeMode(mode: mode)
    }

    public func addListener() {
        if !isListenerAdded {
            mode.addListener(listener)
            isListenerAdded = true
        }
    }

    public func removeListener() {
        if isListenerAdded {
            mode.removeListener(listener)
            isListenerAdded = false
        }
    }

    public func finishDidCaptureId(enabled: Bool) {
        listener.finishDidCaptureId(enabled: enabled)
    }

    public func finishDidRejectId(enabled: Bool) {
        listener.finishDidRejectId(enabled: enabled)
    }

    public func setModeEnabled(enabled: Bool) {
        mode.isEnabled = enabled
    }

    public func applySettings(modeSettingsJson: String) throws {
        let settings = try deserializer.settings(fromJSONString: modeSettingsJson)
        mode.apply(settings)
    }

    public func updateModeFromJson(modeJson: String) throws {
        try deserializer.updateMode(mode, fromJSONString: modeJson)
    }

    public func updateFeedback(feedback: IdCaptureFeedback) {
        mode.feedback = feedback
    }

    public func reset() {
        mode.reset()
    }

    public func cancelPendingEvents() {
        listener.reset()
    }

    // MARK: - Factory Method

    public static func create(
        emitter: Emitter,
        captureContext: DefaultFrameworksCaptureContext,
        creationData: IdCaptureModeCreationData,
        dataCaptureContext: DataCaptureContext,
        deserializer: IdCaptureDeserializer
    ) throws -> FrameworksIdCaptureMode {
        let listener = FrameworksIdCaptureListener(emitter: emitter, modeId: creationData.modeId)
        let mode = FrameworksIdCaptureMode(
            listener: listener,
            captureContext: captureContext,
            deserializer: deserializer
        )

        try mode.deserializeMode(dataCaptureContext: dataCaptureContext, creationData: creationData)
        return mode
    }
}
