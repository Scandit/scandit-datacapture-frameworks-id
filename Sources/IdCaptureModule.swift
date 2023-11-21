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

public class IdCaptureModule: NSObject, FrameworkModule {
    private let idCaptureListener: FrameworksIdCaptureListener
    private let idCaptureDeserializer: IdCaptureDeserializer

    private var context: DataCaptureContext?
    
    private var verifier: AamvaBarcodeVerifier?

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
        idCaptureDeserializer.delegate = nil
        idCapture = nil
        removeListener()
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

    public func finishDidLocalizeId(enabled: Bool) {
        idCaptureListener.finishDidLocalizeId(enabled: enabled)
    }

    public func finishTimeout(enabled: Bool) {
        idCaptureListener.finishTimeout(enabled: enabled)
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

    public func verifyCapturedIdAamvaViz(jsonString: String, result: FrameworksResult) {
        let capturedId = CapturedId(jsonString: jsonString)
        let verificationResult = AAMVAVizBarcodeComparisonVerifier().verify(capturedId)
        result.success(result: verificationResult.jsonString)
    }

    public func verifyCaptureIdMrzViz(jsonString: String, result: FrameworksResult) {
        let capturedId = CapturedId(jsonString: jsonString)
        let verificationResult = VizMrzComparisonVerifier().verify(capturedId)
        result.success(result: verificationResult.jsonString)
    }

    public func resetMode() {
        idCapture?.reset()
    }
    
    public func setModeEnabled(enabled: Bool) {
        idCapture?.isEnabled = enabled
    }
    
    public func isModeEnabled() -> Bool {
        return idCapture?.isEnabled == true
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
            mode.isEnabled = JSONValue.bool(forKey: "enabled")
        }
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
                                      from JSONValue: JSONValue) {}
}

extension IdCaptureModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }

    public func didDisposeDataCaptureContext() {
        self.context = nil
    }
}
