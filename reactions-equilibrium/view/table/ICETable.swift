//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ICETable: View {

    let columns: [ICETableColumn]

    var body: some View {
        GeometryReader { geo in
            SizedICETable(
                width: geo.size.width,
                height: geo.size.height,
                columns: columns
            )
        }
    }
}

struct ICETableColumn {
    let header: String
    let initialValue: CGFloat
    let finalValue: CGFloat
}

private struct SizedICETable: View {

    let width: CGFloat
    let height: CGFloat

    let columns: [ICETableColumn]

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                cell("ICE")
                    .accessibility(label: Text("ICE Table"))
                    .accessibility(addTraits: .isHeader)
                cell("Initial")
                    .accessibility(hidden: true)
                cell("Change")
                    .accessibility(hidden: true)
                cell("Final")
                    .accessibility(hidden: true)
            }
            ForEach(0..<columns.count, id: \.self) { i in
                column(index: i)
            }
        }
        .font(.system(size: 0.05 * width))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func column(index: Int) -> some View {
        let columnValue = columns[index]
        let initial = columnValue.initialValue
        let final = columnValue.finalValue

        // Sometimes a very small change appears as a negative 0 in the table
        let change = abs(final - initial) < 0.00001 ? 0 : final - initial
        let changeSign = change > 0 ? "+" : ""
        let changeString = "\(changeSign)\(change.str(decimals: 2))"

        return VStack(spacing: 0) {
            cell(columnValue.header)
                .animation(nil)
                .accessibility(hidden: true)
            cell(initial)
                .accessibility(label: Text("Initial \(columnValue.header)"))

            cell(changeString, emphasise: true)
                .accessibility(label: Text("Change in \(columnValue.header)"))

            cell(final, emphasise: true)
                .accessibility(label: Text("Final \(columnValue.header)"))
        }
    }

    private func cell(_ value: CGFloat, emphasise: Bool = false) -> some View {
        cell("\(value.str(decimals: 2))", emphasise: emphasise)
    }

    private func cell(_ text: String, emphasise: Bool = false) -> some View {
        Text(text)
            .frame(width: width / CGFloat((1 + columns.count)), height: height / 4)
            .foregroundColor(emphasise ? .orangeAccent : .black)
            .background(
                Rectangle()
                    .stroke()
            )
            .accessibility(value: Text(text))
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
            columns: [
                ICETableColumn(header: "A", initialValue: 1, finalValue: 2),
                ICETableColumn(header: "B", initialValue: 2, finalValue: 3),
            ]
        )
        .padding()
    }
}
