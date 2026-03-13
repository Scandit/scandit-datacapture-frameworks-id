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

    public init(
        emitter: Emitter,
        deserializer: IdCaptureDeserializer = IdCaptureDeserializer()
    ) {
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

    public override func getDefaults() -> [String: Any?] {
        IdCaptureDefaults.shared.toEncodable()
    }

    public func addIdCaptureListener(modeId: Int, result: FrameworksResult) {
        getModeFromCache(modeId)?.addListener()
        result.successAndKeepCallback(result: nil)
    }

    public func removeIdCaptureListener(modeId: Int, result: FrameworksResult) {
        getModeFromCache(modeId)?.removeListener()
        result.success()
    }

    public func finishDidCaptureCallback(modeId: Int, enabled: Bool, result: FrameworksResult) {
        getModeFromCache(modeId)?.finishDidCaptureId(enabled: enabled)
        result.success()
    }

    public func finishDidRejectCallback(modeId: Int, enabled: Bool, result: FrameworksResult) {
        getModeFromCache(modeId)?.finishDidRejectId(enabled: enabled)
        result.success()
    }

    public func resetIdCaptureMode(modeId: Int, result: FrameworksResult) {
        getModeFromCache(modeId)?.reset()
        result.success()
    }

    public func setModeEnabledState(modeId: Int, enabled: Bool, result: FrameworksResult) {
        getModeFromCache(modeId)?.setModeEnabled(enabled: enabled)
        result.success()
    }

    public func isModeEnabled(modeId: Int) -> Bool {
        getModeFromCache(modeId)?.isEnabled == true
    }

    public func isTopmostModeEnabled() -> Bool {
        getTopmostMode()?.isEnabled == true
    }

    public func setTopmostModeEnabled(enabled: Bool) {
        getTopmostMode()?.setModeEnabled(enabled: enabled)
    }

    public func updateIdCaptureMode(modeJson: String, modeId: Int, result: FrameworksResult) {
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

    public func applyIdCaptureModeSettings(settingsJson: String, modeId: Int, result: FrameworksResult) {
        guard let mode = getModeFromCache(modeId) else {
            result.success(result: nil)
            return
        }
        do {
            try mode.applySettings(modeSettingsJson: settingsJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func updateIdCaptureOverlay(overlayJson: String, result: FrameworksResult) {
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

    public func updateFeedback(feedbackJson: String, modeId: Int, result: FrameworksResult) {
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

    open override func createCommand(_ method: any FrameworksMethodCall) -> (any BaseCommand)? {
        IdCaptureModuleCommandFactory.create(module: self, method)
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
        let mode: FrameworksIdCaptureMode? =
            if parentId != -1 {
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

        dispatchMain { [weak self] in
            guard let self = self else {
                return
            }
            do {
                guard let idCaptureMode = mode?.mode else {
                    Log.error("ID Capture mode is not available for overlay creation")
                    return
                }
                let overlay = try self.idCaptureDeserializer.overlay(
                    fromJSONString: creationParams.overlayJson,
                    withMode: idCaptureMode
                )

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
