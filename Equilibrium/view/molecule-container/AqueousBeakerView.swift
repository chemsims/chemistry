//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousBeakerView<Nav: ScreenState>: View {

    @ObservedObject var model: AqueousOrIntegrationReactionViewModel<Nav>
    let settings: EquilibriumAppLayoutSettings

    var body: some View {
        ZStack(alignment: .bottom) {
            beaker
                .accessibility(sortPriority: 3)
            shakeText
                .opacity(model.showShakeText ? 1 : 0)
                .animation(.easeOut(duration: 0.5))
            molecules
                .accessibility(sortPriority: 4)
            reactionDefinition
                .accessibility(sortPriority: 5)
        }
        .frame(height: settings.height)
        .accessibilityElement(children: .contain)
        .padding(.leading, settings.beakerLeftPadding)
    }

    private var shakeText: some View {
        HStack {
            Spacer()

            VStack {
                ShakeText()
                    .font(.system(size: settings.shakeTextFontSize))
                Spacer()
                    .frame(height: 1.1 * (settings.beakerHeight + settings.beakerBottomPadding))
            }
        }
        .frame(width: settings.beakerSettings.innerBeakerWidth)
        .padding(.leading, settings.sliderSettings.handleWidth)
    }

    private var reactionDefinition: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: settings.sliderSettings.handleWidth)
                AnimatingReactionDefinition(
                    coefficients: model.selectedReaction.coefficients,
                    direction: model.reactionDefinitionDirection
                )
                .background(reactionBackground)
                .frame(
                    width: settings.reactionDefinitionWidth,
                    height: settings.reactionDefinitionHeight
                )
            }
            Spacer()
        }
    }

    private var reactionBackground: some View {
        Group {
            if model.highlightedElements.highlight(.reactionDefinition) {
                Rectangle()
                    .foregroundColor(.white)
                    .padding(.vertical, -0.07 * settings.reactionDefinitionHeight)
            } else {
                EmptyView()
            }
        }
    }

    private var molecules: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.sliderSettings.handleWidth)
            AddMoleculesView(
                model: model.addingMoleculesModel,
                inputState: model.inputState,
                topRowHeight: settings.moleculeContainerYPos,
                containerWidth: settings.moleculeContainerWidth,
                containerHeight: settings.moleculeContainerHeight,
                startOfWater: topOfWaterPosition,
                moleculeSize: settings.moleculeSize,
                topRowColorMultiply: model.highlightedElements.colorMultiply(for: .moleculeContainers),
                onDrag: { model.highlightedElements.clear() },
                showShakeText: { model.showShakeTextIfNeeded() }
            )
            .frame(
                width: settings.beakerSettings.innerBeakerWidth - settings.moleculeSize
            )
            .mask(
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(
                            width: settings.beakerWidth + (2 * settings.moleculeContainerHeight),
                            height: topOfWaterPosition
                        )
                    Spacer()
                }

            )
        }
    }

    private var beaker: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: [],
            animatingMolecules: model.components.beakerMolecules.map(\.animatingMolecules),
            currentTime: model.currentTime,
            settings: AdjustableFluidBeakerSettings(
                minRows: AqueousReactionSettings.minRows,
                maxRows: AqueousReactionSettings.maxRows,
                beakerWidth: settings.beakerWidth,
                beakerHeight: settings.beakerHeight,
                sliderSettings: settings.sliderSettings,
                sliderHeight: settings.sliderHeight
            ),
            canSetLevel: model.canSetLiquidLevel,
            beakerColorMultiply: model.highlightedElements.colorMultiply(for: nil),
            sliderColorMultiply: model.highlightedElements.colorMultiply(for: .waterSlider),
            beakerModifier: AddMoleculesAccessibilityModifier(
                reactantsEnabled: model.inputState == .addReactants,
                productsEnabled: model.inputState == .addProducts,
                doAdd: manualAddMolecule
            )
        )
        .padding(.bottom, settings.beakerBottomPadding)
    }

    private func manualAddMolecule(molecule: AqueousMolecule, amount: Int) {
        model.increment(molecule: molecule, count: amount)
    }

    private var topOfWaterPosition: CGFloat {
        let topFromSlider = settings.sliderAxis.getPosition(at: model.rows)
        return settings.height - settings.sliderHeight + topFromSlider - settings.beakerBottomPadding
    }
}

private struct AddMoleculesAccessibilityModifier: ViewModifier {
    let reactantsEnabled: Bool
    let productsEnabled: Bool
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                AddReactantsAccessibilityModifier(
                    enabled: reactantsEnabled,
                    doAdd: doAdd
                )
            )
            .modifier(
                AddProductsAccessibilityModifier(
                    enabled: productsEnabled,
                    doAdd: doAdd
                )
            )
    }
}

private struct AddReactantsAccessibilityModifier: ViewModifier {
    let enabled: Bool
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .A, doAdd: doAdd))
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .B, doAdd: doAdd))
    }
}

private struct AddProductsAccessibilityModifier: ViewModifier {
    let enabled: Bool
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .C, doAdd: doAdd))
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .D, doAdd: doAdd))
    }
}

private struct AddToBeakerAccessibilityModifier: ViewModifier {
    let enabled: Bool
    let molecule: AqueousMolecule
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(AddSingleCountToBeakerAccessibilityModifier(enabled: enabled, molecule: molecule, count: 5, doAdd: doAdd))
            .modifier(AddSingleCountToBeakerAccessibilityModifier(enabled: enabled, molecule: molecule, count: 15, doAdd: doAdd))
    }
}

private struct AddSingleCountToBeakerAccessibilityModifier: ViewModifier {

    let enabled: Bool
    let molecule: AqueousMolecule
    let count: Int
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content.modifyIf(enabled) {
            $0.accessibilityAction(named: Text("Add \(count) of \(molecule.rawValue) to the beaker")) {
                doAdd(molecule, count)
            }
        }
    }
}

struct AddMoleculeWithLiquidBeaker_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
            .previewLayout(.iPhoneSELandscape)
    }

    private struct ViewWrapper: View {

        init() {
            self.model = AqueousReactionViewModel()
            self.model.highlightedElements.clear()
        }

        let model: AqueousReactionViewModel

        var body: some View {
            GeometryReader { geo in
                AqueousBeakerView(
                    model: model,
                    settings: EquilibriumAppLayoutSettings(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            }
        }
    }
}
