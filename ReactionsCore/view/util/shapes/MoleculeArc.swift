//
// Reactions App
//


import SwiftUI


public struct MoleculeArc: Shape {

    /// Creates a new molecule arc
    ///
    /// - Parameters:
    ///     - verticalAlignment: Alignment of the start & end y positions
    ///     - horizontalAlignment:Alignment of the start & end x positions
    ///     - startState: Molecule state at start position
    ///     - endState: Molecule state at end position
    ///     - apexXLocation: Position of the curve apex as a fraction of the width, between 0 and 1
    ///     - moleculeRadius: Radius of the molecule
    ///     - startProgress: The progress at which to start the motion
    ///     - endProgress: The progress at which to end the motion
    ///     - progress: Progress along the path, between 0 and 1
    public init(
        verticalAlignment: VerticalAlignment,
        horizontalAlignment: HorizontalAlignment,
        startState: MoleculeArcState,
        endState: MoleculeArcState,
        apexXLocation: CGFloat,
        apexCount: Count?,
        moleculeRadius: CGFloat,
        startProgress: CGFloat,
        endProgress: CGFloat,
        progress: CGFloat
    ) {
        self.vAlignment = verticalAlignment
        self.hAlignment = horizontalAlignment
        self.startState = startState
        self.endState = endState
        self.apexCount = apexCount
        self.moleculeRadius = moleculeRadius
        self.startProgress = startProgress
        self.endProgress = endProgress
        self.progress = progress.within(min: 0, max: 1)

        let adjustedApexX = horizontalAlignment == .leading ? apexXLocation : 1 - apexXLocation

        // This is an equation for the y position as a function of the x position
        self.yEquation = SwitchingEquation(
            thresholdX: adjustedApexX,
            underlyingLeft: QuadraticEquation(
                parabola: CGPoint(x: adjustedApexX, y: 1),
                through: .zero
            ),
            underlyingRight: QuadraticEquation(
                parabola: CGPoint(x: adjustedApexX, y: 1),
                through: CGPoint(x: 1, y: 0)
            )
        )

        // This is an equation for the x position as a function of the progress
        // So the 'x' term in the equation refers to the progress in this context,
        // while the 'y' term is the output, which is the x position (as a fraction)
        self.xEquation = SwitchingEquation(
            thresholdX: 0.5,
            underlyingLeft: QuadraticEquation(
                parabola: CGPoint(x: 0.5, y: adjustedApexX),
                through: .zero
            ),
            underlyingRight: QuadraticEquation(
                parabola: CGPoint(x: 0.5, y: adjustedApexX),
                through: CGPoint(x: 1, y: 1)
            )
        )
    }

    let vAlignment: VerticalAlignment
    let hAlignment: HorizontalAlignment
    let startState: MoleculeArcState
    let endState: MoleculeArcState
    let apexCount: Count?
    let moleculeRadius: CGFloat
    let startProgress: CGFloat
    let endProgress: CGFloat

    var progress: CGFloat

    private let yEquation: Equation
    private let xEquation: Equation

    public var animatableData: CGFloat {
        get { progress }
        set {
            progress = LinearEquation(
                x1: startProgress,
                y1: 0,
                x2: endProgress,
                y2: 1
            ).within(min: 0, max: 1).getY(at: newValue)
        }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let xFraction = xEquation.getY(at: progress)
        let x = AxisPositionCalculations(
            minValuePosition: hAlignment == .leading ? 0 : rect.width,
            maxValuePosition: hAlignment == .leading ? rect.width : 0,
            minValue: 0,
            maxValue: 1
        ).getPosition(at: xFraction)

        let yFraction = yEquation.getY(at: xFraction)
        let y = AxisPositionCalculations<CGFloat>(
            minValuePosition: vAlignment == .bottom ? rect.height : 0,
            maxValuePosition: vAlignment == .bottom ? 0 : rect.height,
            minValue: 0,
            maxValue: 1
        ).getPosition(at: yFraction)

        addMolecules(at: CGPoint(x: x, y: y), path: &path)
        return path
    }

    private func addMolecules(at center: CGPoint, path: inout Path) {
        let counts = [startState.count.number, endState.count.number, apexCount?.number ?? 0]
        let rotation = getScaledRotation()
        for i in 0..<counts.max()! {
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
        if let apexCount = apexCount {
            if progress < 0.5 {
                return getInterpolatedOffset(
                    moleculeIndex: index,
                    startCount: startState.count,
                    endCount: apexCount,
                    fraction: 2 * progress
                )
            }
            return getInterpolatedOffset(
                moleculeIndex: index,
                startCount: apexCount,
                endCount: endState.count,
                fraction: 2 * (progress - 0.5)
            )
        }
        return getInterpolatedOffset(
            moleculeIndex: index,
            startCount: startState.count,
            endCount: endState.count,
            fraction: progress
        )
    }

    private func getInterpolatedOffset(
        moleculeIndex: Int,
        startCount: Count,
        endCount: Count,
        fraction: CGFloat
    ) -> CGSize {
        let startOffset =
            getMaxOffset(forIndex: moleculeIndex, count: startCount)
        let endOffset =
            getMaxOffset(forIndex: moleculeIndex, count: endCount)
        let deltaOffset = endOffset - startOffset
        return startOffset + deltaOffset.scale(by: fraction)
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
}

//MARK: Enums

extension MoleculeArc {
    public enum VerticalAlignment {
        case top, bottom
    }

    public enum HorizontalAlignment {
        case leading, trailing
    }

    /// Supported number of final molecules
    public enum Count: CaseIterable {
        case one, two, three, four

        public var number: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            }
        }

        public static func fromNumber(_ number: Int) -> Count? {
            switch number {
            case 1: return .one
            case 2: return .two
            case 3: return .three
            case 4: return .four
            default: return nil
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
        VStack(spacing: 50) {
            ViewWrapper(vAlignment: .bottom, hAlignment: .leading)
            ViewWrapper(vAlignment: .top, hAlignment: .trailing)
        }
    }

    struct ViewWrapper: View {

        let vAlignment: MoleculeArc.VerticalAlignment
        let hAlignment: MoleculeArc.HorizontalAlignment

        @State var progress: CGFloat = 0

        var body: some View {
            MoleculeArc(
                verticalAlignment: vAlignment,
                horizontalAlignment: hAlignment,
                startState: MoleculeArcState(count: .three, rotation: .degrees(20)),
                endState: MoleculeArcState(count: .two, rotation: .degrees(-45)),
                apexXLocation: 0.3,
                apexCount: .four,
                moleculeRadius: 15,
                startProgress: 0.15,
                endProgress: 0.9,
                progress: progress
            )
            .frame(width: 200, height: 100)
            .border(Color.red)
            .onAppear {
                let animation = Animation.easeOut(duration: 2).repeatForever(autoreverses: false)
                withAnimation(animation) {
                    progress = 1
                }
            }
        }
    }
}
