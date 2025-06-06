//
// Reactions App
//

import SwiftUI


/// A fixed table where all columns are the same width, and rows
/// are the same height.
///
/// Note that this table uses indices for element IDs, so the size
/// and order of the data passed in must not be changed.
public struct Table: View {

    public init(rows: [Row]) {
        self.rows = rows
    }

    let rows: [Row]

    public var body: some View {
        GeometryReader { geo in
            SizedTable(
                width: geo.size.width,
                height: geo.size.height,
                rows: rows
            )
        }
    }
}

extension Table {
    public struct Row {

        /// Constructs a new row.
        /// - Parameters:
        ///   - cells: The text content of each cell
        ///   - emphasised: Whether the row is emphasised. When true, the table controls how to
        ///   show the emphasis, for example by placing an extra border inside the row.
        ///   - colorMultiply: The color multiply of the row.
        public init(
            cells: [TextLine],
            emphasised: Bool = false,
            colorMultiply: Color = .white
        ) {
            self.cells = cells
            self.emphasised = emphasised
            self.colorMultiply = colorMultiply
        }

        public let cells: [TextLine]
        public let emphasised: Bool
        public let colorMultiply: Color
    }
}

private struct SizedTable: View {

    let width: CGFloat
    let height: CGFloat
    let rows: [Table.Row]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                rowView(row: rows[rowIndex])
            }
        }
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.center)
    }

    private func rowView(row: Table.Row) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<row.cells.count, id: \.self) { cellIndex in
                cellView(content: row.emphasised ? row.cells[cellIndex].emphasised() : row.cells[cellIndex])
            }
        }
        .background(Color.white)
        .overlay(rowEmphasis(row: row))
        .colorMultiply(row.colorMultiply)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func rowEmphasis(row: Table.Row) -> some View {
        if row.emphasised {
            Rectangle()
                .stroke()
                .padding(0.1 * cellHeight)
                .foregroundColor(.orangeAccent)
        }
    }

    private func cellView(content: TextLine) -> some View {
        TextLinesView(line: content, fontSize: fontSize)
            .frame(width: cellWidth, height: cellHeight)
            .background(
                Rectangle()
                    .stroke()
            )
    }

    private var fontSize: CGFloat {
        0.45 * cellHeight
    }

    private var cellWidth: CGFloat {
        guard maxCols > 0 else {
            return width
        }
        return width / CGFloat(maxCols)
    }

    private var maxCols: Int {
        rows.max {
            $0.cells.count < $1.cells.count
        }?.cells.count ?? 0
    }

    private var cellHeight: CGFloat {
        height / CGFloat(rows.count)
    }
}

struct Table_Previews: PreviewProvider {
    static var previews: some View {
        Table(
            rows: [
                .init(cells: ["A", "B", "C"]),
                .init(cells: ["D", "E", "F"])
            ]
        )
    }
}
