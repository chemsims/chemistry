//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousBeakerView: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

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
    }

    private var shakeText: some View {
        HStack {
            Spacer()

            VStack {
                ShakeText()
                    .font(.system(size: settings.shakeTextFontSize))
                Spacer()
                    .frame(height: 1.1 * settings.beakerHeight)
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
        HStack(alignment: .bottom, spacing: 0) {
            CustomSlider(
                value: $model.rows,
                axis: settings.sliderAxis,
                orientation: .portrait,
                includeFill: true,
                settings: settings.sliderSettings,
                disabled: !model.canSetLiquidLevel,
                useHaptics: true
            )
            .frame(
                width: settings.sliderSettings.handleWidth,
                height: settings.sliderHeight
            )
            .background(
                Color.white
                    .padding(.horizontal, -0.2 * settings.sliderSettings.handleWidth)
                    .padding(.top, -0.2 * settings.sliderSettings.handleWidth)
            )
            .colorMultiply(model.highlightedElements.colorMultiply(for: .waterSlider))
            .accessibility(label: Text("Slider for number of rows of molecules in beaker"))

            FilledBeaker(
                molecules: [],
                animatingMolecules: model.components.beakerMolecules.map(\.animatingMolecules),
                currentTime: model.currentTime,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
            .modifier(AddReactantsModifier(enabled: model.inputState == .addReactants, doAdd: manualAddMolecule))
            .modifier(AddProductsModifier(enabled: model.inputState == .addProducts, doAdd: manualAddMolecule))
        }
    }

    private func manualAddMolecule(molecule: AqueousMolecule, amount: Int) {
        model.increment(molecule: molecule, count: amount)
    }

    private var topOfWaterPosition: CGFloat {
        let topFromSlider = settings.sliderAxis.getPosition(at: model.rows)
        return settings.height - settings.sliderHeight + topFromSlider
    }
}

private struct AddReactantsModifier: ViewModifier {
    let enabled: Bool
    let doAdd: (AqueousMolecule, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .A, doAdd: doAdd))
            .modifier(AddToBeakerAccessibilityModifier(enabled: enabled, molecule: .B, doAdd: doAdd))
    }
}

private struct AddProductsModifier: ViewModifier {
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
                    settings: AqueousScreenLayoutSettings(geometry: geo)
                )
            }
        }
    }
}
