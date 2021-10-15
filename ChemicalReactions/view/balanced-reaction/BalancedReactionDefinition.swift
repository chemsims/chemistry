//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionDefinition: View {

    let model: ReactionBalancer
    let emphasiseCoefficients: Bool
    let layout: BalancedReactionScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            row(showText: true)
            row(showText: false)
                .accessibility(hidden: true)
        }
        .frame(width: layout.reactionDefinitionSize.width)
        .font(.system(size: layout.reactionDefinitionFontSize))
        .minimumScaleFactor(0.75)
        .accessibilityElement(children: .contain)
    }

    private func row(showText: Bool) -> some View {
        HStack(alignment: .top, spacing: sideSpacing) {
            side(elements: model.reaction.reactants, showText: showText)
            Text("➝")
                .opacity(showText ? 1 : 0)
                .accessibility(label: Text("yields"))
            side(elements: model.reaction.products, showText: showText)
        }
    }

    private func side(elements: BalancedReaction.Elements, showText: Bool) -> some View {
        HStack(alignment: .top, spacing: elementSpacing) {
            term(molecule: elements.first.molecule, showText: showText)
            if let second = elements.second {
                Text("+")
                    .opacity(showText ? 1 : 0)
                term(molecule: second.molecule, showText: showText)
            }
        }
    }

    private func term(molecule: BalancedReaction.Molecule, showText: Bool) -> some View {
        HStack(alignment: .top, spacing: coeffSpacing) {
            coefficientBox(model.count(of: molecule))
                .accessibility(label: Text("Coefficient for \(molecule.textLine.label)"))

            TextLinesView(line: molecule.textLine, fontSize: layout.reactionDefinitionFontSize)
        }
        .opacity(showText ? 1 : 0)
        .overlay(moleculeView(molecule: molecule, show: !showText))
    }

    @ViewBuilder
    private func moleculeView(molecule: BalancedReaction.Molecule, show: Bool) -> some View {
        if show {
            BalancedReactionMoleculeView(
                structure: molecule.structure,
                atomSize: layout.reactionDefinitionMoleculeAtomSize,
                showSymbols: false
            )
        }
    }

    private func coefficientBox(_ coeff: Int) -> some View {
        let coeffString = (coeff == 1 && !emphasiseCoefficients) ? "" : "\(coeff)"
        return Group {
            if coeff == 0 {
                PlaceholderBox()
            } else {
                Text(coeffString)
                    .foregroundColor(emphasiseCoefficients ? .orangeAccent : .black)
            }
        }
        .frame(size: placeholderSize, alignment: .topTrailing)
        .accessibility(value: Text("\(coeff)"))
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
                emphasiseCoefficients: true,
                layout: .init(common: .init(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                )
                )
            )
        }
        .previewLayout(.iPadAirLandscape)
    }
}
