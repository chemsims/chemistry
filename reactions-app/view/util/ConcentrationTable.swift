//
// Reactions App
//
  

import SwiftUI

struct ConcentrationTable: View {

    let c1: String?
    let c2: String?
    let t1: String?
    let t2: String?

    let rate: Equation?
    let currentTime: CGFloat?

    let showTime: Bool
    let showRate: Bool

    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let buttonSize: CGFloat

    @State private var showTable = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            button
            Group {
                HStack(spacing: 0) {
                    cell(value: "c")
                    cell(value: c1)
                    cell(value: c2)
                }
                if (showTime) {
                    HStack(spacing: 0) {
                        cell(value: "t")
                        cell(value: t1)
                        cell(value: t2)
                    }
                }

                if (showRate) {
                    HStack(spacing: 0) {
                        cell(value: "rate")
                        rateCell
                    }
                }
            }
            .scaleEffect(y: showTable ? 1 : 0, anchor: .top)
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
                    .rotationEffect(showTable ? .degrees(135) : .zero)
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

    private var rateCell: some View {
        ZStack {
            Rectangle()
                .stroke()
            if (rate != nil && currentTime != nil) {
                AnimatingNumber(
                    x: currentTime!,
                    equation: rate!,
                    formatter: {$0.str(decimals: 3)}
                )
                .padding(0.1 * cellWidth)
            } else {
                Text("-")
                    .padding(0.1 * cellWidth)
            }
        }.frame(width: 2 * cellWidth, height: cellHeight)

    }

    private func toggleTable() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
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
            rate: ConstantEquation(value: 0.1),
            currentTime: 0.1,
            showTime: false,
            showRate: true,
            cellWidth: 50,
            cellHeight: 40,
            buttonSize: 25
        )
    }
}
