//
// Reactions App
//


import SwiftUI

struct GaseousReactionScreen: View {

    let model: GaseousReactionViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                GaseousReactionScreenWithSettings(
                    model: model,
                    settings: AqueousScreenLayoutSettings(geometry: geometry)
                )
            }
        }
    }

}

private struct GaseousReactionScreenWithSettings: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        Text("")
    }
}

struct GaseousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GaseousReactionScreen(
            model: GaseousReactionViewModel()
        )
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
