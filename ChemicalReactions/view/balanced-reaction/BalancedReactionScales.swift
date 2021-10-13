//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionScales: View {

    let model: BalancedReactionScalesModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            ForEach(BalancedReaction.Atom.allCases) { atom in
                if model.showScales(for: atom) {
                    scalesWithLabels(for: atom)
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: layout.scalesTotalWidth)
    }

    private func scalesWithLabels(for atom: BalancedReaction.Atom) -> some View {
        VStack(spacing: 0) {
            scales(for: atom)
            HStack(spacing: 0) {
                scalesLabel(atom: atom, elementType: .reactant)
                Spacer(minLength: 0)
                scalesLabel(atom: atom, elementType: .product)
            }
            .frame(width: layout.scalesSize.width)
        }
    }

    private func scalesLabel(
        atom: BalancedReaction.Atom,
        elementType: BalancedReaction.ElementType
    ) -> some View {
        let count = model.balancer.atomCount(of: atom, elementType: elementType)
        return Text("\(count)")
            .frame(size: layout.scalesLabelSize)
            .font(.system(size: layout.scalesLabelFontSize))
            .opacity(count > 0 ? 1 : 0)
    }

    private func scales(for atom: BalancedReaction.Atom) -> some View {
        MoleculeScales(
            leftMolecules: .single(
                concentration: .init(
                    fractionToDraw: ConstantEquation(value: model.atomFraction(of: atom, elementType: .reactant)),
                    color: atom.color,
                    label: atom.symbol
                )
            ),
            rightMolecules: .single(
                concentration: .init(
                    fractionToDraw: ConstantEquation(value: model.atomFraction(of: atom, elementType: .product)),
                    color: atom.color,
                    label: atom.symbol
                )
            ),
            equationInput: 0,
            badge: .init(
                label: atom.symbol,
                fontColor: .white,
                backgroundColor: atom.color
            ),
            cols: BalancedReactionScalesModel.cols,
            rows: BalancedReactionScalesModel.rows
        )
        .frame(size: layout.scalesSize)
    }
}

struct BalancedReactionScalesModel {
    static let cols = 6
    static let rows = 6
    static let maxMoleculeCount = CGFloat(MoleculeScales.gridCoords(cols: cols, rows: rows).count)

    init(balancer: ReactionBalancer) {
        self.balancer = balancer
    }

    let balancer: ReactionBalancer

    func atomFraction(of atom: BalancedReaction.Atom, elementType: BalancedReaction.ElementType) -> CGFloat {
        let count = balancer.atomCount(of: atom, elementType: elementType)
        return CGFloat(count) / Self.maxMoleculeCount
    }

    func showScales(for atom: BalancedReaction.Atom) -> Bool {
        balancer.reaction.setOfAtoms.contains(atom)
    }
}
