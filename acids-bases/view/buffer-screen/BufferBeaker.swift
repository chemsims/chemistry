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

    // TODO - try this out with just 1 beaker where all models are passed in, and it
    // chooses the properties to pass deeper down based on the phase. Rather than have
    // completely different beaker views
    private var beaker: some View {
        VStack(spacing: 0) {
            Spacer()
            switch model.phase {
            case .addWeakSubstance:
                AddWeakSubstanceBeaker(
                    layout: layout,
                    model: model,
                    components: model.weakSubstanceModel
                )
            case .addSalt:
                ReactingBeaker(
                    layout: layout,
                    model: model,
                    components: model.saltComponents.reactingModel
                )
            default:
                ReactingBeaker(
                    layout: layout,
                    model: model,
                    components: model.phase3Model.reactingModel
                )
            }
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
            label: "",
            color: .red,
            rows: model.rows,
            disabled: model.input != .addMolecule(phase: phase)
        )
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


private struct AddWeakSubstanceBeaker: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var components: BufferWeakSubstanceComponents

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: [components.substanceCoords],
            animatingMolecules: components.ionCoords,
            currentTime: components.progress,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: BufferBeakerAccessibilityModifier()
        )
    }
}

private struct ReactingBeaker: View {
    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var components: ReactingBeakerViewModel<SubstancePart>

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: components.molecules.map(\.molecules),
            animatingMolecules: [],
            currentTime: 0,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: BufferBeakerAccessibilityModifier()
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
