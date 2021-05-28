//
// Reactions App
//


import SwiftUI

struct IntroScreen: View {

    let layout: AcidBasesGeneralScreenLayout
    @ObservedObject var model: IntroScreenViewModel

    var body: some View {
        GeometryReader { geo in
            IntroScreenWithSettings(
                model: model,
                layout: IntroScreenLayout(general: layout)
            )
        }
    }
}

struct IntroScreenWithSettings: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        Text("foo")
    }

}

struct IntroScreenLayout {
    let general: AcidBasesGeneralScreenLayout
    
}

struct IntroScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroScreen(
                layout: AcidBasesGeneralScreenLayout(
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
