/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

enum ScanditFrameworksIdError: Error {
    case nilVerifier
    case unknownCloudVerificationError
}

open class IdCaptureModule: NSObject, FrameworkModule {
    private let idCaptureListener: FrameworksIdCaptureListener
    private let idCaptureDeserializer: IdCaptureDeserializer

    private var context: DataCaptureContext?

    private var verifier: AamvaBarcodeVerifier?

    private var modeEnabled = true

    private var idCaptureFeedback: IdCaptureFeedback?

    private var idCapture: IdCapture? {
        willSet {
            idCapture?.removeListener(idCaptureListener)
        }
        didSet {
            idCapture?.addListener(idCaptureListener)
        }
    }

    public init(idCaptureListener: FrameworksIdCaptureListener,
                deserializer: IdCaptureDeserializer = IdCaptureDeserializer()) {
        self.idCaptureListener = idCaptureListener
        self.idCaptureDeserializer = deserializer
    }

    public func didStart() {
        idCaptureDeserializer.delegate = self
        Deserializers.Factory.add(idCaptureDeserializer)
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        idCapture = nil
        removeListener()
        idCaptureDeserializer.delegate = nil
        Deserializers.Factory.remove(idCaptureDeserializer)
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
    }

    public let defaults: DefaultsEncodable = IdCaptureDefaults.shared

    public func addListener() {
        idCaptureListener.enable()
    }

    public func removeListener() {
        idCaptureListener.disable()
    }

    public func addAsyncListener() {
        idCaptureListener.enableAsync()
    }

    public func removeAsyncListener() {
        idCaptureListener.disableAsync()
    }

    public func finishDidCaptureId(enabled: Bool) {
        idCaptureListener.finishDidCaptureId(enabled: enabled)
    }

    public func finishDidRejectId(enabled: Bool) {
        idCaptureListener.finishDidRejectId(enabled: enabled)
    }

    public func createAamvaBarcodeVerifier(result: FrameworksResult) {
        guard let context = context else {
            result.reject(error: ScanditFrameworksCoreError.nilDataCaptureContext)
            return
        }
        verifier = AamvaBarcodeVerifier(context: context)
        result.success(result: nil)
    }

    public func verifyCapturedIdWithCloud(jsonString: String, result: FrameworksResult) {
        guard let verifier = verifier else {
            result.reject(error: ScanditFrameworksIdError.nilVerifier)
            return
        }
        let capturedId = CapturedId(jsonString: jsonString)
        verifier.verify(capturedId) { verificationResult, error in
            if let error = error {
                result.reject(error: error)
                return
            }
            if let verificationResult = verificationResult {
                result.success(result: verificationResult.jsonString)
            } else {
                result.reject(error: ScanditFrameworksIdError.unknownCloudVerificationError)
            }
        }
    }

    public func resetMode() {
        idCapture?.reset()
    }

    public func setModeEnabled(enabled: Bool) {
        modeEnabled = enabled
        idCapture?.isEnabled = enabled
    }

    public func isModeEnabled() -> Bool {
        return idCapture?.isEnabled == true
    }

