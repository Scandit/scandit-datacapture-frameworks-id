/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2026- Scandit AG. All rights reserved.
 */

// THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
// Generator: scripts/bridge_generator/generate.py
// Schema: scripts/bridge_generator/schemas/id.json
//
// Codable structs/enums derived from the serialization JSON schemas
// referenced by this module's bridge params -- the Swift twin of
// `SchemaTypes.kt` (SDC-32644) / `schemaTypes.ts` / `schema_types.dart`. No
// runtime dependency beyond Foundation: validation rides Codable's own
// throwing contract, hand-extended below for the keywords Codable doesn't
// natively enforce.
//
// init(from:) enforces the same JSON Schema keywords the Kotlin/Dart
// emitters do: required, type, enum, string const, additionalProperties,
// null-ness, and root-level oneOf (dispatched on the discriminator). NOT
// enforced -- a payload violating one of these still decodes: pattern,
// minimum/maximum, minLength/maxLength, multipleOf.
//
// Like the Kotlin emitter's `SchemaAssertions.requireValid` (SDC-33621:
// throws unconditionally in every build variant), every check below
// throws unconditionally in every build configuration: there is no
// `#if DEBUG` idiom in frameworks/shared/ios today, and Codable's
// `Decodable.init(from:)` throws by contract regardless of build config
// -- gating strictness behind DEBUG would fight the protocol it
// implements. Required-field absence, a null on a non-optional
// property, and a type mismatch are all
// surfaced automatically by `KeyedDecodingContainer.decode(_:forKey:)`
// (native `DecodingError.keyNotFound` / `.valueNotFound` /
// `.typeMismatch`) -- EXCEPT for a property that is both `required` and
// `nullable`, which must accept an explicit null while still rejecting a
// missing key; `decode(_:forKey:)` can't express that (it rejects null
// too) and plain `decodeIfPresent` can't express it either (it treats a
// missing key and an explicit null identically, both -> nil), so that case
// gets a hand-rolled `container.contains(forKey:)` guard below that throws
// `DecodingError.keyNotFound` before falling through to `decodeIfPresent`.
// unknown-enum-value and unknown-key (`additionalProperties: false`)
// checks are likewise hand-rolled below and throw
// `DecodingError.dataCorrupted` with a message naming the offending
// key/value.
//
// Full required/nullable matrix, kept coherent across every property kind
// (plain scalar, enum, array, ref, union) and both directions:
//
//   not required (nullable or not):
//     decode: missing key -> nil; explicit `null` -> nil.
//     encode: `nil` -> key omitted (`encodeIfPresent` / `if let`).
//   required, non-nullable:
//     decode: missing key -> throws `keyNotFound`; explicit `null` -> throws
//       `valueNotFound` (from `decode(_:forKey:)`, or from the union
//       parser's own decode when it hits null).
//     encode: always encodes the key (non-optional Swift property).
//   required, nullable:
//     decode: missing key -> throws `keyNotFound` (hand-rolled
//       `required_key_guard` below, since `decodeIfPresent`/`decodeNil`
//       alone can't distinguish missing-key from explicit-null); explicit
//       `null` -> nil.
//     encode: `nil` -> key present with an explicit `null`
//       (`encodeNil(forKey:)`), never omitted -- omitting it here would
//       make `init(from:)` throw `keyNotFound` on round-trip.
//
// A union-typed property follows the same matrix, but "decode" means
// dispatching through `<Union>Parser.parse(from:)` against a
// `superDecoder`; since that parser cannot itself observe null (it reads a
// discriminator key out of the nested container), every union branch below
// checks `decodeNil`/`contains` itself before ever calling into the parser.

import Foundation
// `UnknownPropertyError` is declared once, by hand, in core -- see its doc comment.
import ScanditFrameworksCore

// Reusable dynamic `CodingKey` for enumerating every key actually present
// in the payload -- needed only to implement `additionalProperties: false`
// (an unknown-key check), since a container keyed by a fixed `CodingKeys`
// enum never surfaces keys it doesn't already know about.
private struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

