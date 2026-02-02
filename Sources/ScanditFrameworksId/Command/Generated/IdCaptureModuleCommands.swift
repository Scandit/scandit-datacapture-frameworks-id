/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2025- Scandit AG. All rights reserved.
 */

// THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
// Generator: scripts/bridge_generator/generate.py
// Schema: scripts/bridge_generator/schemas/id.json

import Foundation
import ScanditFrameworksCore

/// Generated IdCaptureModule command implementations.
/// Each command extracts parameters in its initializer and executes via IdCaptureModule.

/// Resets the ID capture mode
public class ResetIdCaptureModeCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        module.resetIdCaptureMode(
            modeId: modeId,
            result: result
        )
    }
}
/// Sets the enabled state of the ID capture mode
public class SetModeEnabledStateCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    private let enabled: Bool
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
        self.enabled = method.argument(key: "enabled") ?? Bool()
    }

    public func execute(result: FrameworksResult) {
        module.setModeEnabledState(
            modeId: modeId,
            enabled: enabled,
            result: result
        )
    }
}
/// Updates the ID capture mode configuration
public class UpdateIdCaptureModeCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeJson: String
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeJson = method.argument(key: "modeJson") ?? ""
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        guard !modeJson.isEmpty else {
            result.reject(code: "MISSING_PARAMETER", message: "Required parameter 'modeJson' is missing", details: nil)
            return
        }
        module.updateIdCaptureMode(
            modeJson: modeJson,
            modeId: modeId,
            result: result
        )
    }
}
/// Applies new settings to the ID capture mode
public class ApplyIdCaptureModeSettingsCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let settingsJson: String
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.settingsJson = method.argument(key: "settingsJson") ?? ""
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        guard !settingsJson.isEmpty else {
            result.reject(
                code: "MISSING_PARAMETER",
                message: "Required parameter 'settingsJson' is missing",
                details: nil
            )
            return
        }
        module.applyIdCaptureModeSettings(
            settingsJson: settingsJson,
            modeId: modeId,
            result: result
        )
    }
}
/// Updates the ID capture feedback configuration
public class UpdateFeedbackCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let feedbackJson: String
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.feedbackJson = method.argument(key: "feedbackJson") ?? ""
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        guard !feedbackJson.isEmpty else {
            result.reject(
                code: "MISSING_PARAMETER",
                message: "Required parameter 'feedbackJson' is missing",
                details: nil
            )
            return
        }
        module.updateFeedback(
            feedbackJson: feedbackJson,
            modeId: modeId,
            result: result
        )
    }
}
/// Updates the ID capture overlay configuration
public class UpdateIdCaptureOverlayCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let overlayJson: String
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.overlayJson = method.argument(key: "overlayJson") ?? ""
    }

    public func execute(result: FrameworksResult) {
        guard !overlayJson.isEmpty else {
            result.reject(
                code: "MISSING_PARAMETER",
                message: "Required parameter 'overlayJson' is missing",
                details: nil
            )
            return
        }
        module.updateIdCaptureOverlay(
            overlayJson: overlayJson,
            result: result
        )
    }
}
/// Finish callback for ID capture did capture event
public class FinishDidCaptureCallbackCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    private let enabled: Bool
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
        self.enabled = method.argument(key: "enabled") ?? Bool()
    }

    public func execute(result: FrameworksResult) {
        module.finishDidCaptureCallback(
            modeId: modeId,
            enabled: enabled,
            result: result
        )
    }
}
/// Finish callback for ID capture did reject event
public class FinishDidRejectCallbackCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    private let enabled: Bool
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
        self.enabled = method.argument(key: "enabled") ?? Bool()
    }

    public func execute(result: FrameworksResult) {
        module.finishDidRejectCallback(
            modeId: modeId,
            enabled: enabled,
            result: result
        )
    }
}
/// Register persistent event listener for ID capture events
public class AddIdCaptureListenerCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        // Register/unregister event callbacks
        result.registerModeSpecificCallback(
            modeId,
            eventNames: [
                "IdCaptureListener.didCaptureId",
                "IdCaptureListener.didRejectId",
            ]
        )
        module.addIdCaptureListener(
            modeId: modeId,
            result: result
        )
    }
}
/// Unregister event listener for ID capture events
public class RemoveIdCaptureListenerCommand: IdCaptureModuleCommand {
    private let module: IdCaptureModule
    private let modeId: Int
    public init(module: IdCaptureModule, _ method: FrameworksMethodCall) {
        self.module = module
        self.modeId = method.argument(key: "modeId") ?? Int()
    }

    public func execute(result: FrameworksResult) {
        // Register/unregister event callbacks
        result.unregisterModeSpecificCallback(
            modeId,
            eventNames: [
                "IdCaptureListener.didCaptureId",
                "IdCaptureListener.didRejectId",
            ]
        )
        module.removeIdCaptureListener(
            modeId: modeId,
            result: result
        )
    }
}
