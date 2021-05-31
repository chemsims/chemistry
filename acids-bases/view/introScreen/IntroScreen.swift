//
// Reactions App
//


import SwiftUI

struct IntroScreen: View {

    let layout: AcidBasesScreenLayout
    @ObservedObject var model: IntroScreenViewModel

    var body: some View {
        GeometryReader { geo in
            IntroScreenWithSettings(
                model: model,
                layout: IntroScreenLayout(common: layout)
            )
        }
    }
}

struct IntroScreenWithSettings: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            IntroBeaker(model: model, layout: layout)
            Spacer()
            IntroRightStack(model: model, layout: layout)
        }
    }
}

struct IntroScreenLayout {
    let common: AcidBasesScreenLayout
}


// MARK: Left stack layout
extension IntroScreenLayout {
    var containerRowYPos: CGFloat {
        50
    }

    var activeContainerYPos: CGFloat {
        containerRowYPos + common.containerSize.height
    }
}

struct IntroScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroScreen(
                layout: AcidBasesScreenLayout(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                ),
                model: IntroScreenViewModel()
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
