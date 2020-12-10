//
// Reactions App
//
  

import SwiftUI

struct ConcentrationTable: View {

    let c1: String?
    let c2: String?
    let t1: String?
    let t2: String?
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let buttonSize: CGFloat

    @State private var showTable = true

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            button
            Group {
                HStack(spacing: 0) {
                    cell(value: "c")
                    cell(value: c1)
                    cell(value: c2)
                }
                HStack(spacing: 0) {
                    cell(value: "t")
                    cell(value: t1)
                    cell(value: t2)
                }
            }.opacity(showTable ? 1 : 0)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private var button: some View {
        Button(action: toggleTable) {
            ZStack {
                Rectangle()
                    .stroke()
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(0.2 * buttonSize)
            }
        }
        .foregroundColor(.black)
        .frame(width: buttonSize, height: buttonSize)
    }

    private func cell(value: String?) -> some View {
        ZStack {
            Rectangle()
                .stroke()
            Text(value ?? "-")
                .padding(0.1 * cellWidth)
        }.frame(width: cellWidth, height: cellHeight)
    }

    private func toggleTable() {
        withAnimation(.easeOut(duration: 0.2)) {
            showTable.toggle()
        }
    }
}

struct ConcentrationTable_Previews: PreviewProvider {
    static var previews: some View {
        ConcentrationTable(
            c1: "0.12",
            c2: "0.23",
            t1: "1.2",
            t2: "13.4",
            cellWidth: 50,
            cellHeight: 40,
            buttonSize: 25
        )
    }
}