// Codable stand-in for a property (or array element) the generator cannot
// give a nominal type -- an inline anonymous object with no `$ref`/`$defs`,
// like `barcode_ar_filter_filter_barcodes.json`'s `barcodes` items.
//
// Kotlin, Dart and TypeScript can spell "untyped" directly (`Any?`,
// `Object?`, `unknown`), so they render such a property as-is. Swift cannot:
// `Any` is not `Codable`, so `container.decode([Any].self, ...)` has no
// matching overload and the file does not compile. This enum is the Swift
// spelling of the same idea -- it round-trips arbitrary JSON without
// asserting a shape, so element-level validation stays exactly as absent
// here as it is on the other three platforms.
// Internal rather than `private`: unlike `AnyCodingKey` (used only inside
// function bodies), this type appears in the stored-property types of the
// generated structs, and Swift rejects an internal property whose type is
// private.
enum AnyJSON: Codable {
    case string(String)
    case number(Double)
    case integer(Int)
    case bool(Bool)
    case array([AnyJSON])
    case object([String: AnyJSON])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            // Int before Double: `decode(Double.self)` also accepts an
            // integer literal, and matching Double first would turn every
            // whole number into `1.0` on re-encode.
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([AnyJSON].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: AnyJSON].self) {
            self = .object(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "AnyJSON: value is not representable as JSON"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }

    // Projection back to the plain Foundation JSON types that
    // `Event.emit(on:payload: [String: Any])` serializes.
    var jsonObject: Any {
        switch self {
        case .string(let value): return value
        case .number(let value): return value
        case .integer(let value): return value
        case .bool(let value): return value
        case .array(let value): return value.map(\.jsonObject)
        case .object(let value): return value.mapValues(\.jsonObject)
        case .null: return NSNull()
        }
    }
}

// Namespace container for every generated type below. A schema title is
// only unique within its own schema file (`serialization/schemas/**`); the
// Kotlin emitter gets collision safety for free from its
// `...command.generated` *package*, and the TS/Dart emitters keep their
// generated types out of the public barrel -- but a Swift target has no
// per-directory namespace and no barrel to exclude from, so an unqualified
// top-level type here can shadow an unrelated SDK type of the same name
// (e.g. a schema titled "SequenceFrameSource" collided with
// `SDCSequenceFrameSource`'s `NS_SWIFT_NAME(SequenceFrameSource)` from
// ScanditCaptureCore -- see SDC-32645). Wrapping every generated
// declaration in this uninhabited `enum` namespaces all of them under
// `SchemaTypes.<Name>`, so unqualified references elsewhere in the module
// keep resolving to the real SDK type.
enum SchemaTypes {

    /// Notifies the listener that IdCapture captured a document.
    struct IdCaptureListenerDidCaptureId: Codable {
        let id: String
        let imageInfo: ImageInfo?
        let frontReviewImage: String?
        let modeId: Int
        let event: String

        // Explicit memberwise init -- defining `init(from decoder:)` below suppresses Swift's
        // synthesized memberwise initializer, but emit sites need to build these payloads (not
        // just decode them), so both must coexist.
        init(
            id: String,
            imageInfo: ImageInfo? = nil,
            frontReviewImage: String? = nil,
            modeId: Int,
            event: String
        ) {
            self.id = id
            self.imageInfo = imageInfo
            self.frontReviewImage = frontReviewImage
            self.modeId = modeId
            self.event = event
        }

        // Built once per type rather than per decode -- see the per-property
        // `AllowedValues` sets below for the same rationale.
        private static let allowedKeys: Set<String> = [
            "id",
            "imageInfo",
            "frontReviewImage",
            "modeId",
            "event",
        ]
        private static let eventAllowedValues: Set<String> = ["IdCaptureListener.didCaptureId"]

        enum CodingKeys: String, CodingKey {
            case id
            case imageInfo
            case frontReviewImage
            case modeId
            case event
        }

