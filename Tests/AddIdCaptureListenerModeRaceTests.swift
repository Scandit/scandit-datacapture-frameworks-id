/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import XCTest

@testable import ScanditFrameworksId

/// Regression coverage for SDC-32821: registering the Id Capture listener before the
/// mode exists in the module's mode cache used to silently no-op while still reporting
/// success (via successAndKeepCallback), so JS believed it registered and no event ever
/// fired.
///
/// A real FrameworksIdCaptureMode can't be constructed in a unit test (it requires a live
/// DataCaptureContext / native mode deserialization), so this verifies the fix at the
/// retry-queue boundary: registering against an unknown modeId must defer via
/// addPostModeCreationAction (as BarcodeBatchModule.registerBarcodeBatchListenerForEvents
/// already does) instead of completing immediately with no way to retry once the mode is
/// created.
private class SpyFrameworksResult: FrameworksResult {
    private(set) var successCallCount = 0
    private(set) var successAndKeepCallbackCallCount = 0

    func success(result: Any?) {
        successCallCount += 1
    }

    func successAndKeepCallback(result: Any?) {
        successAndKeepCallbackCallCount += 1
    }

    func reject(code: String, message: String?, details: Any?) {}
    func reject(error: Error) {}
}

private class NoopEmitter: Emitter {
    func emit(name: String, payload: [String: Any?]) {}
    func hasListener(for event: String) -> Bool { false }
    func hasViewSpecificListenersForEvent(_ viewId: Int, for event: String) -> Bool { false }
    func hasModeSpecificListenersForEvent(_ modeId: Int, for event: String) -> Bool { false }
}

final class AddIdCaptureListenerModeRaceTests: XCTestCase {

    func testAddIdCaptureListenerBeforeModeExistsQueuesRetryInsteadOfReportingSuccess() {
        let module = IdCaptureModule(emitter: NoopEmitter())
        // Use a modeId that is guaranteed not to be in this module's own mode cache.
        let modeId = Int.max - 12345
        let result = SpyFrameworksResult()

        module.addIdCaptureListener(modeId: modeId, result: result)

        // The bug: success was reported unconditionally (via successAndKeepCallback) even
        // though no listener was attached and nothing was queued to retry once the mode
        // is created.
        XCTAssertEqual(
            result.successAndKeepCallbackCallCount,
            0,
            "must not report success before the mode exists and the listener is actually attached"
        )

        let queuedActions = module.getPostModeCreationActions(modeId)
        XCTAssertEqual(
            queuedActions.count,
            1,
            "must queue exactly one retry action via addPostModeCreationAction, "
                + "matching BarcodeBatchModule.registerBarcodeBatchListenerForEvents"
        )
    }
}
