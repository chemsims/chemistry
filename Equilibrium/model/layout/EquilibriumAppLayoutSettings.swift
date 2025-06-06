//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EquilibriumAppLayoutSettings {

    init(
        geometry: GeometryProxy,
        verticalSizeClass: UserInterfaceSizeClass?,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) {
        self.width = geometry.size.width
        self.height = geometry.size.height
        self.verticalSizeClass = verticalSizeClass
        self.horizontalSizeClass = verticalSizeClass
    }

    let width: CGFloat
    let height: CGFloat
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var beakerSettings: BeakerSettings {
        BeakerSettings(width: beakerWidth, hasLip: true)
    }

    var beakerWidth: CGFloat {
        0.22 * width
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var beakerBottomPadding: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return chartSettings.xAxisLabelHeight
        }
        return 0
    }

    var beakerLeftPadding: CGFloat {
        if horizontalSizeClass.contains(.regular) {
            return 12
        }
        return 0
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

    var reactionDefinitionHeight: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return 0.1 * height
        }
        return 0.15 * height
    }

    var reactionDefinitionWidth: CGFloat {
        beakerSettings.innerBeakerWidth
    }
}

extension EquilibriumAppLayoutSettings {
    var moleculeContainerWidth: CGFloat {
        0.12 * beakerWidth
    }

    var moleculeContainerHeight: CGFloat {
        2.3 * moleculeContainerWidth
    }

    var moleculeContainerYPos: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return chartSize
        }
        return (0.75 * moleculeContainerHeight) + reactionDefinitionHeight
    }

    var moleculeSize: CGFloat {
        beakerSettings.innerBeakerWidth / CGFloat(MoleculeGridSettings.cols)
    }

    var shakeTextFontSize: CGFloat {
        0.08 * reactionDefinitionWidth
    }
}

// Right stack
extension EquilibriumAppLayoutSettings {

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
        0.32 * topRightStackHeight
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

extension EquilibriumAppLayoutSettings {
    var sliderAxis: LinearAxis<CGFloat> {
        BeakerLiquidSliderAxis.axis(
            minRows: AqueousReactionSettings.minRows,
            maxRows: AqueousReactionSettings.maxRows,
            beakerWidth: beakerWidth,
            sliderHeight: sliderHeight
        )
    }
}

extension EquilibriumAppLayoutSettings {
    var branchMenu: BranchMenu.Layout {
        BranchMenu.Layout(height: menuSize)
    }

    var branchMenuHSpacing: CGFloat {
        0.2 * menuSize
    }
}
