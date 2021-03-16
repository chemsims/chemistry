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
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            mainContent
                .padding(AqueousScreenLayoutSettings.padding)
        }
    }

    private var mainContent: some View {
        HStack(spacing: 0) {
            AqueousBeakerView(model: model, settings: settings)
            Spacer()
            MiddleStackView(model: model, settings: settings)
            Spacer()
            RightStackView(model: model, settings: settings)
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
                .colorMultiply(
                    model.highlightedElements.colorMultiply(for: nil)
                )
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
                ICETable(equations: model.components.equations)
                    .colorMultiply(
                        model.highlightedElements.colorMultiply(for: nil)
                    )
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
            discontinuities: model.components.moleculeChartDiscontinuities,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            showData: model.showConcentrationLines,
            offset: model.chartOffset,
            minDragTime: model.components.quotientChartDiscontinuity?.x,
            canSetIndex: model.canSetChartIndex,
            activeIndex: $model.activeChartIndex,
            settings: settings.chartSettings
        )
        .colorMultiply(model.highlightedElements.colorMultiply(for: .chartEquilibrium))
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: model.quotientEquation,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            equilibriumTime: model.equations.convergenceTime,
            showData: model.showQuotientLine,
            offset: model.chartOffset,
            discontinuity: model.components.quotientChartDiscontinuity,
            settings: settings.quotientChartSettings(
                convergenceQ: model.convergenceQuotient,
                maxQ: model.maxQuotient
            )
        )
        .colorMultiply(model.highlightedElements.colorMultiply(for: .chartEquilibrium))
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
            if model.inputState != .selectReactionType {
                AqueousReactionTypeView(
                    type: model.selectedReaction,
                    highlightTopArrow: model.highlightForwardReactionArrow,
                    highlightReverseArrow: model.highlightReverseReactionArrow
                )
                .minimumScaleFactor(0.5)
            }

            Spacer()
            AqueousReactionDropDownSelection(
                isToggled: $model.reactionSelectionIsToggled,
                selection: $model.selectedReaction,
                onSelection: model.next,
                height: settings.reactionToggleHeight
            ).frame(
                width: settings.reactionToggleHeight,
                height: settings.reactionToggleHeight,
                alignment: .topTrailing
            )
            .disabled(model.inputState != .selectReactionType)
        }
        .frame(width: settings.gridWidth, height: settings.reactionToggleHeight)
        .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
    }

    private var equation: some View {
        AqueousEquationView(
            showTerms: model.showEquationTerms,
            equations: model.equations,
            quotient: model.quotientEquation,
            convergedQuotient: model.convergenceQuotient,
            currentTime: model.currentTime,
            highlightedElements: model.highlightedElements,
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
        .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
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

struct AqueousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhoneSELandscape)

        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
