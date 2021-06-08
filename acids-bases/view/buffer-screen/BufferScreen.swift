//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferScreen: View {

    let layout: AcidBasesScreenLayout
    let model: BufferScreenViewModel

    var body: some View {
        GeometryReader { geo in
            BufferScreenWithSettings(
                layout: BufferScreenLayout(common: layout),
                model: model
            )
        }
    }
}

private struct BufferScreenWithSettings: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        HStack(spacing: 0) {
            BufferBeaker(
                layout: layout,
                model: model
            )
            Spacer()
            BufferChartStack(
                layout: layout,
                model: model
            )
            Spacer()
            BufferRightStack(
                layout: layout,
                model: model
            )
        }
    }
}

struct BufferScreenLayout {
    let common: AcidBasesScreenLayout
}

struct BufferScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferScreen(
                layout: AcidBasesScreenLayout(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                ),
                model: BufferScreenViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
