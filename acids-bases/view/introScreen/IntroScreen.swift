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
        IntroBeaker(model: model, layout: layout)
    }

}

struct IntroScreenLayout {
    let common: AcidBasesScreenLayout
    
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
