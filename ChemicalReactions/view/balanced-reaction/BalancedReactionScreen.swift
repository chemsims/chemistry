//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionScreen: View {

    @ObservedObject var model: BalancedReactionScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            SizedBalancedReactionScreen(
                model: model,
                moleculeModel: model.moleculePosition,
                layout: BalancedReactionScreenLayout(
                    common: ChemicalReactionsScreenLayout(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
        .padding(ChemicalReactionsScreenLayout.topLevelScreenPadding)
    }
}

private struct SizedBalancedReactionScreen: View {

    @ObservedObject var model: BalancedReactionScreenViewModel
    @ObservedObject var moleculeModel: BalancedReactionMoleculePositionViewModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        ZStack {
            emptyBeakers
                .accessibilityElement(children: .contain)
                .accessibility(sortPriority: 8)

            moleculeLabels
                .accessibility(hidden: true)

            BalancedReactionTopStack(
                model: moleculeModel,
                emphasiseCoefficients: model.emphasiseReactionCoefficients,
                layout: layout
            )
            .accessibility(sortPriority: 9)

            beaky
                .accessibility(sortPriority: 10)

            BalancedReactionScreen.BalancedReactionScreenMolecules(
                model: model,
                moleculeModel: moleculeModel,
                layout: layout
            )
            .accessibility(sortPriority: 7)

            reactionSelection
        }
        .accessibilityElement(children: .contain)
    }

    private var moleculeLabels: some View {
        ZStack {
            Text("Products")
                .frame(size: layout.moleculeTableLabelSize)
                .rotationEffect(.degrees(-90))
                .position(layout.moleculeTableProductLabelPosition)

            Text("Reactants")
                .frame(size: layout.moleculeTableLabelSize)
                .rotationEffect(.degrees(-90))
                .position(layout.moleculeTableReactantLabelPosition)

            Rectangle()
                .frame(size: layout.moleculeTableDividerSize)
                .position(layout.moleculeTableRect.center)
        }
        .font(.system(size: layout.moleculeTableLabelFontSize))
        .foregroundColor(.orangeAccent)
        .minimumScaleFactor(0.5)
    }

    private var emptyBeakers: some View {
        Group {
            EmptyBeaker(
                settings: layout.beakerSettings,
                emphasised: !model.moleculesInFlightOverReactant.isEmpty
            )
            .frame(size: layout.beakerSize)
            .position(layout.firstBeakerPosition)
            .modifier(EmptyBeakerAccessibilityModifier(model: model, elementType: .reactant))

            reactionArrow
                .accessibilityElement(children: .ignore)
                .accessibility(hidden: true)

            EmptyBeaker(
                settings: layout.beakerSettings,
                emphasised: !model.moleculesInFlightOverProduct.isEmpty
            )
            .frame(size: layout.beakerSize)
            .position(layout.secondBeakerPosition)
            .modifier(EmptyBeakerAccessibilityModifier(model: model, elementType: .product))

            if model.elementTypesInFlight.contains(.reactant) {
                beakerUnderline
                    .position(layout.firstBeakerUnderlinePosition)
            }

            if model.elementTypesInFlight.contains(.product) {
                beakerUnderline
                    .position(layout.secondBeakerUnderlinePosition)
            }
        }
    }

    private var reactionArrow: some View {
        Image(systemName: "arrow.right")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.orangeAccent)
            .frame(width: layout.reactionArrowWidth)
            .position(layout.reactionArrowPosition)
    }

    private var beakerUnderline: some View {
        Rectangle()
            .frame(width: layout.beakerSize.width, height: layout.beakerUnderlingHeight)
            .foregroundColor(.orangeAccent)
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canGoNext,
            settings: layout.common.beakySettings
        )
        .spacing(horizontalAlignment: .trailing, verticalAlignment: .bottom)
    }

    private var reactionSelection: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: BalancedReaction.availableReactions,
            isToggled: .constant(model.inputState == .selectReaction),
            selection: $model.reaction,
            height: layout.common.reactionSelectionToggleHeight,
            animation: nil,
            displayString: { $0.display },
            label: { $0.display.label },
            disabledOptions: model.unavailableReactions,
            onSelection: model.didSelectReaction
        )
        .disabled(model.inputState != .selectReaction)
        .spacing(horizontalAlignment: .trailing, verticalAlignment: .top)
    }
}

