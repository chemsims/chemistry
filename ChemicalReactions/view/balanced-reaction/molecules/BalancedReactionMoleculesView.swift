//
// Reactions App
//


import SwiftUI

struct BalancedReactionMoleculeView: View {
    var body: some View {
        Text("Hello, world")
    }
}

extension BalancedReactionMoleculeView {
    struct Atom: View {
        let size: CGFloat
        let atom: BalancedReaction.Atom

        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(atom.color)
                
                Text(atom.symbol)
                    .font(.system(size: 0.75 * size))
                    .foregroundColor(.white)
            }
            .frame(square: size)
        }
    }
}

struct BalancedReactionMoleculesView_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView()
    }
}
