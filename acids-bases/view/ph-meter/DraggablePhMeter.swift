//
// Reactions App
//

import SwiftUI
import ReactionsCore

/// A draggable pH meter.
///
/// This view assumes a beaker with adjustable water height, using the default acid app layout.
struct DraggablePhMeter: View {

    let pHEquation: Equation

    let pHEquationInput: CGFloat

    let shouldShowLabelWhenInWater: Bool

    /// Acid app layout settings
    let layout: AcidBasesScreenLayout

    /// Initial position of the pH meter (position of the center)
    let initialPosition: CGPoint

    /// Number of rows in the beaker
    let rows: CGFloat

    let beakerDistanceFromBottomOfScreen: CGFloat

    @GestureState private var pHMeterOffset = CGSize.zero
    @State private var isFixedToBeaker = false

    var body: some View {
        PHMeter(
            equation: pHEquation,
            equationInput: pHEquationInput,
            formatter: { pH in
                if isIntersectingWater && shouldShowLabelWhenInWater {
                    return TextLine("pH: \(pH.str(decimals: 1))")
                }
                return ""
            },
            fontSize: layout.phMeterFontSize
        )
        .contentShape(Rectangle())
        .frame(size: layout.phMeterSize)
        .position(currentPosition)
        .offset(pHMeterOffset)
        .gesture(
            DragGesture()
                .onEnded { _ in
                    isFixedToBeaker = isIntersectingWater
                }
                .updating($pHMeterOffset) { gesture, offset, _ in
                    let x = min(gesture.translation.width, maxXOffset)
                    offset = .init(width: x, height: gesture.translation.height)
                }
        )
        .animation(.easeOut(duration: 0.25), value: pHMeterOffset)
        .zIndex(1)
        .accessibility(label: Text("pH meter showing pH of beaker"))
        .accessibility(value: Text(accessibilityValue))
        .accessibility(addTraits: .updatesFrequently)
    }

    private var accessibilityValue: String {
        if shouldShowLabelWhenInWater {
            return "\(pHEquation.getY(at: pHEquationInput).str(decimals: 1))"
        }
        return "no value"
    }

    private var maxXOffset: CGFloat {
        let maxX = waterCenterX + (waterWidth / 2) + (layout.phMeterSize.width / 2)
        return maxX - currentPosition.x
    }


    private var currentPosition: CGPoint {
        isFixedToBeaker ? fixedPosition : initialPosition
    }

    // Aligns center of ph meter with the top of the water,
    // and the left edge of the meter with the left edge of the
    // beaker plus a little padding
    private var fixedPosition: CGPoint {
        let topOfWater = waterCenterY - (waterHeight / 2)
        let waterLeftEdge = waterCenterX - (waterWidth / 2)

        // Make sure tip is inside the beaker
        let bottomOfWater = waterCenterY + (waterHeight / 2)
        let maxY = bottomOfWater - (0.5 * layout.phMeterSize.height)

        let phCenterY = min(topOfWater, maxY)

        // Move ph so it's aligned to right edge plus a little padding (hence 0.6 not 0.5)
        let phCenterX = waterLeftEdge + (0.6 * layout.phMeterSize.width)

        return CGPoint(x: phCenterX, y: phCenterY)
    }

    private var isIntersectingWater: Bool {
        let pHCenterX = currentPosition.x + pHMeterOffset.width
        let phCenterY = currentPosition.y + pHMeterOffset.height

        return PHMeter.tipOverlapsArea(
            meterSize: layout.phMeterSize,
            areaSize: CGSize(
                width: waterWidth,
                height: waterHeight
            ),
            meterCenterFromAreaCenter: CGSize(
                width: pHCenterX - waterCenterX,
                height: phCenterY - waterCenterY
            )
        )
    }

    private var waterHeight: CGFloat {
        layout.waterHeight(rows: rows)
    }

    private var waterCenterY: CGFloat {
        layout.height - (waterHeight / 2) - beakerDistanceFromBottomOfScreen
    }

    private var waterCenterX: CGFloat {
        layout.sliderSettings.handleWidth + (layout.beakerWidth / 2)
    }

    private var waterWidth: CGFloat {
        layout.beakerSettings.innerBeakerWidth
    }
}
