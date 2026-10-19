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

/// Factory for creating IdCaptureModule commands from method calls.
/// Maps method names to their corresponding command implementations.
public class IdCaptureModuleCommandFactory {
    /// Creates a command from a FrameworksMethodCall.
    ///
    /// - Parameter module: The IdCaptureModule instance to bind to the command
    /// - Parameter method: The method call containing method name and arguments
    /// - Returns: The corresponding command, or nil if method is not recognized
    public static func create(module: IdCaptureModule, _ method: FrameworksMethodCall) -> IdCaptureModuleCommand? {
        switch method.method {
        case "resetIdCaptureMode":
            return ResetIdCaptureModeCommand(module: module, method)
        case "setModeEnabledState":
            return SetModeEnabledStateCommand(module: module, method)
        case "updateIdCaptureMode":
            return UpdateIdCaptureModeCommand(module: module, method)
        case "applyIdCaptureModeSettings":
            return ApplyIdCaptureModeSettingsCommand(module: module, method)
        case "updateFeedback":
            return UpdateFeedbackCommand(module: module, method)
        case "updateIdCaptureOverlay":
            return UpdateIdCaptureOverlayCommand(module: module, method)
        case "finishDidCaptureCallback":
            return FinishDidCaptureCallbackCommand(module: module, method)
        case "finishDidRejectCallback":
            return FinishDidRejectCallbackCommand(module: module, method)
        case "addIdCaptureListener":
            return AddIdCaptureListenerCommand(module: module, method)
        case "removeIdCaptureListener":
            return RemoveIdCaptureListenerCommand(module: module, method)
        default:
            return nil
        }
    }
}
