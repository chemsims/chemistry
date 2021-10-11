//
// Reactions App
//

import SwiftUI

struct PolygonEquationView: Shape {

    let points: [PointEquation]
    var progress: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()

        let resolvedPoints = points.map { pointEquation -> CGPoint in
            let fractionalPoint = pointEquation.getPoint(at: progress)
            return CGPoint(
                x: fractionalPoint.x * rect.width,
                y: fractionalPoint.y * rect.height
            )
        }

        p.addLines(resolvedPoints)
        p.closeSubpath()

        return p
    }

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}

struct PolygonEquationView_Previews: PreviewProvider {
    static var previews: some View {
        ViewAllPoints(
            points: GrowingPolygon3(
                center: CGPoint(x: 0.5, y: 0.5),
                steps: 10,
                points: 3,
                pointGrowth: 0.4..<0.8
            ).points
        )
    }

    private struct ViewAllPoints: View {
        let points: [PointEquation]
        let steps = 10

        var body: some View {
            ZStack {
                ForEach(1...steps, id: \.self) { i in
                    PolygonEquationView(
                        points: points,
                        progress: (1 / CGFloat(steps)) * CGFloat(i)
                    )
                    .stroke()
                }
            }
        }
    }

    private struct ViewWrapper: View {

        let points: [PointEquation]
        @State private var isComplete = false

        var body: some View {
            VStack {
                PolygonEquationView(
                    points: points,
                    progress: isComplete ? 1 : 0
                )

                Button(action: {
                    withAnimation(.linear(duration: 2)) {
                        isComplete.toggle()
                    }
                }) {
                    Text("toggle reaction")
                }
            }
        }
    }
}
