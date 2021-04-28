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
                .accessibilityElement(children: .contain)
            Spacer()
            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                settings: settings
            )
            .accessibilityElement(children: .contain)
            Spacer()
            RightStackView<AqueousReactionType>(
                model: model,
                selectedReaction: $model.selectedReaction,
                reactions: AqueousReactionType.allCases,
                reactionSelectionIsToggled: $model.reactionSelectionIsToggled,
                settings: settings
            )
        }
    }
}

struct RightStackView<Reaction: ReactionDefinition>: View {

    let statement: [TextLine]
    let componentWrapper: ReactionComponentsWrapper
    let scalesAngleFraction: Equation
    let currentTime: CGFloat
    let equilibriumQuotient: CGFloat
    let isSelectingReaction: Bool
    let reactions: [Reaction]
    @Binding var selectedReaction: Reaction
    @Binding var reactionSelectionIsToggled: Bool
    let next: () -> Void
    let back: () -> Void

    let generalElementHighlight: Color
    let quotientToConcentrationDefinitionHighlight: Color
    let quotientToEquilibriumConstantDefinitionHighlight: Color
    let reactionToggleHighlight: Color

    let showEquationTerms: Bool
    let formatElementName: (String) -> String

    let isPressure: Bool
    let settings: AqueousScreenLayoutSettings

    var components: ReactionComponents {
        componentWrapper.components
    }

    @State private var showGrid = false

    var body: some View {
        VStack(spacing: 0) {
            reactionToggle

            Spacer()
            equation
            Spacer()
            gridOrScales
            Spacer()
            beaky
        }
    }

    private var reactionToggle: some View {
        ReactionToggle(
            reactions: reactions,
            selectedReaction: $selectedReaction,
            reactionSelectionIsToggled: $reactionSelectionIsToggled,
            isSelectingReaction: isSelectingReaction,
            onSelection: next,
            reactionToggleHighlight: reactionToggleHighlight,
            settings: settings
        )
    }

    private var equation: some View {
        AqueousEquationView(
            showTerms: showEquationTerms,
            equations: isPressure ? components.equation.pressure : components.equation.concentration,
            coefficients: components.coefficients,
            quotient: isPressure ? components.pressureQuotientEquation : components.quotientEquation,
            convergedQuotient: equilibriumQuotient,
            currentTime: currentTime,
            kTerm: isPressure ? "Kp" : "K",
            formatElementName: formatElementName,
            generalElementHighlight: generalElementHighlight,
            quotientToConcentrationDefinitionHighlight: quotientToConcentrationDefinitionHighlight,
            quotientToEquilibriumConstantDefinitionHighlight: quotientToEquilibriumConstantDefinitionHighlight,
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
        .colorMultiply(generalElementHighlight)
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
            reaction: components.equation,
            angleFraction: scalesAngleFraction,
            currentTime: currentTime
        )
        .frame(width: settings.scalesWidth, height: settings.scalesHeight)
    }

    private var grid: some View {
        EquilibriumGrid(
            currentTime: currentTime,
            reactants: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: components.equilibriumGrid.reactantA.coordinates,
                        color: .from(.aqMoleculeA),
                        label: "A"
                    ),
                    fractionToDraw: components.equilibriumGrid.reactantA.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: components.equilibriumGrid.reactantB.coordinates,
                        color: .from(.aqMoleculeB),
                        label: "B"
                    ),
                    fractionToDraw: components.equilibriumGrid.reactantB.fractionToDraw
                )
            ],
            products: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: components.equilibriumGrid.productC.coordinates,
                        color: .from(.aqMoleculeC),
                        label: "C"
                    ),
                    fractionToDraw: components.equilibriumGrid.productC.fractionToDraw
                ),
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: components.equilibriumGrid.productD.coordinates,
                        color: .from(.aqMoleculeD),
                        label: "D"
                    ),
                    fractionToDraw: components.equilibriumGrid.productD.fractionToDraw
                )
            ]
        )
        .frame(width: settings.gridWidth, height: settings.gridHeight)
    }

    private var beaky: some View {
        BeakyBox(
            statement: statement,
            next: next,
            back: back,
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

extension RightStackView {
    init(
        model: AqueousReactionViewModel,
        selectedReaction: Binding<Reaction>,
        reactions: [Reaction],
        reactionSelectionIsToggled: Binding<Bool>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            statement: model.statement,
            componentWrapper: model.componentsWrapper,
            scalesAngleFraction: model.scalesRotationFraction,
            currentTime: model.currentTime,
            equilibriumQuotient: model.convergenceQuotient,
            isSelectingReaction: model.inputState == .selectReactionType,
            reactions: reactions,
            selectedReaction: selectedReaction,
            reactionSelectionIsToggled: reactionSelectionIsToggled,
            next: model.next,
            back: model.back,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            quotientToConcentrationDefinitionHighlight:
                model.highlightedElements.colorMultiply(
                    for: .quotientToConcentrationDefinition
                ),
            quotientToEquilibriumConstantDefinitionHighlight:
                model.highlightedElements.colorMultiply(
                    for: .quotientToEquilibriumConstantDefinition
                ),
            reactionToggleHighlight: model.highlightedElements.colorMultiply(for: .reactionToggle),
            showEquationTerms: model.showEquationTerms,
            formatElementName: { "[\($0)]" },
            isPressure: false,
            settings: settings
        )
    }

    init(
        model: GaseousReactionViewModel,
        selectedReaction: Binding<Reaction>,
        reactions: [Reaction],
        reactionSelectionIsToggled: Binding<Bool>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            statement: model.statement,
            componentWrapper: model.componentWrapper,
            scalesAngleFraction: model.scalesRotationFraction,
            currentTime: model.currentTime,
            equilibriumQuotient: model.equilibriumPressureQuotient,
            isSelectingReaction: model.inputState == .selectReactionType,
            reactions: reactions,
            selectedReaction: selectedReaction,
            reactionSelectionIsToggled: reactionSelectionIsToggled,
            next: model.next,
            back: model.back,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            quotientToConcentrationDefinitionHighlight: model.highlightedElements.colorMultiply(
                for: .quotientToConcentrationDefinition
            ),
            quotientToEquilibriumConstantDefinitionHighlight: model.highlightedElements.colorMultiply(
                for: .quotientToEquilibriumConstantDefinition
            ),
            reactionToggleHighlight: model.highlightedElements.colorMultiply(for: .reactionToggle),
            showEquationTerms: model.showEquationTerms,
            formatElementName: { "P\($0.lowercased())" },
            isPressure: true,
            settings: settings
        )
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
