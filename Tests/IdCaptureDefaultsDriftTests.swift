/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

import ScanditIdCapture
import XCTest

@testable import ScanditFrameworksId

/// Layer-2 defaults-drift test for the Id module (SDC-33331, DESIGN.md section 4) - the
/// iOS mirror of `IdCaptureDefaultsDriftTest.kt`
/// (`frameworks/shared/android/scandit-datacapture-frameworks-id/src/androidTest/.../defaults/`).
///
/// The comparator (`DefaultsDriftComparator.swift`) and fixture
/// (`Fixtures/expected_defaults_ios.json`) are committed symlinks to Core's real files - see
/// `CoreDefaultsDriftTests.swift` for the rationale.
final class IdCaptureDefaultsDriftTests: XCTestCase {

    private static func expectedDefaultsURL() throws -> URL {
        try XCTUnwrap(
            Bundle.module.url(forResource: "expected_defaults_ios", withExtension: "json"),
            "could not locate expected_defaults_ios.json in the test bundle - "
                + "run scripts/defaults_generator/generate.py, then check "
                + "Tests/Fixtures/expected_defaults_ios.json is still a valid symlink"
        )
    }

    func testIdDefaultsMatchTheSotGeneratedExpectedSnapshot() throws {
        let url = try Self.expectedDefaultsURL()
        let data = try XCTUnwrap(
            try? Data(contentsOf: url),
            "could not read expected-defaults fixture at \(url.path) - "
                + "run scripts/defaults_generator/generate.py"
        )
        let enrolledModules = try DefaultsDriftComparator.loadEnrolledModules(data: data)
        XCTAssertTrue(
            enrolledModules.contains("id"),
            "'id' is missing from the snapshot's enrolledModules \(enrolledModules) - "
                + "see scripts/defaults_generator/enrollment.py. This test asserts Id "
                + "defaults; if Id is no longer enrolled, this test must be updated too."
        )

        // SDC-33331: runtime subtrees the SoT knowingly does not model (declared in the
        // SoT via a group-level runtimeOnlyPrefix, stamped into the snapshot by the
        // generator). Read from the snapshot, never hardcoded here - that is exactly what
        // distinguishes this from the outOfScope set SDC-32173 review F1 removed.
        let runtimeOnlyPrefixes = try DefaultsDriftComparator.loadRuntimeOnlyPrefixes(data: data)

        let expected = try DefaultsDriftComparator.loadExpected(data: data)

        let dump = IdCaptureWideDefaults.shared.toEncodable()
        let actual = DefaultsDriftComparator.flatten(
            dump: dump,
            modulePrefix: "Id",
            expectedPaths: Set(expected.keys)
        )

        let failures = DefaultsDriftComparator.compare(
            actual: actual,
            expected: expected,
            scopePrefixes: ["Id"],
            runtimeOnlyPrefixes: runtimeOnlyPrefixes
        )

        XCTAssertTrue(
            failures.isEmpty,
            "Id defaults drifted from the SoT:\n" + failures.joined(separator: "\n")
        )
    }
}
