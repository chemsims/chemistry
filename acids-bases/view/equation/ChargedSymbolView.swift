//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChargedSymbolView: View {

    let symbol: AcidOrBase.ChargedSymbol

    var body: some View {
        HStack(spacing: 0) {
            FixedText("[\(symbol.symbol)")
            if symbol.charge != nil {
                FixedText(symbol.charge!.rawValue)
                    .font(.system(size: EquationSizing.subscriptFontSize))
                    .offset(y: -10)
            }

            FixedText("]")
        }
        .font(.system(size: EquationSizing.fontSize))
    }
}

struct ChargedSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        ChargedSymbolView(symbol: AcidOrBase.weakAcids.first!.chargedSymbol(ofPart: .primaryIon))
    }
}
