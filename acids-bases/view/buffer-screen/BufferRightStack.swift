//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferRightStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            terms
            Spacer()
            beaker
        }
    }

    private var terms: some View {
        SwitchingBufferEquationView(
            model: model,
            weakSubstanceModel: model.weakSubstanceModel,
            saltModel: model.saltModel,
            strongSubstanceModel: model.strongSubstanceModel
        )
        .frame(size: layout.equationSize)
    }

    private var beaker: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canGoNext,
            settings: layout.common.beakySettings
        )
    }
}

private struct SwitchingBufferEquationView: View {

    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var weakSubstanceModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongSubstanceModel: BufferStrongSubstanceComponents

    var body: some View {
        BufferEquationView(
            substance: model.substance,
            progress: progress,
            state: model.equationState,
            data: data
        )
    }

    private var progress: CGFloat {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.progress
        case .addSalt: return CGFloat(saltModel.substanceAdded)
        case .addStrongSubstance: return CGFloat(strongSubstanceModel.substanceAdded)
        }
    }

    private var data: BufferEquationData {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.equationData
        case .addSalt: return saltModel.equationData
        case .addStrongSubstance: return strongSubstanceModel.equationData
        }
    }
}

struct BufferRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferRightStack(
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
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
