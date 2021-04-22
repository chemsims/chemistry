//
// Reactions App
//


import SwiftUI


public struct MoleculeArc: Shape {

    public enum Alignment {
        case top, bottom
    }

    /// Creates a new molecule arc
    ///
    /// - Parameters:
    ///     - alignment: Alignment of the start & end y positions in the frame
    ///     - moleculeRadius: Radius of the molecule
    ///     - progress: Progress along the path, between 0 and 1
    public init(
        alignment: Alignment,
        moleculeRadius: CGFloat,
        progress: CGFloat
    ) {
        self.alignment = alignment
        self.moleculeRadius = moleculeRadius
        self.progress = progress.within(min: 0, max: 1)
    }

    let alignment: Alignment
    let moleculeRadius: CGFloat

    var progress: CGFloat

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue.within(min: 0, max: 1) }
    }

    public func path(in rect: CGRect) -> Path {
        ChartIndicatorHead(
            radius: moleculeRadius,
            equation: Self.equation,
            yAxis: AxisPositionCalculations(
                minValuePosition: rect.height - moleculeRadius,
                maxValuePosition: moleculeRadius,
                minValue: 0,
                maxValue: 1
            ),
            xAxis: AxisPositionCalculations(
                minValuePosition: moleculeRadius,
                maxValuePosition: rect.width - moleculeRadius,
                minValue: 0,
                maxValue: 1
            ),
            x: progress,
            offset: 0
        ).path(in: rect)
    }

    private static let equation = QuadraticEquation(
        parabola: CGPoint(x: 0.5, y: 1),
        through: CGPoint(x: 0, y: 0)
    )
}

struct MoleculeArc_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State var progress: CGFloat = 0

        var body: some View {
            MoleculeArc(
                alignment: .bottom,
                moleculeRadius: 20,
                progress: progress
            )
            .frame(width: 200, height: 100)
            .border(Color.red)
            .onAppear {
                let animation = Animation.easeOut(duration: 0.75).repeatForever()
                withAnimation(animation) {
                    progress = 1
                }
            }
        }

    }
}
