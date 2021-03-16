//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ICETable: View {

    let data: MoleculeValue<ICETableElement>

    var body: some View {
        GeometryReader { geo in
            SizedICETable(
                width: geo.size.width,
                height: geo.size.height,
                data: data
            )
        }
    }
}

private struct SizedICETable: View {

    let width: CGFloat
    let height: CGFloat
    let data: MoleculeValue<ICETableElement>

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                cell("ICE")
                cell("Initial")
                cell("Change")
                cell("Final")
            }
            column(element: data.reactantA, name: "A")
            column(element: data.reactantB, name: "B")
            column(element: data.productC, name: "C")
            column(element: data.productD, name: "D")
        }
        .font(.system(size: 0.05 * width))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func column(element: ICETableElement, name: String) -> some View {
        // Sometimes a very small change appears as a negative 0 in the table, so handle that here
        let change = abs(element.change) < 0.00001 ? 0 : element.change
        let changeSign = change > 0 ? "+" : ""
        let changeString = "\(changeSign)\(change.str(decimals: 2))"

        return VStack(spacing: 0) {
            cell(name)
            cell(element.initial)
            cell(changeString, emphasise: true)
            cell(element.final, emphasise: true)
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
            data: MoleculeValue(
                reactantA: ICETableElement(initial: 0, final: 1),
                reactantB: ICETableElement(initial: 0.2, final: 0.3),
                productC: ICETableElement(initial: 0.3, final: 0.1),
                productD: ICETableElement(initial: 0.4, final: 0.2)
            )
        )
        .padding()
    }
}
