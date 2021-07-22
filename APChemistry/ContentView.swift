//
// Reactions App
//

import SwiftUI
import ReactionRates
import Equilibrium

struct ContentView: View {
    var body: some View {
        ReactionEquilibriumRootView(model: .inMemory)
//        ReactionsRateRootView(model: .inMemory)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
