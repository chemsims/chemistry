//
// Reactions App
//

import SwiftUI
import ReactionRates

struct ContentView: View {
    var body: some View {
        ReactionsRateRootView(model: .inMemory)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
