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
            beaker
            container
        }
        .frame(height: layout.common.height)
    }

    private var beaker: some View {
        VStack(spacing: 0) {
            Spacer()
            BufferBeakerWithMolecules(
                layout: layout,
                model: model,
                weakSubstanceModel: model.weakSubstanceModel,
                saltModelReaction: model.saltComponents.reactingModel,
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
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
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
            container(phase: .addWeakSubstance, index: 0)
            container(phase: .addSalt, index: 1)
            container(phase: .addStrongSubstance, index: 2)
        }
        .frame(width: containerAreaWidth)
        .offset(x: layout.common.sliderSettings.handleWidth)
    }

    private func container(
        phase: Phase,
        index: Int
    ) -> some View {
        AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            onTap: { didTapContainer(phase: phase, index: index) },
            initialLocation: containerLocation(phase: phase, index: index),
            type: phase,
            label: containerLabel(phase: phase),
            color: containerColor(phase: phase),
            rows: model.rows,
            disabled: model.input != .addMolecule(phase: phase)
        )
    }

    private func containerColor(phase: Phase) -> Color {
        switch phase {
        case .addWeakSubstance: return model.substance.color
        case .addSalt: return .red // TODO move to styling
        case .addStrongSubstance: return .purple // TODO move to styling
        }
    }

    private func containerLabel(phase: Phase) -> String {
        switch phase {
        case .addWeakSubstance: return model.substance.symbol
        case .addSalt: return "M\(model.substance.secondary.rawValue)"
        case .addStrongSubstance: return "HCl"
        }
    }

    private func containerLocation(
        phase: Phase,
        index: Int
    ) -> CGPoint {
        if shakeModel.activeMolecule == phase {
            return CGPoint(x: containerAreaWidth / 2, y: layout.activeContainerYPos)
        }

        let containerX = CGFloat(index + 1) * (containerAreaWidth / 4)
        return CGPoint(x: containerX, y: layout.containerRowYPos)
    }

    private var containerAreaWidth: CGFloat {
        layout.common.beakerWidth
    }

    private func didTapContainer(
        phase: Phase,
        index: Int
    ) {
        if shakeModel.activeMolecule == phase {
            shakeModel.model(for: phase).manualAdd(amount: 5)
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            shakeModel.activeMolecule = phase
        }
        shakeModel.start(
            for: phase,
            at: containerLocation(phase: phase, index: index),
            bottomY: layout.common
                .topOfWaterPosition(rows: model.rows),
            halfXRange: layout.common.containerShakeHalfXRange,
            halfYRange: layout.common.containerShakeHalfYRange
        )
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
                model: BufferScreenViewModel()
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
