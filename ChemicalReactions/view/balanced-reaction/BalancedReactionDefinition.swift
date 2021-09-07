//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionDefinition: View {

    let model: ReactionBalancer
    let layout: BalancedReactionScreenLayout

    var body: some View {
        HStack(spacing: sideSpacing) {
            side(elements: model.reaction.reactants)
            Text("➝")
            side(elements: model.reaction.products)
        }
        .frame(size: layout.reactionDefinitionSize)
        .font(.system(size: layout.reactionDefinitionFontSize))
        .minimumScaleFactor(0.75)
    }

    private func side(elements: BalancedReaction.Elements) -> some View {
        HStack(alignment: .top, spacing: elementSpacing) {
            term(molecule: elements.first.molecule)
            if let second = elements.second {
                Text("+")
                term(molecule: second.molecule)
            }
        }
    }

    private func term(molecule: BalancedReaction.Molecule) -> some View {
        HStack(alignment: .top, spacing: coeffSpacing) {
            coefficientBox(model.count(of: molecule))

            TextLinesView(line: molecule.textLine, fontSize: layout.reactionDefinitionFontSize)
        }
    }

    private func coefficientBox(_ coeff: Int) -> some View {
        Group {
            if coeff == 0 {
                PlaceholderBox()
            } else {
                Text("\(coeff)")
                    .foregroundColor(.orangeAccent)
            }
        }
        .frame(size: placeholderSize, alignment: .topTrailing)
    }

    private var placeholderSize: CGSize {
        CGSize(
            width: 0.9 * layout.reactionDefinitionFontSize,
            height: 1.1 * layout.reactionDefinitionFontSize
        )
    }

    private var sideSpacing: CGFloat {
        0.5 * layout.reactionDefinitionFontSize
    }


    private var elementSpacing: CGFloat {
        0.5 * sideSpacing
    }

    private var coeffSpacing: CGFloat {
        0.25 * elementSpacing
    }
}

struct BalancedReactionDefinition_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BalancedReactionDefinition(
                model: .init(reaction: .firstReaction),
                layout: .init(common: .init(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                )
                )
            )
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
