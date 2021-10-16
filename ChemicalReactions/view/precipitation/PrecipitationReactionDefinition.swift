//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationReactionDefinition: View {

    let reaction: PrecipitationReaction
    let showMetal: Bool
    let emphasiseMetal: Bool
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 4) {
            unknownReactant
            FixedText("+")
            knownReactant
            FixedText("➝")
            product
            FixedText("+")
            secondaryProduct
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))

    }

    private var unknownReactant: some View {
        TextLinesView(
            line: unknownReactantTextLine,
            fontSize: fontSize
        )
    }

    private var knownReactant: some View {
        TextLinesView(
            line: knownReactantTextLine,
            fontSize: fontSize
        )
    }

    private var product: some View {
        TextLinesView(
            line: productTextLine,
            fontSize: fontSize
        )
    }

    private var secondaryProduct: some View {
        TextLinesView(
            line: secondaryProductTextLine,
            fontSize: fontSize
        )
    }

    private var knownReactantTextLine: TextLine {
        reaction.knownReactant.nameWithState
    }

    private var unknownReactantTextLine: TextLine {
        reaction.unknownReactant.nameWithState(showMetal: showMetal, emphasiseMetal: emphasiseMetal)
    }

    private var productTextLine: TextLine {
        reaction.product.nameWithState
    }

    private var secondaryProductTextLine: TextLine {
        reaction.secondaryProduct.nameWithState(showMetal: showMetal, emphasiseMetal: emphasiseMetal)
    }

    private var label: String {
        let reactants = unknownReactantTextLine.label + " + " + knownReactantTextLine.label 
        let products = productTextLine.label + " + " + secondaryProductTextLine.label
        return "\(reactants) yields \(products)"
    }
}