    public func updateModeFromJson(modeJson: String, result: FrameworksResult) {
        guard let mode = idCapture else {
            result.success(result: nil)
            return
        }
        do {
            try idCaptureDeserializer.updateMode(mode, fromJSONString: modeJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func applyModeSettings(modeSettingsJson: String, result: FrameworksResult) {
        guard let mode = idCapture else {
            result.success(result: nil)
            return
        }
        do {
            let settings = try idCaptureDeserializer.settings(fromJSONString: modeSettingsJson)
            mode.apply(settings)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func updateOverlay(overlayJson: String, result: FrameworksResult) {
        guard let overlay: IdCaptureOverlay = DataCaptureViewHandler.shared.findFirstOverlayOfType() else {
            result.success(result: nil)
            return
        }

        do {
            try idCaptureDeserializer.update(overlay, fromJSONString: overlayJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func updateFeedback(feedbackJson: String, result: FrameworksResult) {
        do {
            idCaptureFeedback = try IdCaptureFeedback(fromJSON: JSONValue(string: feedbackJson))

            // in case we don't have a mode yet, it will return success and cache the new
            // feedback to be applied after the creation of the view.
             if let mode = idCapture, let feedback = idCaptureFeedback {
                 mode.feedback = feedback
                 idCaptureFeedback = nil
            }
            result.success()
        } catch let error {
            result.reject(error: error)
        }
    }
}

extension IdCaptureModule: IdCaptureDeserializerDelegate {
    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didStartDeserializingMode mode: IdCapture,
                                      from JSONValue: JSONValue) {}

    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didFinishDeserializingMode mode: IdCapture,
                                      from JSONValue: JSONValue) {
        if JSONValue.containsKey("enabled") {
            modeEnabled = JSONValue.bool(forKey: "enabled")
        }

        mode.isEnabled = modeEnabled
        idCapture = mode
    }

    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didStartDeserializingSettings settings: IdCaptureSettings,
                                      from JSONValue: JSONValue) {}

    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didFinishDeserializingSettings settings: IdCaptureSettings,
                                      from JSONValue: JSONValue) {}

    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didStartDeserializingOverlay overlay: IdCaptureOverlay,
                                      from JSONValue: JSONValue) {}

    public func idCaptureDeserializer(_ deserializer: IdCaptureDeserializer,
                                      didFinishDeserializingOverlay overlay: IdCaptureOverlay,
                                      from JSONValue: JSONValue) {
        if JSONValue.containsKey("frontSideTextHint") {
            overlay.setFrontSideTextHint(JSONValue.string(forKey: "frontSideTextHint", default: ""))
        }

        if JSONValue.containsKey("backSideTextHint") {
            overlay.setBackSideTextHint(JSONValue.string(forKey: "backSideTextHint", default: ""))
        }
        if JSONValue.containsKey("textHintPosition") {
            let textHintPositionJson = JSONValue.string(forKey: "textHintPosition", default: "")
            var textHintPosition = TextHintPosition.aboveViewfinder
            SDCTextHintPositionFromJSONString(textHintPositionJson, &textHintPosition)
            overlay.textHintPosition = textHintPosition
        }
        overlay.showTextHints = JSONValue.bool(forKey: "showTextHints", default: true)
    }
}


extension IdCaptureModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }

    public func didDisposeDataCaptureContext() {
        self.context = nil
    }

    public func dataCaptureContext(addMode modeJson: String) throws {
        if JSONValue(string: modeJson).string(forKey: "type") != "idCapture" {
            return
        }

        guard let dcContext = self.context else {
            return
        }

        let mode = try idCaptureDeserializer.mode(fromJSONString: modeJson, with: dcContext)
        dcContext.addMode(mode)

        // update feedback in case the update call did run before the creation of the mode
        if let feedback = idCaptureFeedback {
            dispatchMain { [weak self] in
                mode.feedback = feedback
                self?.idCaptureFeedback = nil
            }
        }
    }

    public func dataCaptureContext(removeMode modeJson: String) {
        if  JSONValue(string: modeJson).string(forKey: "type") != "idCapture" {
            return
        }

        guard let dcContext = self.context else {
            return
        }

        guard let mode = self.idCapture else {
            return
        }
        dcContext.removeMode(mode)
        self.idCapture = nil
    }

    public func dataCaptureContextAllModeRemoved() {
        self.idCapture = nil
    }

    public func dataCaptureView(addOverlay overlayJson: String, to view: DataCaptureView) throws {
        if  JSONValue(string: overlayJson).string(forKey: "type") != "idCapture" {
            return
        }

        guard let mode = self.idCapture else {
            return
        }

        try dispatchMainSync {
            let overlay = try idCaptureDeserializer.overlay(fromJSONString: overlayJson, withMode: mode)
            DataCaptureViewHandler.shared.addOverlayToView(view, overlay: overlay)
        }
    }
}
