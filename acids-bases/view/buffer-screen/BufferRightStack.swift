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
        BufferEquationView(state: model.equationState)
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
