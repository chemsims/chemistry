//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ConcentrationTable: View {

    let c1: String?
    let c2: String?
    let t1: String?
    let t2: String?

    let rate1: String?
    let rate2: String?

    let showTime: Bool
    let showRate: Bool

    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let buttonSize: CGFloat
    let highlighted: Bool

    @State private var showTable = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            button
            Group {
                HStack(spacing: 0) {
                    cell(value: "c")
                        .accessibility(hidden: true)
                    cell(value: c1)
                        .accessibility(label: Text("c1"))
                        .accessibility(value: Text(c1 ?? "no value"))
                    cell(value: c2)
                        .accessibility(label: Text("c2"))
                        .accessibility(value: Text(c2 ?? "no value"))
                }
                if showTime {
                    HStack(spacing: 0) {
                        cell(value: "t")
                            .accessibility(hidden: true)
                        cell(value: t1)
                            .accessibility(label: Text("t1"))
                            .accessibility(value: Text(t1 ?? "no value"))
                        cell(value: t2)
                            .accessibility(label: Text("t2"))
                            .accessibility(value: Text(t2 ?? "no value"))
                    }
                }

                if showRate {
                    HStack(spacing: 0) {
                        cell(value: "Rate")
                            .accessibility(hidden: true)
                        cell(value: rate1)
                            .accessibility(label: Text("rate at c1"))
                            .accessibility(value: Text(rate1 ?? "no value"))
                        cell(value: rate2)
                            .accessibility(label: Text("rate at c2"))
                            .accessibility(value: Text(rate2 ?? "no value"))
                    }
                }
            }
            .scaleEffect(y: showTable ? 1 : 0, anchor: .top)
            .accessibility(hidden: !showTable)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .accessibilityElement(children: .contain)
    }

    private var button: some View {
        Button(action: toggleTable) {
            ZStack {
                rectWithStroke
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(0.2 * buttonSize)
                    .rotationEffect(showTable ? .degrees(135) : .zero)
            }
            .accessibilityElement(children: .ignore)
//            .accessibility(label: Text("\(showTable ? "hide" : "show") concentration table"))
        }
        .foregroundColor(.black)
        .frame(width: buttonSize, height: buttonSize)
//        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("\(showTable ? "hide" : "show") concentration table"))
    }

    private func cell(value: String?) -> some View {
        ZStack {
            rectWithStroke
            Text(value ?? "-")
                .padding(0.1 * cellWidth)
        }.frame(width: cellWidth, height: cellHeight)
    }

    private var rectWithStroke: some View {
        ZStack {
            if highlighted {
                Rectangle()
                    .foregroundColor(.white)
            }
            Rectangle()
                .stroke()
        }
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
            rate1: "0.05",
            rate2: "0.08",
            showTime: false,
            showRate: true,
            cellWidth: 50,
            cellHeight: 40,
            buttonSize: 25,
            highlighted: true
        ).background(Styling.inactiveScreenElement)
    }
}
