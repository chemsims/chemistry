//
// Reactions App
//

import SwiftUI

public struct MoleculeScales: View {

    /// A rotating with basket of molecules on the left and right, where the rotation fraction is explicitly provided
    ///
    /// - Parameters:
    ///   - rotationFraction: The rotation of the scales, between -1 and 1. A value of 1 corresponds to a maximum
    ///   clockwise rotation, and -1 corresponds to a maximum anti clockwise rotation.
    ///   - scalesAccessibilityLabel: Accessibility label of the scales as a whole. Overriding the label
    ///   should not be done by calling the `accessibility(label:)`, as the view provides labels for specific
    ///   parts of the scales - the arm, and each basket. This property is placed on the arm, and it's value is the
    ///   rotation.
    public init(
        leftMolecules: MoleculeScales.Molecules,
        rightMolecules: MoleculeScales.Molecules,
        rotationFraction: Equation,
        equationInput: CGFloat,
        badge: Badge? = nil,
        cols: Int,
        rows: Int,
        scalesAccessibilityLabel: String = Self.scalesAccessibilityLabel
    ) {
        self.leftMolecules = leftMolecules
        self.rightMolecules = rightMolecules
        self.rotationFraction = rotationFraction
        self.equationInput = equationInput
        self.badge = badge
        self.cols = cols
        self.rows = rows
        self.scalesAccessibilityLabel = scalesAccessibilityLabel
    }

    let leftMolecules: Molecules
    let rightMolecules: Molecules
    let rotationFraction: Equation
    let equationInput: CGFloat
    let badge: Badge?
    let cols: Int
    let rows: Int
    let scalesAccessibilityLabel: String

