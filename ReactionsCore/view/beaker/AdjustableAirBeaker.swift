//
// Reactions App
//


import SwiftUI

struct AdjustableAirBeaker: View {
    let minRows: Int
    let maxRows: Int
    @Binding var rows: CGFloat

    let settings: AdjustableAirBeakerSettings

    var body: some View {
        GeometryReader { geo in
            AdjustableAirBeakerWithHeight(
                minRows: CGFloat(minRows),
                maxRows: CGFloat(maxRows),
                rows: $rows,
                width: geo.size.width,
                height: geo.size.height,
                settings: settings
            )
        }
    }
}


private struct AdjustableAirBeakerWithHeight: View {

    let minRows: CGFloat
    let maxRows: CGFloat
    @Binding var rows: CGFloat

    let width: CGFloat
    let height: CGFloat

    let settings: AdjustableAirBeakerSettings

    var body: some View {
        ZStack(alignment: .trailing) {
            Spacer()
                .frame(width: width)

            slider
                .frame(
                    width: settings.sliderWidth,
                    height: sliderHeight
                )
                .position(x: settings.sliderWidth / 2, y: sliderYPos)

            beaker.frame(width: settings.beakerWidth)
        }
        .frame(width: width)
    }

    // The rows for max/min of the slider axis (not the selectable range)
    private var maxSliderRowsPos: CGFloat { maxRows + 2 }

    private var minSliderRowsPos: CGFloat { minRows - 2 }

    private var slider: some View {
        CustomSlider(
            value: $rows,
            axis: sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: SliderGeometrySettings(handleWidth: settings.sliderWidth),
            disabled: false,
            useHaptics: true
        )
    }

    private var beaker: some View {
        FilledAirBeaker(
            molecules: [],
            animatingMolecules: [],
            currentTime: 10,
            rows: rows
        )
    }

    private var sliderAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: relativeSliderPosition(for: minRows),
            maxValuePosition: relativeSliderPosition(for: maxRows),
            minValue: minRows,
            maxValue: maxRows
        )
    }

    private var sliderHeight: CGFloat {
        let minPos = absoluteSliderPosition(for: minSliderRowsPos)
        let maxPos = absoluteSliderPosition(for: maxSliderRowsPos)

        return minPos - maxPos
    }

    private var sliderYPos: CGFloat {
        let topPos = absoluteSliderPosition(for: maxSliderRowsPos)
        return topPos + (sliderHeight / 2)
    }

    private func relativeSliderPosition(for rows: CGFloat) -> CGFloat {
        let absolutePos = absoluteSliderPosition(for: rows)
        let minPos = absoluteSliderPosition(for: minSliderRowsPos)
        let maxPos = absoluteSliderPosition(for: maxSliderRowsPos)
        let factor = (absolutePos - maxPos) / (minPos - maxPos)
        return (minPos - maxPos) * factor
    }

    private func absoluteSliderPosition(for rows: CGFloat) -> CGFloat {
        let grid = MoleculeGridSettings(totalWidth: settings.beakerWidth)
        let sealSettings = FilledAirSealSettings(width: settings.beakerWidth)
        let liquidHeight = grid.height(for: rows)
        let midSealPosition = sealSettings.midSealPosition
        return height - liquidHeight - midSealPosition
    }
}

struct AdjustableAirBeakerSettings {
    let beakerWidth: CGFloat
    let sliderWidth: CGFloat
}

struct AdjustableAirBeaker_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State var rows: CGFloat = 10

        var body: some View {
            AdjustableAirBeaker(
                minRows: 5,
                maxRows: 15,
                rows: $rows,
                settings: AdjustableAirBeakerSettings(
                    beakerWidth: 200,
                    sliderWidth: 20
                )
            )
            .frame(width: 250, height: 245)
        }
    }
}
