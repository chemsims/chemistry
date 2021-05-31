//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroRightStack: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
           bottomRow
        }
        .frame(width: layout.common.rightColumnWidth)
    }

    private var bottomRow: some View {
        HStack(spacing: 0) {
            Spacer()
            beaky
        }
    }

    private var beaky: some View {
        BeakyBox(
            statement: [],
            next: { },
            back: { },
            nextIsDisabled: false,
            settings: layout.common.beakySettings
        )
    }
}

struct IntroRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroRightStack(
                model: IntroScreenViewModel(),
                layout: IntroScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
