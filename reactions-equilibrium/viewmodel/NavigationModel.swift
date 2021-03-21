//
// Reactions App
//


import SwiftUI

struct RootNavigationView: View {
    @ObservedObject var model: RootNavigationModel

    var body: some View {
        model.view
            .transition(.opacity)
    }
}

// TODO - remove this when root nav model from rates has been factored out into
// reactions core
class RootNavigationModel: ObservableObject {

    @Published var view: AnyView

    init() {
        self.view = AnyView(EmptyView())
        goToAqueous()
    }

    private var aqModel: AqueousReactionViewModel?

    private func goToAqueous() {
        let model = aqModel ?? AqueousReactionViewModel()
        self.aqModel = model
        model.navigation?.nextScreen = goToGaseous
        withAnimation(.easeOut(duration: 0.35)) {
            view = AnyView(AqueousReactionScreen(model: model))
        }
    }

    private func goToGaseous() {
        let model = GaseousReactionViewModel()
        model.navigation?.prevScreen = goToAqueous
        withAnimation(.easeOut(duration: 0.35)) {
            view = AnyView(GaseousReactionScreen(model: model))
        }
    }
}
