/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

// THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
// Generator: scripts/bridge_generator/generate.py
// Schema: scripts/bridge_generator/schemas/id.json
//
// Fixture-driven round-trip tests: every fixture under
// serialization/tests/<module>/<name>/valid/ must decode without throwing
// (and its re-encoded/re-decoded form must decode too); every fixture
// under .../invalid/ must throw UNLESS the validation keyword that rejects
// it (minimum, pattern, oneOf, ...) is outside the set the hand-rolled
// validator supports, in which case the test is skipped (`XCTSkip`) rather
// than asserting a throw the code can't produce.

// For `UnknownPropertyError`, which core declares once for every module.
import ScanditFrameworksCore
import XCTest

@testable import ScanditFrameworksId

final class SchemaTypesTest: XCTestCase {

    func testIdCaptureListenerDidCaptureIdAcceptsValid_basic_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\",\"documentNumber\":\"D1234567\"}",
              "imageInfo": {
                "front": { "face": null, "croppedDocument": null, "frame": null },
                "back": { "croppedDocument": null, "frame": null }
              },
              "frontReviewImage": "base64image",
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidCaptureIdAcceptsValid_no_image_info_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\",\"documentNumber\":\"D1234567\"}",
              "frontReviewImage": null,
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_missing_event_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "modeId": 1
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_missing_id_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_missing_modeId_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_unknown_property_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId",
              "unknownProperty": true
            }
            """#.utf8
        )
        // Asserts the TYPE: the unknown-key class must surface as core's one shared
        // `UnknownPropertyError`, so a cross-module catch keeps matching.
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw)) {
            error in
            XCTAssertTrue(error is UnknownPropertyError, "expected UnknownPropertyError, got \(error)")
        }
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_wrong_event_const_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId.wrongEventName"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_wrong_type_id_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": 12345,
              "modeId": 1,
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidCaptureIdRejectsInvalid_wrong_type_modeId_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "modeId": "not-an-int",
              "event": "IdCaptureListener.didCaptureId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidCaptureId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdAcceptsValid_basic_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "invalidFormat",
              "id": "{\"fullName\":\"John Doe\",\"documentNumber\":\"D1234567\"}",
              "imageInfo": {
                "front": { "face": null, "croppedDocument": null, "frame": null },
                "back": { "croppedDocument": null, "frame": null }
              },
              "frontReviewImage": "base64image",
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidRejectIdAcceptsValid_bluetooth_rejection_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "bluetoothCommunicationError",
              "id": null,
              "frontReviewImage": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidRejectIdAcceptsValid_cloud_request_failed_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "cloudRequestFailed",
              "id": null,
              "frontReviewImage": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidRejectIdAcceptsValid_manipulated_document_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "manipulatedDocument",
              "id": null,
              "frontReviewImage": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidRejectIdAcceptsValid_null_id_no_image_info_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "frontReviewImage": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        let parsed = try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)
        let reEncoded = try JSONEncoder().encode(parsed)
        XCTAssertNoThrow(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: reEncoded))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_missing_event_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "modeId": 1
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_missing_modeId_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_missing_rejectionReason_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "id": "{\"fullName\":\"John Doe\"}",
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_unknown_property_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId",
              "unknownProperty": true
            }
            """#.utf8
        )
        // Asserts the TYPE: the unknown-key class must surface as core's one shared
        // `UnknownPropertyError`, so a cross-module catch keeps matching.
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw)) {
            error in
            XCTAssertTrue(error is UnknownPropertyError, "expected UnknownPropertyError, got \(error)")
        }
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_wrong_event_const_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId.wrongEventName"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_wrong_type_modeId_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "timeout",
              "id": null,
              "modeId": "not-an-int",
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }

    func testIdCaptureListenerDidRejectIdRejectsInvalid_wrong_type_rejectionReason_json() throws {
        // Raw string literal (#"""..."""#): a plain Swift multi-line literal processes
        // backslash escapes, so a fixture carrying an embedded JSON string (any property
        // with contentMediaType: application/json) would have its \" collapsed to a bare "
        // and stop being valid JSON. Raw literals keep the fixture bytes verbatim.
        let raw = Data(
            #"""
            {
              "rejectionReason": "notARealReason",
              "id": null,
              "modeId": 1,
              "event": "IdCaptureListener.didRejectId"
            }
            """#.utf8
        )
        XCTAssertThrowsError(try JSONDecoder().decode(SchemaTypes.IdCaptureListenerDidRejectId.self, from: raw))
    }
}
