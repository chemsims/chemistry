//
// Reactions App
//

import SwiftUI
import ReactionsCore

/// A draggable pH meter.
///
/// This view assumes a beaker with adjustable water height, using the default acid app layout.
struct DraggablePhMeter: View {

    /// The label to show when the pH meter is intersecting the water
    let labelWhenIntersectingWater: TextLine

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
            content: isIntersectingWater ? labelWhenIntersectingWater : "",
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
                    offset = gesture.translation
                }

        )
        .animation(.easeOut(duration: 0.25), value: pHMeterOffset)
        .animation(.easeOut(duration: 0.25), value: isFixedToBeaker)
        .zIndex(1)
//        .overlay(foo, alignment: .bottom)
    }

    private var foo: some View {
        Rectangle()
            .stroke()
            .frame(width: waterWidth, height: waterHeight)
            .position(CGPoint(x: waterCenterX, y: waterCenterY))
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
