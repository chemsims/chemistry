//
// Reactions App
//

import SwiftUI

public struct ICETable: View {

    /// Creates a new ICETable.
    ///
    /// - Parameters:
    ///     - columns: The table columns.
    ///     - x: The x value to pass into the column equations. A default value of 0 is used. Note that columns
    ///          can be constructed using constant values, in which case the `x` parameter has no effect.
    public init(
        columns: [ICETableColumn],
        x: CGFloat = 0
    ) {
        self.columns = columns
        self.x = x
    }

    let columns: [ICETableColumn]
    let x: CGFloat

    public var body: some View {
        GeometryReader { geo in
            SizedICETable(
                width: geo.size.width,
                height: geo.size.height,
                x: x,
                columns: columns
            )
        }
        .accessibilityElement(children: .contain)
    }
}

/// Represents a column in the ICE table.
public struct ICETableColumn {

    /// Creates a new instance using fixed values
    ///
    /// - Parameters:
    ///     - header: String of the header row.
    ///     - initialValue: The initial value.
    ///     - finalValue: The final value.
    ///     - formatInitial: Closure to format initial value as a String.
    ///     - formatFinal: Closure to format the final value as a String.
    ///     - formatChange: Closure to format the change in value as a String. Note that a '+' will be
    ///                     prepended to the String for a positive change.
    public init(
        header: String,
        initialValue: CGFloat,
        finalValue: CGFloat,
        formatInitial: @escaping (CGFloat) -> String = { $0.str(decimals: 2) },
        formatFinal: @escaping (CGFloat) -> String = { $0.str(decimals: 2) },
        formatChange: @escaping (CGFloat) -> String = { $0.str(decimals: 2) }
    ) {
        self.header = header
        self.initialValue = ConstantEquation(value: initialValue)
        self.finalValue = ConstantEquation(value: finalValue)
        self.formatInitial = formatInitial
        self.formatFinal = formatFinal
        self.formatChange = formatChange
    }

    /// Creates a new instance using equations
    ///
    /// - Parameters:
    ///     - header: String of the header row.
    ///     - initialValue: The initial value.
    ///     - finalValue: The final value.
    ///     - formatInitial: Closure to format initial value as a String.
    ///     - formatFinal: Closure to format the final value as a String.
    ///     - formatChange: Closure to format the change in value as a String. Note that a '+' will be
    ///                     prepended to the String for a positive change.
    public init(
        header: String,
        initialValue: Equation,
        finalValue: Equation,
        formatInitial: @escaping (CGFloat) -> String = { $0.str(decimals: 2) },
        formatFinal: @escaping (CGFloat) -> String = { $0.str(decimals: 2) },
        formatChange: @escaping (CGFloat) -> String = { $0.str(decimals: 2) }
    ) {
        self.header = header
        self.initialValue = initialValue
        self.finalValue = finalValue
        self.formatInitial = formatInitial
        self.formatFinal = formatFinal
        self.formatChange = formatChange
    }

    let header: String
    let initialValue: Equation
    let finalValue: Equation

    let formatInitial: (CGFloat) -> String
    let formatFinal: (CGFloat) -> String
    let formatChange: (CGFloat) -> String
}

private struct SizedICETable: View {

    let width: CGFloat
    let height: CGFloat

    let x: CGFloat

    let columns: [ICETableColumn]

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                cell("ICE")
                    .accessibility(label: Text("ICE Table"))
                    .accessibility(addTraits: .isHeader)
                    .accessibility(sortPriority: sortPriority(col: 0, row: 0))

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


        let change = ChangeInValueEquation(initial: initial, final: final)

        return VStack(spacing: 0) {
            cell(columnValue.header)
                .animation(nil)
                .accessibility(hidden: true)
            cell(initial, formatter: columnValue.formatInitial)
                .accessibility(label: Text("Initial \(columnValue.header)"))
                .accessibility(sortPriority: sortPriority(col: index, row: 0))

            cell(
                change,
                formatter: {
                    formatChange($0, formatter: columnValue.formatChange)
                },
                emphasise: true
            )
            .accessibility(label: Text("Change in \(columnValue.header)"))
            .accessibility(sortPriority: sortPriority(col: index, row: 1))

            cell(
                final,
                formatter: columnValue.formatFinal,
                emphasise: true
            )
            .accessibility(label: Text("Final \(columnValue.header)"))
            .accessibility(sortPriority: sortPriority(col: index, row: 2))
        }
    }

    private func cell(
        _ equation: Equation,
        formatter: @escaping (CGFloat) -> String,
        emphasise: Bool = false
    ) -> some View {
        AnimatingNumber(
            x: x,
            equation: equation,
            formatter: formatter
        )
        .frame(width: width / CGFloat((1 + columns.count)), height: height / 4)
        .foregroundColor(emphasise ? .orangeAccent : .black)
        .background(
            Rectangle()
                .stroke()
        )
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

    // Sometimes a very small change appears as a negative 0 in the table
    private func formatChange(
        _ change: CGFloat,
        formatter: (CGFloat) -> String
    ) -> String {
        let sign = change > 0 ? "+" : ""
        return "\(sign)\(formatter(change))"
    }

    private struct ChangeInValueEquation: Equation {
        let initial: Equation
        let final: Equation

        func getValue(at x: CGFloat) -> CGFloat {
            let delta = final.getValue(at: x) - initial.getValue(at: x)
            return abs(delta) < 0.00001 ? 0 : delta
        }
    }


    // The implicit accessibility ordering was found to sometimes be incorrect,
    // so we pass in an explicit sort ordering
    private func sortPriority(col: Int, row: Int) -> Double {
        let maxCols = columns.count
        let maxRows = 4

        let maxIndex = maxCols * maxRows
        let prevCells = (0..<row).map { $0 * maxCols }.sum()
        return Double(maxIndex - (col * row) - prevCells)
    }
}

extension Equation {
    fileprivate func delta(t2: CGFloat) -> CGFloat {
        getValue(at: t2) - getValue(at: 0)
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
