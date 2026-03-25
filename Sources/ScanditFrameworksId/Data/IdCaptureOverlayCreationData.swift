/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2025- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditIdCapture

public struct IdCaptureOverlayCreationData {
    let isValid: Bool
    let overlayJson: String
    let modeId: Int
    let showTextHints: Bool
    let frontSideTextHint: String?
    let backSideTextHint: String?
    let textHintPosition: TextHintPosition?

    private init(
        isValid: Bool,
        overlayJson: String,
        modeId: Int,
        showTextHints: Bool,
        frontSideTextHint: String? = nil,
        backSideTextHint: String? = nil,
        textHintPosition: TextHintPosition? = nil
    ) {
        self.isValid = isValid
        self.overlayJson = overlayJson
        self.modeId = modeId
        self.showTextHints = showTextHints
        self.frontSideTextHint = frontSideTextHint
        self.backSideTextHint = backSideTextHint
        self.textHintPosition = textHintPosition
    }

    static func fromJson(_ overlayJson: String) -> IdCaptureOverlayCreationData {
        let json = JSONValue(string: overlayJson)
        let type = json.string(forKey: "type", default: "")
        let modeId = json.integer(forKey: "modeId", default: -1)

        let isValid = type == "idCapture"
        if !isValid {
            return IdCaptureOverlayCreationData(
                isValid: false,
                overlayJson: "",
                modeId: modeId,
                showTextHints: false
            )
        }

        let showTextHints = json.bool(forKey: "showTextHints", default: true)
        var frontSideTextHint: String? = nil
        if json.containsKey("frontSideTextHint") {
            frontSideTextHint = json.string(forKey: "frontSideTextHint", default: "")
        }

        var backSideTextHint: String? = nil
        if json.containsKey("backSideTextHint") {
            backSideTextHint = json.string(forKey: "backSideTextHint", default: "")
        }

        var textHintPosition: TextHintPosition? = nil
        if json.containsKey("textHintPosition") {
            var parsingTextPosition = TextHintPosition.aboveViewfinder
            SDCTextHintPositionFromJSONString(
                json.string(forKey: "textHintPosition", default: ""),
                &parsingTextPosition
            )
            textHintPosition = parsingTextPosition
        }

        return IdCaptureOverlayCreationData(
            isValid: true,
            overlayJson: overlayJson,
            modeId: modeId,
            showTextHints: showTextHints,
            frontSideTextHint: frontSideTextHint,
            backSideTextHint: backSideTextHint,
            textHintPosition: textHintPosition
        )
    }
}
