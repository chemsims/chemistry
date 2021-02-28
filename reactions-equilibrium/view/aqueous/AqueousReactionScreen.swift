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

    @State private var showGraph = true

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                molecules
                Spacer()
                beaker
            }

            Spacer()
            middleStack
            Spacer()

            rightStack
        }
        .padding(.bottom, settings.bottomPadding)
        .padding(.top, settings.topPadding)
    }

    private var rightStack: some View {
        VStack(spacing: 2) {
//            AqueousEquationView(
//                equations: model.equations,
//                quotient: model.quotientEquation,
//                currentTime: model.currentTime,
//                maxWidth: settings.width / 4,
//                maxHeight: settings.height / 4
//            )

            MoleculeScales(
                equations: model.equations,
                currentTime: model.currentTime
            )
            .frame(width: 0.2 * settings.width, height: 0.2 * settings.height)

            EquilibriumGrid(
                currentTime: model.currentTime,
                reactants: [
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.gridMoleculesA,
                            color: .from(.aqMoleculeA)
                        ),
                        fractionToDraw: model.gridMoleculesAToDraw
                    ),
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.gridMoleculesB,
                            color: .from(.aqMoleculeB)
                        ),
                        fractionToDraw: model.gridMoleculesBToDraw
                    )
                ],
                products: [
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.gridMoleculesC,
                            color: .from(.aqMoleculeC)
                        ),
                        fractionToDraw: model.productMolecules.cFractionToDraw
                    ),
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.gridMoleculesD,
                            color: .from(.aqMoleculeD)
                        ),
                        fractionToDraw: model.productMolecules.dFractionToDraw
                    )
                ]
            )
            .frame(width: 0.25 * settings.width, height: 0.2 * settings.height)

            BeakyBox(
                statement: [],
                next: model.next,
                back: model.back,
                nextIsDisabled: false,
                settings: settings.beakySettings
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
                        coords: model.moleculesA,
                        color: .from(.aqMoleculeA)
                    ),
                    BeakerMolecules(
                        coords: model.moleculesB,
                        color: .from(.aqMoleculeB)
                    )
                ],
                animatingMolecules: [
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.productMolecules.cMolecules,
                            color: .from(.aqMoleculeC)
                        ),
                        fractionToDraw: model.productMolecules.cFractionToDraw
                    ),
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.productMolecules.dMolecules,
                            color: .from(.aqMoleculeD)
                        ),
                        fractionToDraw: model.productMolecules.dFractionToDraw
                    )
                ],
                currentTime: model.currentTime,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
        }
    }

    private var middleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                Button(action: { showGraph = true }) {
                    Text("Graph")
                }
                Button(action: { showGraph = false }) {
                    Text("Table")
                }
            }

            chartOrTable
            quotientChart
        }
    }

    // Must use opacity to hide chart rather than remove from view, otherwise the animation doesn't resume
    private var chartOrTable: some View {
        ZStack {
            concentrationChart.opacity(showGraph ? 1 : 0)
            if (!showGraph) {
                ICETable(equations: model.equations)
            }
        }.frame(
            width: settings.chartSettings.totalChartWidth,
            height: settings.chartSettings.totalChartHeight
        )
    }

    private var concentrationChart: some View {
        MultiConcentrationPlot(
            equations: model.equations,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.totalReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            settings: settings.chartSettings
        )
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: model.quotientEquation,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.totalReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            settings: settings.chartSettings
        )
    }
}

struct AqueousScreenLayoutSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    var beakerWidth: CGFloat {
        0.22 * width
    }

    var bottomPadding: CGFloat {
        0.02 * geometry.size.height
    }

    var topPadding: CGFloat {
        bottomPadding
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
        0.12 * beakerWidth
    }

    var moleculeSpacing: CGFloat {
        0.1 * beakerWidth
    }
}

extension AqueousScreenLayoutSettings {
    var beakySettings: BeakyGeometrySettings {
        let bubbleWidth = 0.3 * width
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

    var axisShapeSettings: ChartAxisShapeSettings {
        ChartAxisShapeSettings(chartSize: size)
    }

    var axisLabelFontSize: CGFloat {
        0.06 * size
    }
}

extension ReactionEquilibriumChartsLayoutSettings {
    var totalChartWidth: CGFloat {
        size + (2 * (yAxisWidthLabelWidth + axisLabelGapFromAxis))
    }

    var totalChartHeight: CGFloat {
        size + axisLabelGapFromAxis + xAxisLabelHeight
    }
}

extension ReactionEquilibriumChartsLayoutSettings {
    var legendCircleSize: CGFloat {
        0.09 * size
    }

    var legendSpacing: CGFloat {
        0.8 * legendCircleSize
    }

    var legendFontSize: CGFloat {
        0.6 * legendCircleSize
    }

    var legendPadding: CGFloat {
        0.35 * legendCircleSize
    }
}

extension ReactionEquilibriumChartsLayoutSettings {
    var yAxisWidthLabelWidth: CGFloat {
        0.1 * size
    }

    var axisLabelGapFromAxis: CGFloat {
        headRadius
    }

    var xAxisLabelHeight: CGFloat {
        0.1 * size
    }
}

struct AqueousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhoneSELandscape)

        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
