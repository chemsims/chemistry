//
// Reactions App
//


import Foundation

struct CsvParser {

    static let quoteCharacter: Character = "\""
    static let colDelimiter: Character = ","

    static func parse(content: String) -> [[String]] {
        guard !content.isEmpty else {
            return []
        }

        var rows = [[String]]()
        var isQuoted = false

        var position = content.indices.first!
        var rowBuffer = [String]()
        var cellBuffer = ""

        while(content.indices.contains(position)) {
            let element = content[position]
            let nextIndex = content.index(after: position)
            let nextElement = content.indices.contains(nextIndex) ? content[nextIndex] : nil

            // Special case of 2 quote characters
            if element == quoteCharacter, let next = nextElement, next == quoteCharacter {
                cellBuffer.append(quoteCharacter)
                position = content.index(position, offsetBy: 2)
                continue
            }

            switch element {
            case _ where nextElement == nil:
                if element != quoteCharacter && element != colDelimiter {
                    cellBuffer.append(element)
                }
                rowBuffer.append(cellBuffer)
                if element == colDelimiter {
                    // if final char is col-delim, then there should be an extra cell
                    rowBuffer.append("")
                }
                rows.append(rowBuffer)
                cellBuffer.removeAll()
                rowBuffer.removeAll()
            case quoteCharacter:
                isQuoted.toggle()
            case colDelimiter where !isQuoted:
                rowBuffer.append(cellBuffer)
                cellBuffer.removeAll()
            case _ where element.isNewline && !isQuoted:
                rowBuffer.append(cellBuffer)
                rows.append(rowBuffer)
                rowBuffer.removeAll()
                cellBuffer.removeAll()
            default:
                cellBuffer.append(element)
            }

            position = content.index(after: position)
        }

        return rows
    }
}
