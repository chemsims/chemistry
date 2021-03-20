//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousReactionScreen: View {

    @ObservedObject var model: AqueousReactionViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                AqueousReactionScreenWithSettings(
                    model: model,
                    settings: AqueousScreenLayoutSettings(geometry: geometry)
                )
            }
            .padding(10)
        }
    }
}

private struct AqueousReactionScreenWithSettings: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            AqueousBeakerView(model: model, settings: settings)
            Spacer()
            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                activeChartIndex: $model.activeChartIndex,
                settings: settings
            )
            Spacer()
            RightStackView(model: model, settings: settings)
        }
    }
}

struct RightStackView: View {

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
            equations: model.components.equation,
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
            reaction: model.components.equation,
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
                        coords: model.components.equilibriumGrid.reactantA.coordinates,
                        color: .from(.aqMoleculeA)
                    ),
                    fractionToDraw: model.components.equilibriumGrid.reactantA.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.equilibriumGrid.reactantB.coordinates,
                        color: .from(.aqMoleculeB)
                    ),
                    fractionToDraw: model.components.equilibriumGrid.reactantB.fractionToDraw
                )
            ],
            products: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.equilibriumGrid.productC.coordinates,
                        color: .from(.aqMoleculeC)
                    ),
                    fractionToDraw: model.components.equilibriumGrid.productC.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: model.components.equilibriumGrid.productD.coordinates,
                        color: .from(.aqMoleculeD)
                    ),
                    fractionToDraw: model.components.equilibriumGrid.productD.fractionToDraw
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

struct AqueousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhoneSELandscape)

        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
