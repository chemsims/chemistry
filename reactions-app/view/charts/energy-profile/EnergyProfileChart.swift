//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {
    var body: some View {
            EnergyProfileChartShape(
                leftAsymptote: 0.5,
                peak: 0.75,
                rightAsymptote: 0.2
            )
            .stroke()
            .border(Color.black)
    }
}

struct EnergyProfileChartShape: Shape {

    let leftAsymptote: CGFloat
    var peak: CGFloat
    let rightAsymptote: CGFloat

    private let points: CGFloat = 100

    var animatableData: CGFloat {
        get { peak }
        set { peak = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        func absoluteY(absoluteX: CGFloat, asymptote: CGFloat) -> CGFloat {
            let relativeX = absoluteX / rect.size.width
            let relativeY = getRelativeY(at: relativeX, asymptote: asymptote)
            let absoluteFromTop = relativeY * rect.size.height
            return rect.size.height - absoluteFromTop
        }

        path.move(to: CGPoint(x: 0, y: absoluteY(absoluteX: 0, asymptote: leftAsymptote)))
        let dx = rect.size.width / points
        for x in stride(from: 0, through: rect.size.width / 2, by: dx) {
            let y = absoluteY(absoluteX: x, asymptote: leftAsymptote)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        for x in stride(from: rect.size.width / 2, through: rect.size.width, by: dx) {
            let y = absoluteY(absoluteX: x, asymptote: rightAsymptote)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

    private func getRelativeY(at relativeX: CGFloat, asymptote: CGFloat) -> CGFloat {
        let height = peak - asymptote
        let exponent = -1 * pow((relativeX - 0.5), 2) * 20
        return (height * pow(CGFloat(Darwin.M_E), exponent)) + asymptote
    }

}


struct EnergyProfileChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileChart()
    }
}
