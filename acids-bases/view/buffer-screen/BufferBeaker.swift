//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferBeaker: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            stackedReactionDefinition
            beaker
            container
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
            reaction: model.substance.reactionDefinition,
            fontSize: layout.common.reactionDefinitionFontSize,
            circleSize: layout.common.reactionDefinitionCircleSize
        )
        .frame(size: layout.common.reactionDefinitionSize)
        .background(Color.white)
        .padding(.leading, layout.common.reactionDefinitionLeadingPadding)
        .animation(nil, value: model.substance)
        .minimumScaleFactor(0.5)
        .colorMultiply(model.highlights.colorMultiply(for: .reactionDefinition))
    }

    private var beaker: some View {
        VStack(spacing: 0) {
            Spacer()
            BufferBeakerWithMolecules(
                layout: layout,
                model: model,
                weakSubstanceModel: model.weakSubstanceModel,
                saltModelReaction: model.saltModel.reactingModel,
                strongSubstanceReaction: model.strongSubstanceModel.reactingModel
            )
        }
        .padding(.bottom, layout.common.beakerBottomPadding)
    }

    private var container: some View {
        BufferMoleculeContainers(
            layout: layout,
            model: model,
            shakeModel: model.shakeModel
        )
    }
}

private struct BufferBeakerWithMolecules: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var weakSubstanceModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModelReaction: ReactingBeakerViewModel<SubstancePart>
    @ObservedObject var strongSubstanceReaction: ReactingBeakerViewModel<SubstancePart>

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            currentTime: reactionProgress,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: model.highlights.colorMultiply(for: nil),
            sliderColorMultiply: model.highlights.colorMultiply(for: .waterSlider),
            beakerModifier: BufferBeakerAccessibilityModifier()
        )
    }

    private var molecules: [BeakerMolecules] {
        switch model.phase {
        case .addWeakSubstance: return [weakSubstanceModel.substanceCoords]
        case .addSalt: return saltModelReaction.molecules.map(\.molecules)
        case .addStrongSubstance: return strongSubstanceReaction.molecules.map(\.molecules)
        }
    }

    private var animatingMolecules: [AnimatingBeakerMolecules] {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.ionCoords
        default: return []
        }
    }

    private var reactionProgress: CGFloat {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.progress
        default: return 0
        }
    }
}

private struct BufferMoleculeContainers: View {

    typealias Phase = BufferScreenViewModel.Phase

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<Phase>

    var body: some View {
        ZStack {
            highlight

            container(phase: .addWeakSubstance, index: 0)
            container(phase: .addSalt, index: 1)
            container(phase: .addStrongSubstance, index: 2)
        }
        .frame(width: containerAreaWidth)
        .offset(x: layout.common.sliderSettings.handleWidth)
        .colorMultiply(model.highlights.colorMultiply(for: .containers))
    }

    private var highlight: some View {
        Rectangle()
            .frame(
                height: 1.2 * layout.common.containerSize.height
            )
            .position(
                x: containerAreaWidth / 2,
                y: layout.containerRowYPos
            )
            .foregroundColor(.white)
    }

    private func container(
        phase: Phase,
        index: Int
    ) -> some View {
        AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: containerLocation(phase: phase, index: index),
            activeLocation: activeContainerLocation,
            type: phase,
            label: containerLabel(phase: phase),
            color: containerColor(phase: phase),
            topOfWaterPosition: layout.common.topOfWaterPosition(
                rows: model.rows
            ),
            disabled: model.input != .addMolecule(phase: phase),
            onActivateContainer: { _ in
                model.highlights.clear()
            }
        )
    }

    private func containerColor(phase: Phase) -> Color {
        switch phase {
        case .addWeakSubstance: return model.substance.color
        case .addSalt: return .red // TODO move to styling
        case .addStrongSubstance: return .purple // TODO move to styling
        }
    }

    private func containerLabel(phase: Phase) -> TextLine {
        switch phase {
        case .addWeakSubstance:
            return model.substance.chargedSymbol(ofPart: .substance).text
        case .addSalt:
            let suffix = model.substance.chargedSymbol(ofPart: .secondaryIon).text
            return suffix.prepending(TextSegment(content: "M"))
        case .addStrongSubstance: return "HCl"
        }
    }

    private func containerLocation(
        phase: Phase,
        index: Int
    ) -> CGPoint {
        let containerX = CGFloat(index + 1) * (containerAreaWidth / 4)
        return CGPoint(x: containerX, y: layout.containerRowYPos)
    }

    private var activeContainerLocation: CGPoint {
        CGPoint(x: containerAreaWidth / 2, y: layout.activeContainerYPos)
    }

    private var containerAreaWidth: CGFloat {
        layout.common.beakerWidth
    }
}

// TODO
private struct BufferBeakerAccessibilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct BufferBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferBeaker(
                layout: BufferScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: BufferScreenViewModel(
                    namePersistence: InMemoryNamePersistence()
                )
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