private struct BalancedReactionTopStack: View {

    @ObservedObject var model: BalancedReactionMoleculePositionViewModel
    let emphasiseCoefficients: Bool
    let layout: BalancedReactionScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            BalancedReactionDefinition(
                model: model.reactionBalancer,
                emphasiseCoefficients: emphasiseCoefficients,
                layout: layout
            )

            Spacer(minLength: 0)

            scales

            Spacer(minLength: 0)
        }
        .padding(.bottom, layout.beakerSize.height)
        .horizontalSpacing(alignment: .leading)
    }

    private var scales: some View {
        BalancedReactionScales(
            model: .init(balancer: model.reactionBalancer),
            layout: layout
        )
    }
}

private struct EmptyBeakerAccessibilityModifier: ViewModifier {

    @ObservedObject var model: BalancedReactionScreenViewModel
    let elementType: BalancedReaction.ElementType

    // Note the reason we wrap the action in a check that voice over is running, is that the
    // action uses other conditional view modifiers. Conditionally changing a view like this
    // can produce some unwanted animations. These aren't big animations - they might be a
    // little opacity change for example, so they aren't a big concern. But we should still
    // only do it when necessary, so that's why we check voice over is running before doing it.
    func body(content: Content) -> some View {
        content
        .accessibility(label: Text(emptyBeakerLabel(element: elementType)))
        .accessibility(value: Text(model.beakerAccessibilityValue(elementType: elementType)))
        .modifyIf(
            UIAccessibility.isVoiceOverRunning && model.inputState == .dragMolecules,
            modifier: EmptyBeakerAccessibilityActionModifier(
                model: model,
                elementType: elementType
            )
        )
    }

    private func emptyBeakerLabel(element: BalancedReaction.ElementType) -> String {
        "Beaker showing \(element.label) molecules added"
    }
}

private struct EmptyBeakerAccessibilityActionModifier: ViewModifier {

    let model: BalancedReactionScreenViewModel
    let elementType: BalancedReaction.ElementType

    func body(content: Content) -> some View {
        content
            .modifier(
                EmptyBeakerMoleculeInteractionModifier(
                    model: model,
                    elementType: elementType,
                    element: elements.first
                )
            )
            .modifyIf(
                elements.second != nil,
                modifier: EmptyBeakerMoleculeInteractionModifier(
                    model: model,
                    elementType: elementType,
                    // There is a delay where this modifier will be evaluated, even after
                    // elements.second is nil, so we must not force unwrap it.
                    element: elements.second ?? elements.first
                )
            )
    }

    private var elements: BalancedReaction.Elements {
        model.reaction.elements(ofType: elementType)
    }
}

private struct EmptyBeakerMoleculeInteractionModifier: ViewModifier {
    let model: BalancedReactionScreenViewModel
    let elementType: BalancedReaction.ElementType
    let element: BalancedReaction.Element

    func body(content: Content) -> some View {
        content
            .accessibilityAction(named: Text("Add 1 \(molecule) molecule"), addMolecule)
            .accessibilityAction(named: Text("Remove 1 \(molecule) molecule"), removeMolecule)
    }

    private func addMolecule() {
        model.accessibilityAddMoleculeAction(molecule: element.molecule, element: elementType)
    }

    private func removeMolecule() {
        model.accessibilityRemoveMoleculeAction(molecule: element.molecule)
    }

    private var molecule: String {
        element.molecule.textLine.label
    }
}

struct BalancedReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BalancedReactionScreen(
                model: BalancedReactionScreenViewModel()
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
