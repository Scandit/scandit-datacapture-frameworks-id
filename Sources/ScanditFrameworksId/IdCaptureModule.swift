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

open class IdCaptureModule: BasicFrameworkModule<FrameworksIdCaptureMode> {
    private let emitter: Emitter
    private let idCaptureDeserializer: IdCaptureDeserializer
    private let captureContext = DefaultFrameworksCaptureContext.shared
    private let captureViewHandler = DataCaptureViewHandler.shared

    private var idCaptureFeedback: IdCaptureFeedback?

    public init(emitter: Emitter,
                deserializer: IdCaptureDeserializer = IdCaptureDeserializer()) {
        self.emitter = emitter
        self.idCaptureDeserializer = deserializer
        super.init()
    }

    public override func didStart() {
        super.didStart()
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public override func didStop() {
        for mode in getAllModesInCache() {
            mode.dispose()
        }
        removeAllModesFromCache()
        clearPostModeCreationActions(nil)
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        super.didStop()
    }

    public let defaults: DefaultsEncodable = IdCaptureDefaults.shared

    public func addListener(modeId: Int) {
        getModeFromCache(modeId)?.addListener()
    }

    public func removeListener(modeId: Int) {
        getModeFromCache(modeId)?.removeListener()
    }

    public func finishDidCaptureId(modeId: Int, enabled: Bool) {
        getModeFromCache(modeId)?.finishDidCaptureId(enabled: enabled)
    }

    public func finishDidRejectId(modeId: Int, enabled: Bool) {
        getModeFromCache(modeId)?.finishDidRejectId(enabled: enabled)
    }

    public func resetMode(modeId: Int) {
        getModeFromCache(modeId)?.reset()
    }

    public func setModeEnabled(modeId: Int, enabled: Bool) {
        getModeFromCache(modeId)?.setModeEnabled(enabled: enabled)
    }

    public func isModeEnabled(modeId: Int) -> Bool {
        return getModeFromCache(modeId)?.isEnabled == true
    }

    public func isTopmostModeEnabled() -> Bool {
        return getTopmostMode()?.isEnabled == true
    }

    public func setTopmostModeEnabled(enabled: Bool) {
        getTopmostMode()?.setModeEnabled(enabled: enabled)
    }

    public func updateModeFromJson(modeId: Int, modeJson: String, result: FrameworksResult) {
        guard let mode = getModeFromCache(modeId) else {
            result.success(result: nil)
            return
        }
        do {
            try mode.updateModeFromJson(modeJson: modeJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func applyModeSettings(modeId: Int, modeSettingsJson: String, result: FrameworksResult) {
        guard let mode = getModeFromCache(modeId) else {
            result.success(result: nil)
            return
        }
        do {
            try mode.applySettings(modeSettingsJson: modeSettingsJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func updateOverlay(overlayJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let overlay: IdCaptureOverlay = self.captureViewHandler.findFirstOverlayOfType() else {
                result.success(result: nil)
                return
            }

            do {
                try self.idCaptureDeserializer.update(overlay, fromJSONString: overlayJson)
                result.success(result: nil)
            } catch {
                result.reject(error: error)
            }
        }
        dispatchMain(block)
    }

    public func updateFeedback(modeId: Int, feedbackJson: String, result: FrameworksResult) {
        guard let mode = getModeFromCache(modeId) else {
            result.success(result: nil)
            return
        }

        do {
            let feedback = try IdCaptureFeedback(fromJSON: JSONValue(string: feedbackJson))
            mode.updateFeedback(feedback: feedback)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    // MARK: - Execute Method
    public func execute(method: FrameworksMethodCall, result: FrameworksResult) -> Bool {
        switch method.method {
        case "getDefaults":
            let jsonString = defaults.stringValue
            result.success(result: jsonString)

        case "addIdCaptureListener":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            addListener(modeId: modeId)
            result.success(result: nil)

        case "removeIdCaptureListener":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            removeListener(modeId: modeId)
            result.success(result: nil)

        case "finishDidCaptureId":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            let enabled: Bool = method.argument(key: "enabled") ?? false
            finishDidCaptureId(modeId: modeId, enabled: enabled)
            result.success(result: nil)

        case "finishDidRejectId":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            let enabled: Bool = method.argument(key: "enabled") ?? false
            finishDidRejectId(modeId: modeId, enabled: enabled)
            result.success(result: nil)

        case "reset":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            resetMode(modeId: modeId)
            result.success(result: nil)

        case "getLastFrameData":
            result.success(result: nil)

        case "setModeEnabledState":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            let enabled: Bool = method.argument(key: "enabled") ?? false
            setModeEnabled(modeId: modeId, enabled: enabled)
            result.success(result: nil)

        case "updateIdCaptureMode":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            if let modeJson: String = method.argument(key: "modeJson") {
                updateModeFromJson(modeId: modeId, modeJson: modeJson, result: result)
            } else {
                result.reject(code: "-1", message: "Invalid mode JSON argument", details: nil)
            }

        case "applyIdCaptureModeSettings":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            if let modeSettingsJson: String = method.argument(key: "settingsJson") {
                applyModeSettings(modeId: modeId, modeSettingsJson: modeSettingsJson, result: result)
            } else {
                result.reject(code: "-1", message: "Invalid mode settings JSON argument", details: nil)
            }

        case "updateIdCaptureOverlay":
            if let overlayJson: String = method.arguments() {
                updateOverlay(overlayJson: overlayJson, result: result)
            } else {
                result.reject(code: "-1", message: "Invalid overlay JSON argument", details: nil)
            }

        case "updateFeedback":
            guard let modeId: Int = method.argument(key: "modeId") else {
                result.reject(code: "-1", message: "Invalid modeId argument", details: nil)
                return true
            }
            if let feedbackJson: String = method.argument(key: "feedbackJson") {
                updateFeedback(modeId: modeId, feedbackJson: feedbackJson, result: result)
            } else {
                result.reject(code: "-1", message: "Invalid feedback JSON argument", details: nil)
            }

        default:
            return false
        }
        return true
    }
}


extension IdCaptureModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(addMode modeJson: String) throws {
        let creationParams = IdCaptureModeCreationData.fromJson(modeJson)
        if creationParams.modeType != "idCapture" {
            return
        }
        guard let dcContext = self.captureContext.context else {
            Log.error("Unable to add the id capture mode to the context. DataCaptureContext is nil.")
            return
        }
        do {
            let idCaptureMode = try FrameworksIdCaptureMode.create(
                emitter: emitter,
                captureContext: captureContext,
                creationData: creationParams,
                dataCaptureContext: dcContext,
                deserializer: idCaptureDeserializer
            )

            addModeToCache(modeId: creationParams.modeId, mode: idCaptureMode)

            for action in getPostModeCreationActions(creationParams.modeId) {
                action()
            }
            for action in getPostModeCreationActionsByParent(creationParams.parentId) {
                action()
            }
        } catch {
            Log.error("Error adding mode to context", error: error)
        }
    }

    public func dataCaptureContext(removeMode modeJson: String) {
        if JSONValue(string: modeJson).string(forKey: "type") != "idCapture" {
            return
        }

        let modeId = JSONValue(string: modeJson).integer(forKey: "modeId", default: -1)

        guard let mode = removeModeFromCache(modeId) else {
            Log.error("Unable to remove the IdCaptureMode from the DataCaptureContext, the mode is null.")
            return
        }

        mode.dispose()
        clearPostModeCreationActions(modeId)
    }

    public func dataCaptureContextAllModeRemoved() {
        for mode in getAllModesInCache() {
            mode.dispose()
        }
        removeAllModesFromCache()
        clearPostModeCreationActions(nil)
    }

    public func dataCaptureView(addOverlay overlayJson: String, to view: FrameworksDataCaptureView) throws {
        let creationParams = IdCaptureOverlayCreationData.fromJson(overlayJson)
        if !creationParams.isValid {
            return
        }

        let parentId = view.parentId ?? -1
        let mode: FrameworksIdCaptureMode? = if parentId != -1 {
            getModeFromCacheByParent(parentId) as? FrameworksIdCaptureMode
        } else {
            getModeFromCache(creationParams.modeId)
        }

        if mode == nil {
            if parentId != -1 {
                addPostModeCreationActionByParent(parentId) {
                    try? self.dataCaptureView(addOverlay: overlayJson, to: view)
                }
            } else {
                addPostModeCreationAction(creationParams.modeId) {
                    try? self.dataCaptureView(addOverlay: overlayJson, to: view)
                }
            }
            return
        }

        dispatchMain {[weak self] in
            guard let self = self else {
                return
            }
            do {
                let overlay = try self.idCaptureDeserializer.overlay(fromJSONString: creationParams.overlayJson, withMode: mode!.mode)
                
                if let frontSideTextHint = creationParams.frontSideTextHint {
                    overlay.setFrontSideTextHint(frontSideTextHint)
                }
                
                if let backSideTextHint = creationParams.backSideTextHint {
                    overlay.setBackSideTextHint(backSideTextHint)
                }
                
                if let textHintPosition = creationParams.textHintPosition {
                    overlay.textHintPosition = textHintPosition
                }
                
                overlay.showTextHints = creationParams.showTextHints
                
                view.addOverlay(overlay)
            } catch {
                Log.error("Unable to add the IdCaptureOverlay.", error: error)
            }
        }
    }
}
