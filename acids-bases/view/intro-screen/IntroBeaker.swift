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
            fontSize: layout.reactionDefinitionFontSize,
            circleSize: layout.reactionDefinitionCircleSize
        )
        .frame(size: layout.reactionDefinitionSize)
        .padding(.leading, layout.reactionDefinitionLeadingPadding)
        .animation(nil, value: components.substance.reactionDefinition)
        .minimumScaleFactor(0.5)
    }

    private var containers: some View {
        IntroBeakerContainers(
            model: model,
            components: components,
            shakeModel: model.addMoleculesModel,
            layout: layout
        )
    }

    private var beaker: some View {
        VStack {
            Spacer()
            AdjustableFluidBeaker(
                rows: $model.rows,
                molecules: components.coords.all,
                animatingMolecules: [],
                currentTime: 0,
                settings: layout.common.adjustableBeakerSettings,
                canSetLevel: model.inputState == .setWaterLevel,
                beakerColorMultiply: .white,
                sliderColorMultiply: .white,
                beakerModifier: AddMoleculesAccessibilityModifier()
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
            phMeter
            container(.strongAcid, 0)
            container(.strongBase, 1)
            container(.weakAcid, 2)
            container(.weakBase, 3)
        }
        .frame(width: totalBeakerWidth)
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
        let label = substance?.chargedSymbol(ofPart: .substance).text ?? ""
        return AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: containerLocation(type, index),
            activeLocation: activeContainerLocation,
            type: type,
            label: label,
            color: substance?.color ?? RGB.placeholderContainer.color,
            topOfWaterPosition: layout.common.topOfWaterPosition(
                rows: model.rows
            ),
            disabled: model.inputState != .addSubstance(type: type)
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
    // TODO
    func body(content: Content) -> some View {
        content
    }
}

struct IntroBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroBeaker(
                model: IntroScreenViewModel(
                    namePersistence: InMemoryNamePersistence()
                ),
                components: IntroScreenViewModel(
                    namePersistence: InMemoryNamePersistence()
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
