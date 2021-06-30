//
// Reactions App
//


import SwiftUI

struct CircleChartLabel: View {

    let layout: Layout
    let labels: [Label]

    var body: some View {
        HStack(spacing: 0) {
//            Spacer(minLength: 0)
//                .frame(width: labelWidth / 2)
            ForEach(labels) { label in
                labelView(label)
            }
//            Spacer(minLength: 0)
//                .frame(width: labelWidth / 2)
        }
        .frame(width: layout.width)
    }

    private func labelView(_ label: Label) -> some View {
        VStack(spacing: layout.circleToTextSpacing) {
            Circle()
                .frame(square: layout.circleSize)
                .foregroundColor(label.color)

            TextLinesView(line: label.label, fontSize: layout.fontSize)
                .frame(height: layout.textHeight)
                .minimumScaleFactor(0.75)
                .animation(nil)
        }
        .frame(width: labelWidth)
    }

    private var labelWidth: CGFloat {
        guard !labels.isEmpty else {
            return 0
        }
        return layout.width / CGFloat(labels.count)
    }

    struct Label: Identifiable {
        let id: Int
        let label: TextLine
        let color: Color
    }

    struct Layout {
        let width: CGFloat
        let circleSize: CGFloat
        let textHeight: CGFloat
        let fontSize: CGFloat
        let circleToTextSpacing: CGFloat
    }
}

struct CirlceChartLabel_Previews: PreviewProvider {

    static let width: CGFloat = 300

    static var previews: some View {
        CircleChartLabel(
            layout: .init(
                width: width,
                circleSize: 20,
                textHeight: 20,
                fontSize: 20,
                circleToTextSpacing: 10
            ),
            labels: [
                .init(id: 0, label: "A", color: .red),
                .init(id: 1, label: "B", color: .blue),
                .init(id: 2, label: "C", color: .green),
            ]
        )
        .frame(width: width)
        .border(Color.red)
    }
}
