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

    @GestureState private var pHMeterOffset = CGSize.zero

    var body: some View {
        PHMeter(
            content: isIntersectingWater ? labelWhenIntersectingWater : "",
            fontSize: layout.phMeterFontSize
        )
        .contentShape(Rectangle())
        .frame(size: layout.phMeterSize)
        .position(initialPosition)
        .offset(pHMeterOffset)
        .gesture(
            DragGesture()
                .updating($pHMeterOffset) { gesture, offset, _ in
                    offset = gesture.translation
                }
        )
        .animation(.easeOut(duration: 0.25))
        .zIndex(1)
    }

    private var isIntersectingWater: Bool {
        let waterHeight = layout.waterHeight(rows: rows)
        let centerWaterY = layout.height - (waterHeight / 2)

        let pHCenterX = initialPosition.x + pHMeterOffset.width
        let phCenterY = initialPosition.y + pHMeterOffset.height
        let waterCenterX = layout.sliderSettings.handleWidth + (layout.beakerWidth / 2)

        return PHMeter.tipOverlapsArea(
            meterSize: layout.phMeterSize,
            areaSize: CGSize(
                width: layout.beakerSettings.innerBeakerWidth,
                height: waterHeight
            ),
            meterCenterFromAreaCenter: CGSize(
                width: pHCenterX - waterCenterX,
                height: phCenterY - centerWaterY
            )
        )
    }
}
