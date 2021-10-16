//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct LimitingReagentBeaker: View {

    init(model: LimitingReagentScreenViewModel, layout: LimitingReagentScreenLayout) {
        self.model = model
        self.components = model.components
        self.shakeModel = model.shakeReactantModel
        self.layout = layout
    }

    @ObservedObject var model: LimitingReagentScreenViewModel
    @ObservedObject var components: LimitingReagentComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>
    let layout: LimitingReagentScreenLayout

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                beaker
            }

            containers
                .mask(
                    VStack(spacing: 0) {
                        Rectangle()
                            .frame(
                                size: layout.common.containerMaskSize(
                                    rows: components.rows
                                )
                            )
                        Spacer(minLength: 0)
                    }
                )
        }
        .frame(height: layout.common.beakerAreaHeight)
    }

    private var containers: some View {
        MultiShakingContainerView(
            shakeModel: shakeModel,
            containerPosition: { layout.common.initialContainerPosition(index: $0.index) },
            activeContainerPosition: { _ in layout.common.activeContainerPosition },
            disabled: { model.input != .addReactant(type: $0) },
            containerWidth: layout.common.containerWidth,
            containerSettings: { reactant in
                .init(
                    labelColor: containerColor(reactant),
                    label: containerLabel(reactant),
                    labelFontSize: layout.common.containerFontSize,
                    labelFontColor: .white,
                    strokeLineWidth: 0.4
                )
            },
            moleculeSize: layout.common.containerMoleculeSize,
            topOfWaterY: layout.common.topOfWaterPosition(rows: components.rows),
            halfXShakeRange: layout.common.containerShakeHalfYRange,
            halfYShakeRange: layout.common.containerShakeHalfYRange,
            highlightedMolecule: highlightedReactantContainer,
            dismissHighlight: { model.highlights.clear() }
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var highlightedReactantContainer: LimitingReagentComponents.Reactant? {
        let elements = model.highlights.elements
        if elements.contains(.limitingReactantContainer) {
            return .limiting
        } else if elements.contains(.excessReactantContainer) {
            return .excess
        }
        return nil
    }

    private var beaker: some View {
        AdjustableFluidBeaker(
            rows: $components.rows,
            molecules: [
                BeakerMolecules(
                    coords: components.limitingReactantCoords,
                    color: components.reaction.limitingReactant.color,
                    label: components.reaction.limitingReactant.name.label
                ),
                BeakerMolecules(
                    coords: components.excessReactantCoords,
                    color: components.reaction.excessReactant.color,
                    label: components.reaction.excessReactant.name.label
                )
            ],
            animatingMolecules: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: components.productCoords,
                        color: components.reaction.product.color,
                        label: components.reaction.product.name.label
                    ),
                    fractionToDraw: LinearEquation(x1: 0, y1: 0, x2: 1, y2: 1)
                )
            ],
            currentTime: components.reactionProgress,
            settings: layout.common.beakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: model.highlights.colorMultiply(for: nil),
            sliderColorMultiply: model.highlights.colorMultiply(for: .beakerSlider),
            beakerModifier: BeakerAddReactantsAction(model: model)
        )
    }

    private func containerColor(_ reactant: LimitingReagentComponents.Reactant) -> Color {
        switch reactant {
        case .limiting: return components.reaction.limitingReactant.color
        case .excess: return components.reaction.excessReactant.color
        }
    }

    private func containerLabel(_ reactant: LimitingReagentComponents.Reactant) -> TextLine {
        switch reactant {
        case .limiting: return components.reaction.limitingReactant.name
        case .excess: return components.reaction.excessReactant.name
        }
    }
}

private extension LimitingReagentComponents.Reactant {
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? -1
    }
}

private struct BeakerAddReactantsAction: ViewModifier {
    let model: LimitingReagentScreenViewModel

    func body(content: Content) -> some View {
        content.modifyIf(UIAccessibility.isVoiceOverRunning) {
            $0
            .modifier(
                BeakerAddOneReactantAction(
                    model: model,
                    name: model.reaction.limitingReactant.name.label,
                    reactant: .limiting
                )
            )
            .modifier(
                BeakerAddOneReactantAction(
                    model: model,
                    name: model.reaction.excessReactant.name.label,
                    reactant: .excess
                )
            )
        }
    }
}

private struct BeakerAddOneReactantAction: ViewModifier {

    @ObservedObject var model: LimitingReagentScreenViewModel
    let name: String
    let reactant: LimitingReagentComponents.Reactant


    func body(content: Content) -> some View {
        content
            .modifyIf(model.input == .addReactant(type: reactant)) {
                $0
                .accessibilityAction(
                    named: Text("Add 5 \(name) molecules to the beaker"),
                    ({ model.add(reactant: reactant, count: 5)  })
                )
                .accessibilityAction(
                    named: Text("Add 15 \(name) molecules to the beaker"),
                    ({ model.add(reactant: reactant, count: 15)  })
                )
            }
    }
}

struct LimitingReagentBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            LimitingReagentBeaker(
                model: .init(),
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
