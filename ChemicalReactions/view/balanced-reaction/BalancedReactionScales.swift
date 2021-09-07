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
            scales(for: .hydrogen)
            Spacer(minLength: 0)
            scales(for: .nitrogen)
            Spacer(minLength: 0)
            scales(for: .carbon)
        }
        .frame(width: layout.scalesTotalWidth)
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
    static let cols = 8
    static let rows = 8
    static let maxMoleculeCount = CGFloat(MoleculeScales.gridCoords(cols: cols, rows: rows).count)

    init(balancer: ReactionBalancer) {
        self.balancer = balancer
    }

    let balancer: ReactionBalancer

    func atomFraction(of atom: BalancedReaction.Atom, elementType: BalancedReaction.ElementType) -> CGFloat {
        let count = balancer.atomCount(of: atom, elementType: elementType)
        return CGFloat(count) / Self.maxMoleculeCount
    }
}
