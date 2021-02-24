//
// Reactions App
//


import SwiftUI
import ReactionsCore

struct AqueousReactionScreen: View {

    let model: AqueousReactionViewModel

    var body: some View {
        GeometryReader { geometry in
            AqueousReactionScreenWithSettings(
                model: model,
                settings: AqueousScreenLayoutSettings(geometry: geometry)
            )
        }
    }
}

private struct AqueousReactionScreenWithSettings: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                molecules
                Spacer()
                beaker
            }

            Spacer()
            charts
            Spacer()

            BeakyBox(
                statement: [],
                next: model.next,
                back: model.back,
                nextIsDisabled: false,
                verticalSpacing: 1,
                bubbleWidth: 100,
                bubbleHeight: 100,
                beakyHeight: 100,
                fontSize: 20,
                navButtonSize: 20,
                bubbleStemWidth: 10
            )
        }
    }

    private var molecules: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.sliderSettings.handleWidth)
            HStack(spacing: settings.moleculeSpacing) {
                ForEach(AqueousMolecule.allCases, id: \.rawValue) { molecule in
                    Image(molecule.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: settings.moleculeWidth)
                        .onTapGesture {
                            guard model.canAddReactants else {
                                return
                            }
                            if molecule == .A {
                                model.incrementAMolecules()
                            } else {
                                model.incrementBMolecules()
                            }
                        }

                }
            }
        }
    }

    private var beaker: some View {
        HStack(alignment: .bottom, spacing: 0) {
            CustomSlider(
                value: $model.rows,
                axis: settings.sliderAxis,
                orientation: .portrait,
                includeFill: true,
                settings: settings.sliderSettings,
                disabled: !model.canSetLiquidLevel
            )
            .frame(width: settings.sliderSettings.handleWidth, height: settings.sliderHeight)

            FilledBeaker(
                molecules: [
                    BeakerMolecules(
                        coords: model.moleculesA, color: .from(.moleculeA)
                    ),
                    BeakerMolecules(
                        coords: model.moleculesB, color: .from(.moleculeB)
                    )
                ],
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
        }
    }

    private var charts: some View {
        TimeChartMultiDataLineView(
            data: [
                data(equation: model.equations.reactantA, color: .from(.aqMoleculeA)),
                data(equation: model.equations.reactantB, color: .from(.aqMoleculeB)),
                data(equation: model.equations.productC, color: .from(.aqMoleculeC)),
                data(equation: model.equations.productD, color: .from(.aqMoleculeD)),
            ],
            settings: settings.chartSettings.layout,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.totalReactionTime,
            filledBarColor: .black,
            canSetCurrentTime: model.canSetCurrentTime
        )
        .frame(width: settings.chartSettings.size, height: settings.chartSettings.size)
        .border(Color.black)
    }

    private func data(equation: Equation, color: Color) -> TimeChartDataline {
        TimeChartDataline(
            equation: equation,
            headColor: color,
            haloColor: color.opacity(0.3),
            headRadius: settings.chartSettings.headRadius
        )
    }
}

struct AqueousScreenLayoutSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }

    var beakerWidth: CGFloat {
        0.25 * width
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

    var chartSettings: ReactionEquilibriumChartsLayoutSettings {
        ReactionEquilibriumChartsLayoutSettings(size: 0.2 * width)
    }
}

extension AqueousScreenLayoutSettings {
    var moleculeWidth: CGFloat {
        0.15 * beakerWidth
    }

    var moleculeSpacing: CGFloat {
        0.1 * beakerWidth
    }
}

extension AqueousScreenLayoutSettings {
    var sliderAxis: AxisPositionCalculations<CGFloat> {
        let innerBeakerWidth = BeakerSettings(width: beakerWidth).innerBeakerWidth
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

struct ReactionEquilibriumChartsLayoutSettings {
    let size: CGFloat

    var headRadius: CGFloat {
        0.018 * size
    }

    var layout: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0,
                maxValuePosition: size,
                minValue: 0,
                maxValue: AqueousReactionSettings.totalReactionTime
            ),
            yAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: size,
                maxValuePosition: 0.2 * size,
                minValue: 0,
                maxValue: 1
            ),
            haloRadius: 2 * headRadius,
            lineWidth: 0.3 * headRadius
        )
    }
}

struct AqueousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
