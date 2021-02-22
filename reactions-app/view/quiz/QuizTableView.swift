//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct QuizTableView: View {

    let table: QuizTable
    let fontSize: CGFloat
    let availableWidth: CGFloat

    var body: some View {
        QuizTableViewWithGeometry(
            settings: QuizTableSettings(
                table: table,
                availableWidth: availableWidth,
                fontSize: fontSize
            )
        )
    }
}

private struct QuizTableViewWithGeometry: View {

    let settings: QuizTableSettings

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<settings.table.cols) { i in
                col(colIndex: i)
            }
        }.minimumScaleFactor(0.5)
    }

    private func col(colIndex: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<settings.table.rows.count) { rowIndex in
                cell(
                    settings.table.rows[rowIndex][colIndex],
                    rowIndex: rowIndex,
                    colIndex: colIndex
                )
            }
        }
    }

    private func cell(
        _ line: TextLine,
        rowIndex: Int,
        colIndex: Int
    ) -> some View {
        TextLinesView(
            line: line,
            fontSize: settings.fontSize,
            weight: rowIndex == 0 ? .semibold : .regular
        )
        .padding(.horizontal, 0.07 * settings.colWidths[colIndex])
        .frame(
            width: settings.colWidths[colIndex],
            height: settings.rowHeights[rowIndex]
        )
        .background(
            rowIndex % 2 == 0 ? Styling.tableEvenRow : Styling.tableOddRow
        )
        .border(Styling.tableCellBorder, width: 0.5)
        .lineLimit(rowIndex == 0 ? 1 : nil)
        .accessibility(label: Text("Cell, column \(colIndex + 1), row \(rowIndex + 1)"))
        .accessibility(value: Text(line.label))
    }
}

private struct QuizTableSettings {
    let table: QuizTable
    let availableWidth: CGFloat
    let fontSize: CGFloat

    var minCellWidth: CGFloat {
        60
    }

    var rowHeights: [CGFloat] {
        Array(repeating: 50, count: table.rows.count)
    }

    var colWidths: [CGFloat] {
        let maxColContentLengths = table.maxColContentLengths
        let maxColContentSum = maxColContentLengths.reduce(0) { $0 + $1 }
        let idealWidths: [CGFloat] = maxColContentLengths.map { length in
            let ratio = CGFloat(length) / CGFloat(maxColContentSum)
            return CGFloat(ratio) * availableWidth
        }
        return SizeAdjuster.adjust(
            sizes: idealWidths,
            minElementSize: minCellWidth,
            maximumSum: availableWidth
        )
    }

}

fileprivate extension QuizTable {

    var maxColContentLengths: [Int] {
        (0..<cols).map { colIndex in
            colContentLengths(at: colIndex).max()!
        }
    }

    func colContentLengths(at colIndex: Int) -> [Int] {
        (0..<rows.count).map { rowIndex in
            rows[rowIndex][colIndex].length
        }
    }
}

struct QuizTableView_Previews: PreviewProvider {
    static var previews: some View {
        QuizTableView(
            table: QuizTable(
                rows: [
                    [
                        "A",
                        "B",
                        "C"
                    ],
                    [
                        "Hello! This is a very long passage. Well, it's not too long anymore. lol.",
                        "2",
                        "3"
                    ],
                    [
                        "3",
                        "4",
                        "Hello, this is also quite long! ha ha ha ! It's too long for the screen :("
                    ]
                ]
            ),
            fontSize: 20,
            availableWidth: 500
        )
        .previewLayout(.fixed(width: 500, height: 300))
    }
}
