//
// Reactions App
//


import SwiftUI

struct SolubilityScreen: View {

    let model: SolubilityViewModel

    var body: some View {
        GeometryReader { geo in
            SolubilityScreenWithSettings(
                model: model,
                settings: SolubilityScreenLayoutSettings(geometry: geo)
            )
        }
    }
}

private struct SolubilityScreenWithSettings: View {

    @ObservedObject var model: SolubilityViewModel
    let settings: SolubilityScreenLayoutSettings

    var body: some View {
        Text("Hello, World!")
    }

}

private struct SolubilityScreenLayoutSettings {
    let geometry: GeometryProxy

    var common: AqueousScreenLayoutSettings {
        AqueousScreenLayoutSettings(geometry: geometry)
    }
}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(model: SolubilityViewModel())
    }
}
