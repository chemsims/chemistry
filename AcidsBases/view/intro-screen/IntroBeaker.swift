//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroBeaker: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
    let layout: IntroScreenLayout

    var body: some View {
        ZStack(alignment: .bottom) {
            stackedReactionDefinition
            beaker
            containers
        }
        .frame(height: layout.common.height)
    }

    private var stackedReactionDefinition: some View {
        VStack {
            reactionDefinition
            Spacer(minLength: 0)
        }
    }

    private var reactionDefinition: some View {
        ReactionDefinitionView(
            reaction: components.substance.reactionDefinition,
            fontSize: layout.common.reactionDefinitionFontSize,
            circleSize: layout.common.reactionDefinitionCircleSize
        )
        .frame(size: layout.common.reactionDefinitionSize)
        .padding(.leading, layout.common.reactionDefinitionLeadingPadding)
        .padding(.top, layout.common.reactionDefinitionTopPadding)
        .animation(nil, value: components.substance.reactionDefinition)
        .minimumScaleFactor(0.5)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var containers: some View {
        IntroBeakerContainers(
            model: model,
            components: components,
            shakeModel: model.addMoleculesModel,
            layout: layout
        )
    }

    @ViewBuilder
    private var beaker: some View {
        if UIAccessibility.isVoiceOverRunning {
            beaker(AddMoleculesAccessibilityModifier(model: model))
        } else {
            beaker(IdentityViewModifier())
        }
    }

    private func beaker<V: ViewModifier>(_ modifier: V) -> some View {
        VStack {
            Spacer()
            AdjustableFluidBeaker(
                rows: $model.rows,
                molecules: components.coords.all,
                animatingMolecules: [],
                currentTime: 0,
                settings: layout.common.adjustableBeakerSettings,
                canSetLevel: model.inputState == .setWaterLevel,
                beakerColorMultiply: model.highlights.colorMultiply(for: nil),
                sliderColorMultiply: model.highlights.colorMultiply(for: .waterSlider),
                beakerModifier: modifier
            )
        }
        .padding(.bottom, layout.common.beakerBottomPadding)
    }
}

private struct IntroBeakerContainers: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<AcidOrBaseType>
    let layout: IntroScreenLayout

    @GestureState private var pHMeterOffset = CGSize.zero

    var body: some View {
        ZStack {
            highlight

            phMeter
            container(.strongAcid, 0)
            container(.strongBase, 1)
            container(.weakAcid, 2)
            container(.weakBase, 3)
        }
        .frame(width: totalBeakerWidth)
        .colorMultiply(model.highlights.colorMultiply(for: .beakerTools))
    }

    private var highlight: some View {
        Rectangle()
            .frame(height: 1.1 * layout.common.phMeterSize.height)
            .foregroundColor(.white)
            .position(
                x: layout.common.beakerPlusSliderWidth / 2,
                y: layout.containerRowYPos
            )
    }

    private var phMeter: some View {
        DraggablePhMeter(
            pHEquation: pHEquation,
            pHEquationInput: 0,
            shouldShowLabelWhenInWater: true,
            layout: layout.common,
            initialPosition: CGPoint(x: phMeterX, y: layout.containerRowYPos),
            rows: model.rows,
            beakerDistanceFromBottomOfScreen: 0
        )
    }

    private func container(
        _ type: AcidOrBaseType,
        _ index: Int
    ) -> some View {
        let substance = model.selectedSubstances.value(for: type)
        let textLine = substance?.chargedSymbol(ofPart: .substance).text
        let label = textLine ?? ""
        return AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: containerLocation(type, index),
            activeLocation: activeContainerLocation,
            type: type,
            label: label,
            accessibilityName: textLine?.label,
            color: substance?.color ?? RGB.placeholderContainer.color,
            topOfWaterPosition: layout.common.topOfWaterPosition(
                rows: model.rows
            ),
            disabled: model.inputState != .addSubstance(type: type),
            includeContainerBackground: false,
            onActivateContainer: { _ in model.highlights.clear() }
        )
    }

    private var phMeterX: CGFloat {
        let leadingSpacing = common.beakerToolsLeadingPadding
        let phWidth = common.phMeterSize.width
        return leadingSpacing + (phWidth / 2)
    }

    private func containerLocation(
        _ element: AcidOrBaseType,
        _ index: Int
    ) -> CGPoint {
        CGPoint(x: containerX(index), y: layout.containerRowYPos)
    }

    private var activeContainerLocation: CGPoint {
        CGPoint(x: common.beakerWaterCenterX, y: layout.activeContainerYPos)
    }

    private func containerX(_ index: Int) -> CGFloat {
        let spacing = common.beakerToolsSpacing
        let containerWidth = common.containerSize.width
        let endOfPh = phMeterX + (common.phMeterSize.width / 2)
        let firstContainerX = endOfPh + spacing + (containerWidth / 2)

        return firstContainerX + (CGFloat(index) * (spacing + containerWidth))
    }

    private var common: AcidBasesScreenLayout {
        layout.common
    }

    private var totalBeakerWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

    private var pHEquation: Equation {
        ConstantEquation(value: components.concentration(ofIon: .hydrogen).p)
    }
}

struct AddMoleculesAccessibilityModifier: ViewModifier {

    @ObservedObject var model: IntroScreenViewModel

    private let firstCount = 5
    private let secondCount = 15

    func body(content: Content) -> some View {
        content
            .modifyIf(inputIsNotNil, modifier: modifier)
    }

    // Even though we check for nil, don't force unwrap optionals, as it can still fail.
    private var modifier: some ViewModifier {
        BeakerAccessibilityAddMultipleCountActions(
            actionName: { count in
                "Add \(count) molecules of \(label ?? "") to the beaker"
            },
            doAdd: { count in
                model.increment(type: currentInputType ?? .strongAcid, count: count)
            },
            firstCount: firstCount,
            secondCount: secondCount
        )
    }

    private var inputIsNotNil: Bool {
        currentInputType != nil && label != nil
    }

    private var currentInputType: AcidOrBaseType? {
        if case let .addSubstance(type) = model.inputState {
            return type
        }
        return nil
    }

    private var label: String? {
        if let inputType = currentInputType,
           let substance = model.selectedSubstances.value(for: inputType) {
            return substance.symbol.label
        }
        return nil
    }
}

struct IntroBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroBeaker(
                model: IntroScreenViewModel(
                    substancePersistence: InMemoryAcidOrBasePersistence(),
                    namePersistence: InMemoryNamePersistence.shared
                ),
                components: IntroScreenViewModel(
                    substancePersistence: InMemoryAcidOrBasePersistence(),
                    namePersistence: InMemoryNamePersistence.shared
                ).components,
                layout: IntroScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhoneSELandscape)
        .padding()
    }
}
