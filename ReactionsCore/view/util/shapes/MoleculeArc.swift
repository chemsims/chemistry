//
// Reactions App
//


import SwiftUI


public struct MoleculeArc: Shape {

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
        startState: MoleculeArcState,
        endState: MoleculeArcState,
        moleculeRadius: CGFloat,
        progress: CGFloat
    ) {
        self.alignment = alignment
        self.startState = startState
        self.endState = endState
        self.moleculeRadius = moleculeRadius
        self.progress = progress.within(min: 0, max: 1)
    }

    let alignment: Alignment
    let startState: MoleculeArcState
    let endState: MoleculeArcState
    let moleculeRadius: CGFloat

    var progress: CGFloat

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue.within(min: 0, max: 1) }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = progress * rect.width
        let y = rect.height - (Self.equation.getY(at: progress) * rect.height)
        addMolecules(at: CGPoint(x: x, y: y), path: &path)
        return path
    }

    private func addMolecules(at center: CGPoint, path: inout Path) {
        let maxCount = max(startState.count.number, endState.count.number)
        let rotation = getScaledRotation()
        for i in 0..<maxCount {
            let offset = getScaledOffset(forIndex: i)
            let rotatedOffset = offset.rotate(by: rotation)

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

    private func getScaledRotation() -> CGFloat {
        let startRotation = CGFloat(startState.rotation.radians)
        let endRotation = CGFloat(endState.rotation.radians)

        let delta = endRotation - startRotation
        return startRotation + (delta * progress)
    }

    private func getScaledOffset(forIndex index: Int) -> CGSize {
        let startOffset = getMaxOffset(forIndex: index, count: startState.count)
        let endOffset = getMaxOffset(forIndex: index, count: endState.count)
        let deltaOffset = endOffset - startOffset
        return startOffset + deltaOffset.scale(by: progress)
    }

    private func getMaxOffset(
        forIndex index: Int,
        count: Count
    ) -> CGSize {
        switch count {
        case .one: return .zero
        case .two: return offsetForCountOfTwo(forIndex: index)
        case .three: return offsetForCountOfThree(forIndex: index)
        case .four: return offsetForCountOfFour(forIndex: index)
        }
    }

    private static let equation = QuadraticEquation(
        parabola: CGPoint(x: 0.5, y: 1),
        through: CGPoint(x: 0, y: 0)
    )

    //MARK: Enums
    public enum Alignment {
        case top, bottom
    }

    /// Supported number of final molecules
    public enum Count {
        case one, two, three, four

        var number: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            }
        }
    }
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

private extension MoleculeArc {
    private func offsetForCountOfFour(forIndex index: Int) -> CGSize {
        switch index {
        case 0: return CGSize(width: moleculeRadius, height: moleculeRadius)
        case 1: return CGSize(width: moleculeRadius, height: -moleculeRadius)
        case 2: return CGSize(width: -moleculeRadius, height: -moleculeRadius)
        default: return CGSize(width: -moleculeRadius, height: moleculeRadius)
        }
    }
}

public struct MoleculeArcState {
    public init(count: MoleculeArc.Count, rotation: Angle) {
        self.count = count
        self.rotation = rotation
    }

    let count: MoleculeArc.Count
    let rotation: Angle
}

private extension CGSize {
    func rotate(by angle: CGFloat) -> CGSize {
        let rotatedWidth = (cos(angle) * width) - (sin(angle) * height)
        let rotatedHeight = (sin(angle) * width) + (cos(angle) * height)
        return CGSize(width: rotatedWidth, height: rotatedHeight)
    }

    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    func scale(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
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
                startState: MoleculeArcState(count: .three, rotation: .degrees(20)),
                endState: MoleculeArcState(count: .four, rotation: .degrees(-45)),
                moleculeRadius: 15,
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
