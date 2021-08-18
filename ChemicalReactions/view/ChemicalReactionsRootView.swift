//
// Reactions App
//


import SwiftUI

public struct ChemicalReactionsRootView: View {

    public init() { }

    public var body: some View {
        BalancedReactionScreen(
            model: BalancedReactionViewModel()
        )
    }
}

struct ChemicalReactionsRootView_Previews: PreviewProvider {
    static var previews: some View {
        ChemicalReactionsRootView()
    }
}