        init(from decoder: Decoder) throws {
            let anyContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            for key in anyContainer.allKeys {
                guard Self.allowedKeys.contains(key.stringValue) else {
                    throw UnknownPropertyError(
                        message: "IdCaptureListenerDidCaptureId: unknown property '\(key.stringValue)'"
                    )
                }
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            imageInfo = try container.decodeIfPresent(ImageInfo.self, forKey: .imageInfo)
            frontReviewImage = try container.decodeIfPresent(String.self, forKey: .frontReviewImage)
            modeId = try container.decode(Int.self, forKey: .modeId)
            guard modeId >= Int(Int32.min), modeId <= Int(Int32.max) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "IdCaptureListenerDidCaptureId.modeId: out of Int32 range"
                    )
                )
            }
            let eventRaw = try container.decode(String.self, forKey: .event)
            guard Self.eventAllowedValues.contains(eventRaw) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "IdCaptureListenerDidCaptureId.event: unknown enum value '\(eventRaw)'"
                    )
                )
            }
            event = eventRaw
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(imageInfo, forKey: .imageInfo)
            try container.encodeIfPresent(frontReviewImage, forKey: .frontReviewImage)
            try container.encode(modeId, forKey: .modeId)
            try container.encode(event, forKey: .event)
        }

        // Dictionary projection for `Event.emit(on:payload: [String: Any])`
        // (frameworks/shared/ios/.../Event/Event.swift) -- a NULLABLE property keeps
        // its key, written as NSNull when nil: omitting it changed the emitted bytes
        // for payloads that previously rode through as raw JSON (SDC-33900), and a
        // strict parser accepts an explicit null but throws on a missing key
        // (SDC-33544). A non-nullable optional is omitted when nil, because the
        // decoder rejects an explicit null for it.
        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            dict["id"] = id
            if let imageInfo { dict["imageInfo"] = imageInfo.toDictionary() }
            dict["frontReviewImage"] = frontReviewImage ?? NSNull()
            dict["modeId"] = modeId
            dict["event"] = event
            return dict
        }
    }

    /// Base64-encoded images captured from an identity document, grouped by side.
    struct ImageInfo: Codable {
        let front: SideImages?
        let back: SideImages?

        // Explicit memberwise init -- defining `init(from decoder:)` below suppresses Swift's
        // synthesized memberwise initializer, but emit sites need to build these payloads (not
        // just decode them), so both must coexist.
        init(
            front: SideImages? = nil,
            back: SideImages? = nil
        ) {
            self.front = front
            self.back = back
        }

        // Built once per type rather than per decode -- see the per-property
        // `AllowedValues` sets below for the same rationale.
        private static let allowedKeys: Set<String> = [
            "front",
            "back",
        ]

        enum CodingKeys: String, CodingKey {
            case front
            case back
        }

        init(from decoder: Decoder) throws {
            let anyContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            for key in anyContainer.allKeys {
                guard Self.allowedKeys.contains(key.stringValue) else {
                    throw UnknownPropertyError(
                        message: "ImageInfo: unknown property '\(key.stringValue)'"
                    )
                }
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            front = try container.decodeIfPresent(SideImages.self, forKey: .front)
            back = try container.decodeIfPresent(SideImages.self, forKey: .back)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(front, forKey: .front)
            try container.encodeIfPresent(back, forKey: .back)
        }

        // Dictionary projection for `Event.emit(on:payload: [String: Any])`
        // (frameworks/shared/ios/.../Event/Event.swift) -- a NULLABLE property keeps
        // its key, written as NSNull when nil: omitting it changed the emitted bytes
        // for payloads that previously rode through as raw JSON (SDC-33900), and a
        // strict parser accepts an explicit null but throws on a missing key
        // (SDC-33544). A non-nullable optional is omitted when nil, because the
        // decoder rejects an explicit null for it.
        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            if let front { dict["front"] = front.toDictionary() }
            if let back { dict["back"] = back.toDictionary() }
            return dict
        }
    }

    struct SideImages: Codable {
        let face: String?
        let croppedDocument: String?
        let frame: String?

        // Explicit memberwise init -- defining `init(from decoder:)` below suppresses Swift's
        // synthesized memberwise initializer, but emit sites need to build these payloads (not
        // just decode them), so both must coexist.
        init(
            face: String? = nil,
            croppedDocument: String? = nil,
            frame: String? = nil
        ) {
            self.face = face
            self.croppedDocument = croppedDocument
            self.frame = frame
        }

        // Built once per type rather than per decode -- see the per-property
        // `AllowedValues` sets below for the same rationale.
        private static let allowedKeys: Set<String> = [
            "face",
            "croppedDocument",
            "frame",
        ]

        enum CodingKeys: String, CodingKey {
            case face
            case croppedDocument
            case frame
        }

        init(from decoder: Decoder) throws {
            let anyContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            for key in anyContainer.allKeys {
                guard Self.allowedKeys.contains(key.stringValue) else {
                    throw UnknownPropertyError(
                        message: "SideImages: unknown property '\(key.stringValue)'"
                    )
                }
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            face = try container.decodeIfPresent(String.self, forKey: .face)
            croppedDocument = try container.decodeIfPresent(String.self, forKey: .croppedDocument)
            frame = try container.decodeIfPresent(String.self, forKey: .frame)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(face, forKey: .face)
            try container.encodeIfPresent(croppedDocument, forKey: .croppedDocument)
            try container.encodeIfPresent(frame, forKey: .frame)
        }

        // Dictionary projection for `Event.emit(on:payload: [String: Any])`
        // (frameworks/shared/ios/.../Event/Event.swift) -- a NULLABLE property keeps
        // its key, written as NSNull when nil: omitting it changed the emitted bytes
        // for payloads that previously rode through as raw JSON (SDC-33900), and a
        // strict parser accepts an explicit null but throws on a missing key
        // (SDC-33544). A non-nullable optional is omitted when nil, because the
        // decoder rejects an explicit null for it.
        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            dict["face"] = face ?? NSNull()
            dict["croppedDocument"] = croppedDocument ?? NSNull()
            dict["frame"] = frame ?? NSNull()
            return dict
        }
    }

    /// Notifies the listener that IdCapture rejected a document.
    struct IdCaptureListenerDidRejectId: Codable {
        let rejectionReason: String
        let id: String?
        let imageInfo: ImageInfo?
        let frontReviewImage: String?
        let modeId: Int
        let event: String

        // Explicit memberwise init -- defining `init(from decoder:)` below suppresses Swift's
        // synthesized memberwise initializer, but emit sites need to build these payloads (not
        // just decode them), so both must coexist.
        init(
            rejectionReason: String,
            id: String? = nil,
            imageInfo: ImageInfo? = nil,
            frontReviewImage: String? = nil,
            modeId: Int,
            event: String
        ) {
            self.rejectionReason = rejectionReason
            self.id = id
            self.imageInfo = imageInfo
            self.frontReviewImage = frontReviewImage
            self.modeId = modeId
            self.event = event
        }

        // Built once per type rather than per decode -- see the per-property
        // `AllowedValues` sets below for the same rationale.
        private static let allowedKeys: Set<String> = [
            "rejectionReason",
            "id",
            "imageInfo",
            "frontReviewImage",
            "modeId",
            "event",
        ]
        private static let rejectionReasonAllowedValues: Set<String> = [
            "notAcceptedDocumentType", "invalidFormat", "documentVoided", "timeout", "singleImageNotRecognized",
            "documentExpired", "documentExpiresSoon", "notRealIdCompliant", "holderUnderage", "forgedAamvaBarcode",
            "inconsistentData", "bluetoothCommunicationError", "bluetoothUnavailable", "cloudRequestFailed",
            "manipulatedDocument",
        ]
        private static let eventAllowedValues: Set<String> = ["IdCaptureListener.didRejectId"]

        enum CodingKeys: String, CodingKey {
            case rejectionReason
            case id
            case imageInfo
            case frontReviewImage
            case modeId
            case event
        }

        init(from decoder: Decoder) throws {
            let anyContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            for key in anyContainer.allKeys {
                guard Self.allowedKeys.contains(key.stringValue) else {
                    throw UnknownPropertyError(
                        message: "IdCaptureListenerDidRejectId: unknown property '\(key.stringValue)'"
                    )
                }
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rejectionReasonRaw = try container.decode(String.self, forKey: .rejectionReason)
            guard Self.rejectionReasonAllowedValues.contains(rejectionReasonRaw) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription:
                            "IdCaptureListenerDidRejectId.rejectionReason: unknown enum value '\(rejectionReasonRaw)'"
                    )
                )
            }
            rejectionReason = rejectionReasonRaw
            id = try container.decodeIfPresent(String.self, forKey: .id)
            imageInfo = try container.decodeIfPresent(ImageInfo.self, forKey: .imageInfo)
            frontReviewImage = try container.decodeIfPresent(String.self, forKey: .frontReviewImage)
            modeId = try container.decode(Int.self, forKey: .modeId)
            guard modeId >= Int(Int32.min), modeId <= Int(Int32.max) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "IdCaptureListenerDidRejectId.modeId: out of Int32 range"
                    )
                )
            }
            let eventRaw = try container.decode(String.self, forKey: .event)
            guard Self.eventAllowedValues.contains(eventRaw) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "IdCaptureListenerDidRejectId.event: unknown enum value '\(eventRaw)'"
                    )
                )
            }
            event = eventRaw
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(rejectionReason, forKey: .rejectionReason)
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(imageInfo, forKey: .imageInfo)
            try container.encodeIfPresent(frontReviewImage, forKey: .frontReviewImage)
            try container.encode(modeId, forKey: .modeId)
            try container.encode(event, forKey: .event)
        }

        // Dictionary projection for `Event.emit(on:payload: [String: Any])`
        // (frameworks/shared/ios/.../Event/Event.swift) -- a NULLABLE property keeps
        // its key, written as NSNull when nil: omitting it changed the emitted bytes
        // for payloads that previously rode through as raw JSON (SDC-33900), and a
        // strict parser accepts an explicit null but throws on a missing key
        // (SDC-33544). A non-nullable optional is omitted when nil, because the
        // decoder rejects an explicit null for it.
        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            dict["rejectionReason"] = rejectionReason
            dict["id"] = id ?? NSNull()
            if let imageInfo { dict["imageInfo"] = imageInfo.toDictionary() }
            dict["frontReviewImage"] = frontReviewImage ?? NSNull()
            dict["modeId"] = modeId
            dict["event"] = event
            return dict
        }
    }
}
