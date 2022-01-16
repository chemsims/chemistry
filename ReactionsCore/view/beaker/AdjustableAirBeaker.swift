//
// Reactions App
//


import SwiftUI

public struct AdjustableAirBeaker: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let minRows: Int
    let maxRows: Int
    let dynamicMinRows: Int?
    @Binding var rows: CGFloat
    let disabled: Bool

    let generalColorMultiply: Color
    let sliderColorMultiply: Color
    let highlightSlider: Bool

    let settings: AdjustableAirBeakerSettings

    public init(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        minRows: Int,
        maxRows: Int,
        dynamicMinRows: Int?,
        rows: Binding<CGFloat>,
        disabled: Bool,
        generalColorMultiply: Color,
        sliderColorMultiply: Color,
        highlightSlider: Bool,
        settings: AdjustableAirBeakerSettings
    ) {
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.minRows = minRows
        self.maxRows = maxRows
        self.dynamicMinRows = dynamicMinRows.map { max(minRows, $0) }
        self._rows = rows
        self.disabled = disabled
        self.generalColorMultiply = generalColorMultiply
        self.sliderColorMultiply = sliderColorMultiply
        self.highlightSlider = highlightSlider
        self.settings = settings
    }

    public var body: some View {
        GeometryReader { geo in
            AdjustableAirBeakerWithHeight(
                molecules: molecules,
                animatingMolecules: animatingMolecules,
                currentTime: currentTime,
                minRows: CGFloat(minRows),
                maxRows: CGFloat(maxRows),
                dynamicMinRows: dynamicMinRows.map(CGFloat.init),
                rows: $rows,
                disabled: disabled,
                generalColorMultiply: generalColorMultiply,
                sliderColorMultiply: sliderColorMultiply,
                highlightSlider: highlightSlider,
                width: geo.size.width,
                height: geo.size.height,
                settings: settings
            )
        }
    }
}


private struct AdjustableAirBeakerWithHeight: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let minRows: CGFloat
    let maxRows: CGFloat
    let dynamicMinRows: CGFloat?
    @Binding var rows: CGFloat
    let disabled: Bool

    let generalColorMultiply: Color
    let sliderColorMultiply: Color
    let highlightSlider: Bool

    let width: CGFloat
    let height: CGFloat

    let settings: AdjustableAirBeakerSettings

    var body: some View {
        ZStack(alignment: .trailing) {
            Spacer()
                .frame(width: width)

            slider
                .background(
                    Color
                        .white
                        .padding(-0.2 * settings.sliderWidth)
                        .opacity(highlightSlider ? 1 : 0)
                )
                .frame(
                    width: settings.sliderWidth,
                    height: sliderHeight
                )
                .position(x: settings.sliderWidth / 2, y: sliderYPos)
                .colorMultiply(sliderColorMultiply)
                .accessibility(label: Text(sliderLabel))


            beaker
                .frame(width: settings.beakerWidth)
                .colorMultiply(generalColorMultiply)
        }
        .frame(width: width)
    }

    // The rows for max/min of the slider axis (not the selectable range)
    private var maxSliderRowsPos: CGFloat { maxRows + 1 }

    private var minSliderRowsPos: CGFloat { minRows - 1 }

    private var slider: some View {
        CustomSlider(
            value: $rows,
            axis: sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: SliderGeometrySettings(handleWidth: settings.sliderWidth),
            disabled: disabled,
            useHaptics: true
        )
    }

    private var beaker: some View {
        FilledAirBeaker(
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            currentTime: currentTime,
            rows: rows
        )
    }

    private var sliderAxis: LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: relativeSliderPosition(for: minRows),
            maxValuePosition: relativeSliderPosition(for: maxRows),
            minValue: minRows,
            maxValue: maxRows
        ).updateMin(value: dynamicMinRows ?? minRows)
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

    private var sliderLabel: String {
        "Slider to set rows of molecules below beaker piston"
    }

    private var sliderValue: String {
        "\(rows.str(decimals: 1))"
    }
}

public struct AdjustableAirBeakerSettings {
    let beakerWidth: CGFloat
    let sliderWidth: CGFloat

    public init(
        beakerWidth: CGFloat,
        sliderWidth: CGFloat
    ) {
        self.beakerWidth = beakerWidth
        self.sliderWidth = sliderWidth
    }
}

struct AdjustableAirBeaker_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State var rows: CGFloat = 10

        var body: some View {
            AdjustableAirBeaker(
                molecules: [],
                animatingMolecules: [],
                currentTime: 0,
                minRows: 5,
                maxRows: 15,
                dynamicMinRows: 6,
                rows: $rows,
                disabled: true,
                generalColorMultiply: .red,
                sliderColorMultiply: .blue,
                highlightSlider: false,
                settings: AdjustableAirBeakerSettings(
                    beakerWidth: 200,
                    sliderWidth: 20
                )
            )
            .frame(width: 250, height: 245)
        }
    }
}
