//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ICETable: View {

    let initial: MoleculeValue<CGFloat>
    let final: MoleculeValue<CGFloat>

    var body: some View {
        GeometryReader { geo in
            SizedICETable(
                width: geo.size.width,
                height: geo.size.height,
                initialValues: initial,
                finalValues: final
            )
        }
    }
}

private struct SizedICETable: View {

    let width: CGFloat
    let height: CGFloat
    let initialValues: MoleculeValue<CGFloat>
    let finalValues: MoleculeValue<CGFloat>

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                cell("ICE")
                cell("Initial")
                cell("Change")
                cell("Final")
            }
            column(molecule: .A)
            column(molecule: .B)
            column(molecule: .C)
            column(molecule: .D)
        }
        .font(.system(size: 0.05 * width))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func column(molecule: AqueousMolecule) -> some View {
        let initial = initialValues.value(for: molecule)
        let final = finalValues.value(for: molecule)

        // Sometimes a very small change appears as a negative 0 in the table
        let change = abs(final - initial) < 0.00001 ? 0 : final - initial
        let changeSign = change > 0 ? "+" : ""
        let changeString = "\(changeSign)\(change.str(decimals: 2))"

        return VStack(spacing: 0) {
            cell(molecule.rawValue)
            cell(initial)
            cell(changeString, emphasise: true)
            cell(final, emphasise: true)
        }
    }

    private func cell(_ value: CGFloat, emphasise: Bool = false) -> some View {
        cell("\(value.str(decimals: 2))", emphasise: emphasise)
    }

    private func cell(_ text: String, emphasise: Bool = false) -> some View {
        Text(text)
            .frame(width: width / 5, height: height / 4)
            .foregroundColor(emphasise ? .orangeAccent : .black)
            .background(
                Rectangle()
                    .stroke()
            )
    }
}

extension Equation {
    fileprivate func delta(t2: CGFloat) -> CGFloat {
        getY(at: t2) - getY(at: 0)
    }
}

struct ICETable_Previews: PreviewProvider {
    static var previews: some View {
        ICETable(
            initial: MoleculeValue(builder: { _ in 1 }),
            final: MoleculeValue(builder: { _ in 1 })
        )
        .padding()
    }
}