    public var body: some View {
        GeometryReader { geo in
            SizedMoleculeScales(
                leftMolecules: leftMolecules,
                rightMolecules: rightMolecules,
                rotationFraction: rotationFraction,
                equationInput: equationInput,
                badge: badge,
                cols: cols,
                rows: rows,
                scalesAccessibilityLabel: scalesAccessibilityLabel,
                settings: MoleculeScalesGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }

    public enum Molecules {
        case single(concentration: MoleculeEquation)
        case double(left: MoleculeEquation, right: MoleculeEquation)
    }

    public struct MoleculeEquation {
        public init(fractionToDraw: Equation, color: Color, label: String) {
            self.fractionToDraw = fractionToDraw
            self.color = color
            self.label = label
        }

        let fractionToDraw: Equation
        let color: Color
        let label: String
    }

    public struct Badge {
        public init(
            label: String,
            fontColor: Color,
            backgroundColor: Color
        ) {
            self.label = label
            self.fontColor = fontColor
            self.backgroundColor = backgroundColor
        }
        let label: String
        let fontColor: Color
        let backgroundColor: Color
    }
}

extension MoleculeScales {
    public static func gridCoords(cols: Int, rows: Int) -> [GridCoordinate] {
        let maxRows = min(rows, cols)
        return (0..<maxRows).flatMap { row in
            (0..<(cols - row)).map { col in
                GridCoordinate(col: col, row: row)
            }
        }
    }

    static func rotationEquation(
        leftMolecules: MoleculeScales.Molecules,
        rightMolecules: MoleculeScales.Molecules
    ) -> Equation {
        rightMolecules.combinedConcentration - leftMolecules.combinedConcentration
    }
}

private extension MoleculeScales.Molecules {
    var combinedConcentration: Equation {
        switch self {
        case let .single(concentration): return concentration.fractionToDraw
        case let .double(left, right): return left.fractionToDraw + right.fractionToDraw
        }
    }
}

private struct SizedMoleculeScales: View {

    let leftMolecules: MoleculeScales.Molecules
    let rightMolecules: MoleculeScales.Molecules
    let rotationFraction: Equation
    let equationInput: CGFloat
    let badge: MoleculeScales.Badge?
    let cols: Int
    let rows: Int
    let scalesAccessibilityLabel: String
    let settings: MoleculeScalesGeometry

    var body: some View {
        ZStack {
            arm
                .accessibility(sortPriority: 3)

            stand

            leftBasket
                .accessibility(sortPriority: 2)

            rightBasket
                .accessibility(sortPriority: 1)

            if let badge = badge {
                badgeView(badge)
            }
        }
        .frame(width: settings.width)
        .accessibilityElement(children: .contain)
    }

    private var stand: some View {
        Image("scales-stand", bundle: .reactionsCore)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibility(hidden: true)
    }

    private var rotationDegrees: Equation {
        settings.maxRotationAngle * rotationFraction
    }
}

// MARK: Badge
private extension SizedMoleculeScales {
    private func badgeView(_ badge: MoleculeScales.Badge) -> some View {
        ZStack {
            Circle()
                .foregroundColor(badge.backgroundColor)
            Circle()
                .stroke()
                .foregroundColor(Styling.scalesBadgeOutline)
            Text(badge.label)
                .font(.system(size: settings.badgeFontSize))
                .foregroundColor(badge.fontColor)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
        }
        .frame(square: settings.badgeSize)
        .position(settings.rotationCenter)
        .accessibility(hidden: true)
    }
}

// MARK: Baskets
private extension SizedMoleculeScales {

    private var leftBasket: some View {
        basket(
            isLeft: true,
            molecules: leftMolecules
        )
    }

    private var rightBasket: some View {
        basket(
            isLeft: false,
            molecules: rightMolecules
        )
    }

    private func basket(
        isLeft: Bool,
        molecules: MoleculeScales.Molecules
    ) -> some View {
        MoleculeScaleBasket(
            molecules: molecules,
            equationInput: equationInput,
            cols: cols,
            rows: rows
        )
        .frame(
            width: settings.basketWidth,
            height: settings.basketHeight
        )
        .offset(y: settings.basketYOffset)
        .animatablePosition(
            equation: BasketPositionEquation(
                rotationDegrees: rotationDegrees,
                rotationCenter: settings.rotationCenter,
                armWidth: isLeft ? settings.armWidth / 2 : -settings.armWidth / 2
            ),
            input: equationInput
        )
        .accessibility(
            label: Text(basketLabel(side: isLeft ? "left" : "right", molecules: molecules))
        )
    }

    private func basketLabel(
        side: String,
        molecules: MoleculeScales.Molecules
    ) -> String {
        switch molecules {
        case let .single(concentration):
            return "\(side) basket showing molecules of \(concentration.label)"
        case let .double(left, right):
            return "\(side) basket showing molecules of \(left.label) and \(right.label)"
        }
    }
}

extension MoleculeScales {
    public static let scalesAccessibilityLabel =
        "Scales with a basket of molecules on the left and right"
}

private struct BasketPositionEquation: PointEquation {

    let rotationDegrees: Equation
    let rotationCenter: CGPoint
    let armWidth: CGFloat

    func getPoint(at progress: CGFloat) -> CGPoint {
        let rotation = rotationDegrees.getValue(at: progress)
        let rads = Angle(degrees: Double(rotation)).radians

        let dy = armWidth * CGFloat(sin(rads))
        let dx = armWidth * CGFloat(cos(rads))

        return CGPoint(
            x: rotationCenter.x - dx,
            y: rotationCenter.y - dy
        )
    }
}

// MARK: Arm
private extension SizedMoleculeScales {

    private var arm: some View {
        Rectangle()
            .frame(
                width: settings.armWidth,
                height: MoleculeScalesGeometry.lineWidth
            )
            .animatableRotation(
                degreesRotation: rotationDegrees,
                currentTime: equationInput
            )
            .position(settings.rotationCenter)
            .foregroundColor(Styling.scalesBody)
            .accessibility(label: Text(scalesAccessibilityLabel))
            .updatingAccessibilityValue(x: equationInput, format: getRotationLabel)
    }

    private func getRotationLabel(at input: CGFloat) -> String {
        let rotation = rotationDegrees.getValue(at: input)
        let roundedRotation = rotation.rounded(decimals: 2)
        var end: String {
            if roundedRotation > 0 {
                return " clockwise"
            } else if roundedRotation < 0 {
                return " anti-clockwise"
            }
            return ""
        }

        return "Rotation is \(abs(rotation).str(decimals: 0)) degrees\(end)"
    }
}

struct MoleculeScales_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {

        @State private var hasEnded = false

        var body: some View {
            VStack {
                MoleculeScales(
                    leftMolecules: .single(
                        concentration: .init(
                            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0),
                            color: .red,
                            label: "A"
                        )
                    ),
                    rightMolecules: .single(
                        concentration: .init(
                            fractionToDraw: LinearEquation(m: -1, x1: 0, y1: 1),
                            color: .purple,
                            label: "B"
                        )
                    ),
                    rotationFraction: LinearEquation(m: 2, x1: 0, y1: -1),
                    equationInput: hasEnded ? 0 : 1,
                    badge: .init(
                        label: "C",
                        fontColor: .white,
                        backgroundColor: .purple
                    ),
                    cols: 4,
                    rows: 4
                )
                .frame(width: 380, height: 250)

                Button(action: {
                    withAnimation(.linear(duration: 2)) {
                        hasEnded.toggle()
                    }
                }) {
                    Text("Rotate")
                }
            }
        }
    }
}
