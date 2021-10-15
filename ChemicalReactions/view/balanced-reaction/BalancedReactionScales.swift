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
        VStack(spacing: 2) {
            scales(for: atom)
            HStack(spacing: 0) {
                scalesLabel(atom: atom, elementType: .reactant)
                checkmark(for: atom)
                scalesLabel(atom: atom, elementType: .product)
            }
            .frame(width: layout.scalesSize.width)
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func checkmark(for atom: BalancedReaction.Atom) -> some View {
        if model.balancer.atomIsBalanced(atom) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: layout.scalesLabelSize)
                .foregroundColor(.green)
                .transition(.scale.animation(.easeOut(duration: 0.25)))
        } else {
            Spacer()
                .frame(size: layout.scalesLabelSize)
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
            .minimumScaleFactor(0.7)
            .accessibilityElement(children: .contain)
            .accessibility(hidden: true)
    }

    private func scales(for atom: BalancedReaction.Atom) -> some View {
        MoleculeScales(
            leftMolecules: .single(
                concentration: .init(
                    fractionToDraw: ConstantEquation(value: model.atomFraction(of: atom, elementType: .reactant)),
                    color: atom.color,
                    label: "reactant"
                )
            ),
            rightMolecules: .single(
                concentration: .init(
                    fractionToDraw: ConstantEquation(value: model.atomFraction(of: atom, elementType: .product)),
                    color: atom.color,
                    label: "product"
                )
            ),
            rotationFraction: ConstantEquation(value: model.rotation(of: atom)),
            equationInput: 0,
            badge: .init(
                label: atom.symbol,
                fontColor: .white,
                backgroundColor: atom.color
            ),
            cols: BalancedReactionScalesModel.cols,
            rows: BalancedReactionScalesModel.rows,
            scalesAccessibilityLabel: scalesAccessibilityLabel(atom: atom)
        )
        .frame(size: layout.scalesSize)
        .animation(.easeOut(duration: 0.5), value: model.rotation(of: atom))
        .animation(nil, value: model.showScales(for: atom))
    }

    private func scalesAccessibilityLabel(atom: BalancedReaction.Atom) -> String {
        """
        Scales showing \(atom.name) atoms added, with reactants on the left \
        and products on the right
        """
    }
}

struct BalancedReactionScalesModel {
    static let cols = 5
    static let rows = 5
    static let maxMoleculeCount = CGFloat(MoleculeScales.gridCoords(cols: cols, rows: rows).count)

    init(balancer: ReactionBalancer) {
        self.balancer = balancer
    }

    let balancer: ReactionBalancer

    func rotation(of atom: BalancedReaction.Atom) -> CGFloat {
        let reactantCount = balancer.atomCount(of: atom, elementType: .reactant)
        let productCount = balancer.atomCount(of: atom, elementType: .product)
        let productSurplus = CGFloat(productCount - reactantCount)
        return ChemicalReactionsSettings.productAtomSurplusToRotation.getY(at: productSurplus)
    }

    func atomFraction(of atom: BalancedReaction.Atom, elementType: BalancedReaction.ElementType) -> CGFloat {
        let count = balancer.atomCount(of: atom, elementType: elementType)
        return CGFloat(count) / Self.maxMoleculeCount
    }

    func showScales(for atom: BalancedReaction.Atom) -> Bool {
        balancer.reaction.setOfAtoms.contains(atom)
    }
}
