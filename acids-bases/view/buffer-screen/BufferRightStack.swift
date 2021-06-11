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
            saltModel: model.saltComponents,
            strongSubstanceModel: model.phase3Model
        )
        .frame(size: layout.equationSize)
    }

    private var beaker: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: false,
            settings: layout.common.beakySettings
        )
    }
}

private struct SwitchingBufferEquationView: View {

    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var weakSubstanceModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongSubstanceModel: BufferComponents3

    var body: some View {
        BufferEquationView(
            progress: progress,
            state: model.equationState,
            data: data
        )
    }

    private var progress: CGFloat {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.progress
        case .addSalt: return CGFloat(saltModel.substanceAdded)
        default: return 0
        }
    }

    private var data: BufferEquationData {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.equationData
        default: return saltModel.equationData
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
