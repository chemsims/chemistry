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
        public init(
            cells: [TextLine],
            emphasised: Bool = false
        ) {
            self.cells = cells
            self.emphasised = emphasised
        }

        public let cells: [TextLine]
        public let emphasised: Bool
    }
}

private struct SizedTable: View {

    let width: CGFloat
    let height: CGFloat
    let rows: [Table.Row]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count) { rowIndex in
                rowView(row: rows[rowIndex])
            }
        }
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.center)
    }

    private func rowView(row: Table.Row) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<row.cells.count) { cellIndex in
                cellView(content: row.cells[cellIndex])
            }
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
