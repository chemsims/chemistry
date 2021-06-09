//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferBeaker: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            container
            beaker
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
        VStack {
            HStack(spacing: 0) {
                Button(action: model.incrementWeakSubstance) {
                    Text("HA")
                }
                Spacer()
                Button(action: model.incrementSalt) {
                    Text("MA")
                }
                Spacer()
                Button(action: model.incrementStrongSubstance) {
                    Text("HCl")
                }
            }
            .frame(width: layout.common.beakerWidth)
            Spacer()
        }
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
