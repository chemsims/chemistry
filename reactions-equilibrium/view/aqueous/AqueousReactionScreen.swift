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
            MiddleStackView(model: model, settings: settings)
            Spacer()
            RightStackView(model: model, settings: settings)
        }
        .padding(.bottom, settings.bottomPadding)
        .padding(.top, settings.topPadding)
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
                            if molecule == .A {
                                model.incrementAMolecules()
                            } else if molecule == .B {
                                model.incrementBMolecules()
                            } else if molecule == .C {
                                model.incrementCMolecules()
                            } else if molecule == .D {
                                model.incrementDMolecules()
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
                        coords: model.components.aMolecules,
                        color: .from(.aqMoleculeA)
                    ),
                    BeakerMolecules(
                        coords: model.components.bMolecules,
                        color: .from(.aqMoleculeB)
                    )
                ],
                animatingMolecules: [
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.components.cMolecules,
                            color: .from(.aqMoleculeC)
                        ),
                        fractionToDraw: model.components.cBeakerFractionToDraw
                    ),
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: model.components.dMolecules,
                            color: .from(.aqMoleculeD)
                        ),
                        fractionToDraw: model.components.dBeakerFractionToDraw
                    )
                ],
                currentTime: model.currentTime,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
        }
    }
}

private struct MiddleStackView: View {
    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    @State private var showGraph = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chartSelectionToggle
            chartOrTable
            Spacer()
            quotientChart
        }
    }

    // Must use opacity to hide chart rather than remove from view, otherwise the animation doesn't resume
    private var chartOrTable: some View {
        ZStack(alignment: .leading) {
            concentrationChart.opacity(showGraph ? 1 : 0)
            if (!showGraph) {
                ICETable(equations: model.equations)
            }
        }.frame(
            width: settings.chartSettings.totalChartWidth,
            height: settings.chartSettings.totalChartHeight,
            alignment: .leading
        )
    }

    private var concentrationChart: some View {
        MultiConcentrationPlot(
            equations: model.components.equations,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            showData: model.showConcentrationLines,
            offset: model.chartOffset,
            discontinuity: model.components.chartDiscontinuity,
            settings: settings.chartSettings
        )
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: model.quotientEquation,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            showData: model.showQuotientLine,
            offset: model.chartOffset,
            discontinuity: model.components.chartDiscontinuity,
            settings: settings.quotientChartSettings(
                convergenceQ: model.convergenceQuotient,
                maxQ: model.maxQuotient
            )
        )
    }

    private var chartSelectionToggle: some View {
        HStack {
            selectionToggleText(isGraph: true)
            Spacer()
            selectionToggleText(isGraph: false)
            Spacer()
        }
        .frame(
            width: settings.chartSize,
            height: settings.chartSelectionHeight
        )
        .padding(.leading, settings.chartSettings.yAxisWidthLabelWidth)
        .padding(.bottom, settings.chartSelectionBottomPadding)
        .font(.system(size: settings.chartSelectionFontSize))
    }

    private func selectionToggleText(isGraph: Bool) -> some View {
        SelectionToggleText(
            text: isGraph ? "Graph" : "Table",
            isSelected: showGraph == isGraph,
            action: { showGraph = isGraph }
        )
        .font(.system(size: settings.chartSelectionFontSize))
    }
}

private struct RightStackView: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    @State private var showGrid = false

    var body: some View {
        VStack(spacing: 0) {
            reactionToggle
                .zIndex(1)
            Spacer()
            equation
            Spacer()
            gridOrScales
            Spacer()
            beaky
        }
    }

    private var reactionToggle: some View {
        HStack(spacing: 0) {
            Spacer()
            AqueousReactionDropDownSelection(
                isToggled: $model.reactionSelectionIsToggled,
                selection: $model.selectedReaction,
                height: settings.reactionToggleHeight
            ).frame(
                width: settings.reactionToggleHeight,
                height: settings.reactionToggleHeight,
                alignment: .topTrailing
            )
        }
        .frame(width: settings.gridWidth)
    }

    private var equation: some View {
        AqueousEquationView(
            equations: model.equations,
            quotient: model.quotientEquation,
            currentTime: model.currentTime,
            maxWidth: settings.equationWidth,
            maxHeight: settings.equationHeight
        )
    }

    // Must use opacity to control visibility instead of removing from stack, otherwise animation stops
    private var gridOrScales: some View {
        VStack(spacing: 0) {
            ZStack {
                grid
                    .opacity(showGrid ? 1 : 0)
                scales
                    .opacity(showGrid ? 0 : 1)
            }
            .frame(width: settings.scalesWidth, height: settings.scalesHeight)

            gridToggleSelection
                .frame(
                    width: settings.gridWidth,
                    height: settings.chartSelectionHeight
                )
        }
    }

    private var gridToggleSelection: some View {
        HStack(spacing: 0) {
            selectionToggleText(isGrid: true)
            Spacer()
            selectionToggleText(isGrid: false)
            Spacer()
        }
    }

    private var scales: some View {
        MoleculeScales(
            equations: model.equations,
            currentTime: model.currentTime
        )
        .frame(width: settings.scalesWidth, height: settings.scalesHeight)
    }

    private var grid: some View {
        EquilibriumGrid(
            currentTime: model.currentTime,
            reactants: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.aGridMolecules.coordinates,
                        color: .from(.aqMoleculeA)
                    ),
                    fractionToDraw: model.components.aGridMolecules.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.bGridMolecules.coordinates,
                        color: .from(.aqMoleculeB)
                    ),
                    fractionToDraw: model.components.bGridMolecules.fractionToDraw
                )
            ],
            products: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.cGridMolecules.coordinates,
                        color: .from(.aqMoleculeC)
                    ),
                    fractionToDraw: model.components.cGridMolecules.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.dGridMolecules.coordinates,
                        color: .from(.aqMoleculeD)
                    ),
                    fractionToDraw: model.components.dGridMolecules.fractionToDraw
                )
            ]
        )
        .frame(width: settings.gridWidth, height: settings.gridHeight)
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: false,
            settings: settings.beakySettings
        )
    }

    private func selectionToggleText(isGrid: Bool) -> some View {
        SelectionToggleText(
            text: isGrid ? "Dynamic Equilibrium" : "Pair of Scales",
            isSelected: showGrid == isGrid,
            action: { showGrid = isGrid }
        )
        .font(.system(size: settings.gridSelectionFontSize))
    }
}

private struct SelectionToggleText: View {

    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(text)
            .foregroundColor(
                isSelected ? .orangeAccent : Styling.inactiveScreenElement
            )
            .onTapGesture(perform: action)
            .lineLimit(1)
    }
}

private struct AqueousScreenLayoutSettings {
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
        let maxSizeForHeight = 0.4 * height
        let maxSizeForWidth = 0.2 * width
        return min(maxSizeForWidth, maxSizeForHeight)
    }

    var chartSelectionHeight: CGFloat {
        0.048 * height
    }

    var chartSelectionFontSize: CGFloat {
        0.8 * chartSelectionHeight
    }

    var chartSelectionBottomPadding: CGFloat {
        0.1 * chartSelectionHeight
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
    let maxYAxisValue: CGFloat

    var headRadius: CGFloat {
        0.018 * size
    }

    var layout: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0,
                maxValuePosition: size,
                minValue: 0,
                maxValue: AqueousReactionSettings.forwardReactionTime
            ),
            yAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: size,
                maxValuePosition: 0.2 * size,
                minValue: 0,
                maxValue: maxYAxisValue
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
