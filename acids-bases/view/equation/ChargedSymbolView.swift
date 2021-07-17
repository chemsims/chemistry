//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChargedSymbolView: View {

    let symbol: AcidOrBase.ChargedSymbol

    var body: some View {
        TextLinesView(
            line: text,
            fontSize: EquationSizing.fontSize
        )
        .fixedSize()
    }

    private var text: TextLine {
        let charge = symbol.charge.map { "^\($0.rawValue)^" } ?? ""
        return "[\(symbol.symbol)\(charge)]"
    }
}

struct ChargedSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        ChargedSymbolView(symbol: AcidOrBase.weakAcids.first!.chargedSymbol(ofPart: .primaryIon))
    }
}
