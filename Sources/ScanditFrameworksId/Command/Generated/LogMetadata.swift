/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

// THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
// Generator: scripts/bridge_generator/generate.py
// Schema: scripts/bridge_generator/schemas/id.json

import Foundation
import ScanditFrameworksCore

/// Per-method `LogRecord` level and category overrides for the id
/// bridge surface. Consulted by `ScanditLogger.emit`: per-frame / per-scan
/// callbacks log at `.trace` under their category label, so they only show once
/// the level is raised to `.trace`.
///
/// Registered as a side effect of the generated `<Module>CommandFactory`'s
/// first `create` call -- no customer wiring required.
enum LogMetadata {
    static let metadata: [String: MethodLogMetadata] = [
        "finishDidCaptureCallback": MethodLogMetadata(level: .trace, category: .events),
        "finishDidRejectCallback": MethodLogMetadata(level: .trace, category: .events),
    ]

    static let registered: Void = {
        ScanditLogger.shared.registerMethodMetadata(metadata)
    }()
}
