//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousScreenLayoutSettings {

    init(geometry: GeometryProxy) {
        self.width = geometry.size.width
        self.height = geometry.size.height
    }

    let width: CGFloat
    let height: CGFloat

    var beakerSettings: BeakerSettings {
        BeakerSettings(width: beakerWidth, hasLip: true)
    }

    var beakerWidth: CGFloat {
        0.22 * width
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var sliderHeight: CGFloat {
        0.8 * beakerHeight
    }

    var sliderSettings: SliderGeometrySettings {
        SliderGeometrySettings(handleWidth: 0.13 * beakerWidth)
    }

    // Chart settings for concentration chart
    var chartSettings: ReactionEquilibriumChartsLayoutSettings {
        ReactionEquilibriumChartsLayoutSettings(
            size: chartSize,
            maxYAxisValue: AqueousReactionSettings.ConcentrationInput.maxAxis
        )
    }

    func quotientChartSettings(
        convergenceQ: CGFloat,
        maxQ: CGFloat
    ) -> ReactionEquilibriumChartsLayoutSettings {
        let safeConvergence = convergenceQ == 0 ? 1 : convergenceQ
        let convergenceWithPadding = safeConvergence / 0.8
        let maxValue = max(maxQ, convergenceWithPadding)
        return ReactionEquilibriumChartsLayoutSettings(
            size: chartSize,
            maxYAxisValue: maxValue
        )
    }

    var chartSize: CGFloat {
        let maxSizeForHeight = 0.42 * height
        let maxSizeForWidth = 0.25 * width
        return min(maxSizeForWidth, maxSizeForHeight)
    }

    var chartSelectionHeight: CGFloat {
        0.048 * height
    }

    var chartSelectionFontSize: CGFloat {
        0.6 * chartSelectionHeight
    }

    var chartSelectionBottomPadding: CGFloat {
        0.1 * chartSelectionHeight
    }
}

extension AqueousScreenLayoutSettings {
    var moleculeContainerWidth: CGFloat {
        0.12 * beakerWidth
    }

    var moleculeContainerHeight: CGFloat {
        2.3 * moleculeContainerWidth
    }

    var moleculeContainerYPos: CGFloat {
        0.75 * moleculeContainerHeight
    }

    var moleculeSize: CGFloat {
        beakerSettings.innerBeakerWidth / CGFloat(MoleculeGridSettings.cols)
    }
}

// Right stack
extension AqueousScreenLayoutSettings {

    var rightStackWidth: CGFloat {
        0.8 * (width - beakerWidth - chartSize)
    }

    var scalesWidth: CGFloat {
        let maxWidthForGeometry = 0.23 * width
        let maxWidthForImage = MoleculeScalesGeometry.widthToHeight * scalesHeight
        return min(maxWidthForImage, maxWidthForGeometry)
    }

    var scalesHeight: CGFloat {
        0.29 * topRightStackHeight
    }

    var gridWidth: CGFloat {
        0.28 * width
    }

    var gridHeight: CGFloat {
        0.29 * topRightStackHeight
    }

    var equationHeight: CGFloat {
        0.3 * topRightStackHeight
    }

    var equationWidth: CGFloat {
        0.3 * width
    }

    var gridSelectionFontSize: CGFloat {
        0.6 * chartSelectionFontSize
    }

    var reactionToggleHeight: CGFloat {
        0.09 * topRightStackHeight
    }

    var topRightStackHeight: CGFloat {
        height - beakyTotalHeight
    }

    var beakyTotalHeight: CGFloat {
        beakySettings.bubbleHeight + beakySettings.beakyVSpacing + beakySettings.navButtonSize
    }

    var beakySettings: BeakyGeometrySettings {
        let bubbleWidth = 0.27 * width
        return BeakyGeometrySettings(
            beakyVSpacing: 2,
            bubbleWidth: bubbleWidth,
            bubbleHeight: 0.34 * height,
            beakyHeight: 0.1 * width,
            bubbleFontSize: 0.018 * width,
            navButtonSize: 0.076 * height,
            bubbleStemWidth: SpeechBubbleSettings.getStemWidth(bubbleWidth: bubbleWidth)
        )
    }
}

extension AqueousScreenLayoutSettings {
    var sliderAxis: AxisPositionCalculations<CGFloat> {
        let innerBeakerWidth = BeakerSettings(width: beakerWidth, hasLip: true).innerBeakerWidth
        let grid = MoleculeGridSettings(totalWidth: innerBeakerWidth)

        func posForRows(_ rows: CGFloat) -> CGFloat {
            sliderHeight - grid.height(for: CGFloat(rows))
        }

        let minRow = CGFloat(AqueousReactionSettings.minRows)
        let maxRow = CGFloat(AqueousReactionSettings.maxRows)

        return AxisPositionCalculations(
            minValuePosition: posForRows(minRow),
            maxValuePosition: posForRows(maxRow),
            minValue: minRow,
            maxValue: maxRow
        )
    }
}
