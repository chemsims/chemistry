//
// Reactions App
//


import SwiftUI


public struct MoleculeArc: Shape {

    public enum Alignment {
        case top, bottom
    }

    /// Supported number of final molecules
    public enum Count {
        case one, two, three

        var number: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            }
        }
    }

    /// Creates a new molecule arc
    ///
    /// - Parameters:
    ///     - alignment: Alignment of the start & end y positions in the frame
    ///     - finalCount: Number of molecules in the final state
    ///     - finalRotation: Rotation of the molecules in the final state
    ///     - moleculeRadius: Radius of the molecule
    ///     - progress: Progress along the path, between 0 and 1
    public init(
        alignment: Alignment,
        finalCount: Count,
        finalRotation: Angle,
        moleculeRadius: CGFloat,
        progress: CGFloat
    ) {
        self.alignment = alignment
        self.finalCount = finalCount
        self.finalRotation = finalRotation
        self.moleculeRadius = moleculeRadius
        self.progress = progress.within(min: 0, max: 1)
    }

    let alignment: Alignment
    let finalCount: Count
    let finalRotation: Angle
    let moleculeRadius: CGFloat

    var progress: CGFloat

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue.within(min: 0, max: 1) }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = progress * rect.width
        let y = AxisPositionCalculations(
            minValuePosition: rect.height,
            maxValuePosition: 0,
            minValue: 0,
            maxValue: 1
        ).getPosition(at: Self.equation.getY(at: progress))

        addMolecules(at: CGPoint(x: x, y: y), path: &path)
        return path
    }

    private func addMolecules(at center: CGPoint, path: inout Path) {
        for i in 0..<finalCount.number {
            let offset = getScaledOffset(forIndex: i)
            let rotatedOffset = offset.rotate(
                by: CGFloat(finalRotation.radians) * progress
            )

            let position = center.offset(dx: rotatedOffset.width, dy: rotatedOffset.height)
            let rect = CGRect(
                x: position.x - moleculeRadius,
                y: position.y - moleculeRadius,
                width: 2 * moleculeRadius,
                height: 2 * moleculeRadius
            )

            path.addEllipse(in: rect)
        }
    }

    private func getScaledOffset(forIndex index: Int) -> CGSize {
        let maxOffset = getMaxOffset(forIndex: index)
        return CGSize(
            width: maxOffset.width * progress,
            height: maxOffset.height * progress
        )
    }

    private func getMaxOffset(forIndex index: Int) -> CGSize {
        switch finalCount {
        case .one: return .zero
        case .two: return offsetForCountOfTwo(forIndex: index)
        case .three: return offsetForCountOfThree(forIndex: index)
        }
    }

    private static let equation = QuadraticEquation(
        parabola: CGPoint(x: 0.5, y: 1),
        through: CGPoint(x: 0, y: 0)
    )
}

// MARK: Offset for 2 molecules
private extension MoleculeArc {
    private func offsetForCountOfTwo(forIndex index: Int) -> CGSize {
        let delta = moleculeRadius
        let width = index == 0 ? -delta : delta
        return CGSize(width: width, height: 0)
    }
}

// MARK: Offset for 3 molecules
private extension MoleculeArc {
    private func offsetForCountOfThree(forIndex index: Int) -> CGSize {
        let distanceFromCenter = moleculeRadius * Self.sqrt2
        let rowHeight = moleculeRadius * Self.sqrt3

        let bottomRowHeightOffset = distanceFromCenter * Self.sin45
        let topRowHeightOffset = -(rowHeight - bottomRowHeightOffset)

        // Top
        if index == 0 {
            return CGSize(width: 0, height: topRowHeightOffset)

            // Bottom right
        } else if index == 1 {
            return CGSize(width: moleculeRadius, height: bottomRowHeightOffset)
        }

        // Bottom left
        return CGSize(width: -moleculeRadius, height: bottomRowHeightOffset)
    }

    private static let sin45 = sin(CGFloat(Angle.degrees(45).radians))
    private static let sqrt2: CGFloat = sqrt(2)
    private static let sqrt3: CGFloat = sqrt(3)

}

private extension CGSize {
    func rotate(by angle: CGFloat) -> CGSize {
        let rotatedWidth = (cos(angle) * width) - (sin(angle) * height)
        let rotatedHeight = (sin(angle) * width) + (cos(angle) * height)
        return CGSize(width: rotatedWidth, height: rotatedHeight)
    }
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
                finalCount: .three,
                finalRotation: .degrees(225),
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
