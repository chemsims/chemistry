//
// Reactions App
//

import SwiftUI

public struct AdjustableFluidBeaker<BeakerModifier: ViewModifier>: View {

    public init(
        rows: Binding<CGFloat>,
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        settings: AdjustableFluidBeakerSettings,
        canSetLevel: Bool,
        beakerColorMultiply: Color,
        sliderColorMultiply: Color,
        beakerModifier: BeakerModifier
    ) {
        self._rows = rows
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.settings = settings
        self.canSetLevel = canSetLevel
        self.beakerColorMultiply = beakerColorMultiply
        self.sliderColorMultiply = sliderColorMultiply
        self.beakerModifier = beakerModifier
    }

    @Binding var rows: CGFloat
    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let settings: AdjustableFluidBeakerSettings
    let canSetLevel: Bool
    let beakerColorMultiply: Color
    let sliderColorMultiply: Color
    let beakerModifier: BeakerModifier

    public var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            slider
            beaker
                .modifier(beakerModifier)
        }
    }

    private var slider: some View {
        CustomSlider(
            value: $rows,
            axis: settings.sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: settings.sliderSettings,
            disabled: !canSetLevel,
            useHaptics: true
        )
        .frame(
            width: settings.sliderSettings.handleWidth,
            height: settings.sliderHeight
        )
        .background(
            Color.white
                .padding(.horizontal, settings.sliderPadding)
                .padding(.top, settings.sliderPadding)
        )
        .colorMultiply(sliderColorMultiply)
        .accessibility(
            label: Text("Slider for number of rows of molecules in beaker")
        )
    }

    private var beaker: some View {
        FilledBeaker(
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            currentTime: currentTime,
            rows: rows
        )
        .frame(
            width: settings.beakerWidth,
            height: settings.beakerHeight
        )
        .colorMultiply(beakerColorMultiply)
    }
}

public struct AdjustableFluidBeakerSettings {
    public init(
        minRows: Int,
        maxRows: Int,
        beakerWidth: CGFloat,
        beakerHeight: CGFloat,
        sliderSettings: SliderGeometrySettings,
        sliderHeight: CGFloat
    ) {
        self.minRows = minRows
        self.maxRows = maxRows
        self.beakerWidth = beakerWidth
        self.beakerHeight = beakerHeight
        self.sliderSettings = sliderSettings
        self.sliderHeight = sliderHeight
    }

    let minRows: Int
    let maxRows: Int

    let beakerWidth: CGFloat
    let beakerHeight: CGFloat

    let sliderSettings: SliderGeometrySettings
    let sliderHeight: CGFloat

    var sliderPadding: CGFloat {
        -0.2 * sliderSettings.handleWidth
    }

    var sliderAxis: AxisPositionCalculations<CGFloat> {
        BeakerLiquidSliderAxis.axis(
            minRows: minRows,
            maxRows: maxRows,
            beakerWidth: beakerWidth,
            sliderHeight: sliderHeight
        )
    }
}

public struct BeakerLiquidSliderAxis {
    private init() { }

    /// Returns an axis for a slider where the slider handle is at the same position
    /// as the water level.
    ///
    /// - Note: This assumes the slider is aligned with the bottom of the beaker.
    ///         If this is not the case, the axis should be offset as needed.
    public static func axis(
        minRows: Int,
        maxRows: Int,
        beakerWidth: CGFloat,
        sliderHeight: CGFloat
    ) -> AxisPositionCalculations<CGFloat> {
        let innerBeakerWidth = BeakerSettings(
            width: beakerWidth,
            hasLip: true
        ).innerBeakerWidth

        let grid = MoleculeGridSettings(totalWidth: innerBeakerWidth)

        func posForRows(_ rows: Int) -> CGFloat {
            sliderHeight - grid.height(for: CGFloat(rows))
        }

        return AxisPositionCalculations(
            minValuePosition: posForRows(minRows),
            maxValuePosition: posForRows(maxRows),
            minValue: CGFloat(minRows),
            maxValue: CGFloat(maxRows)
        )
    }
}
