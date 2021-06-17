//
// Reactions App
//


import SwiftUI


extension Path {

    /// Adds a cone to the path in the given `rect`, with a curved circle at the bottom with the given `radius`.
    mutating func addCone(
        in rect: CGRect,
        radius: CGFloat
    ) {
        self.move(to: rect.origin)
        self.addConeArc(
            coneHeight: rect.height,
            coneWidth: rect.width,
            radius: radius
        )
        self.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    }

    /// Adds an arc to the path, which completes the cone of given width and height.
    mutating func addConeArc(
        coneHeight: CGFloat,
        coneWidth: CGFloat,
        radius: CGFloat
    ) {
        let start = self.currentPoint ?? .zero

        let circleCenter = CGPoint(
            x: start.x + coneWidth / 2,
            y: start.y + coneHeight - radius
        )

        let tangent =  ArcGeometry.tangentOfCircle(
            withRadius: radius,
            center: circleCenter,
            through: start
        ) .map { tangents in
            tangents.0.x < tangents.1.x ? tangents.0 : tangents.1
        }


        guard let leftTangent = tangent, leftTangent.y != start.y else {
            return
        }

        let slopeDx = leftTangent.x - start.x
        let slopeDy = leftTangent.y - start.y

        let angleOfSlopeToVertical = atan(slopeDx / slopeDy)
        let angleOfSlopeToHorizontal = (Double.pi / 2) - Double(angleOfSlopeToVertical)

        self.addArc(
            center: circleCenter,
            radius: radius,
            startAngle: .radians((Double.pi / 2) + angleOfSlopeToHorizontal),
            endAngle: .radians(Double(angleOfSlopeToVertical)),
            clockwise: true
        )
    }
}

struct ArcGeometry {
    private init() { }

    static func tangentOfCircle(
        withRadius radius: CGFloat,
        center: CGPoint,
        through point: CGPoint
    ) -> (CGPoint, CGPoint)? {
        let pointInCircleFrameOfReference = point.offset(dx: -center.x, dy: -center.y)
        let tangentPoints = tangentOfCircleAtOrigin(
            withRadius: radius,
            through: pointInCircleFrameOfReference
        )
        func inOriginalFrameOfReference(point: CGPoint) -> CGPoint {
            point.offset(dx: center.x, dy: center.y)
        }

        if let points = tangentPoints {
            return (inOriginalFrameOfReference(point: points.0), inOriginalFrameOfReference(point: points.1))
        }
        return nil
    }

    /// Returns two points along a circle where the tangent passes through `point`.
    ///
    /// The coordinate space of this method is in the frame of the circle. i.e., the center of
    /// the circle is at (0, 0)
    ///
    /// This uses the derivation found here https://sites.math.washington.edu/~conroy/m120-general/circleTangents.pdf,
    /// generalised for an arbitrary radius and `through` point.
    ///
    /// - returns: Two points along the circle whose tangent passes through `point`, if
    /// such points exist.
    static func tangentOfCircleAtOrigin(
        withRadius radius: CGFloat,
        through point: CGPoint
    ) -> (CGPoint, CGPoint)? {
        guard point.y != 0 else {
            return nil
        }

        let aTerm = pow(point.x, 2) + pow(point.y, 2)
        let bTerm = -2 * pow(radius, 2) * point.x
        let cTerm = pow(radius, 4) - pow(point.y * radius, 2)

        func pointFromX(_ x: CGFloat) -> CGPoint {
            let y = (pow(radius, 2) - (x * point.x)) / point.y
            return CGPoint(x: x, y: y)
        }

        if let xPositionRoots = QuadraticEquation.roots(a: aTerm, b: bTerm, c: cTerm) {
            return (pointFromX(xPositionRoots.0), pointFromX(xPositionRoots.1))
        }
        return nil
    }
}

struct CurvedTriangle_Previews: PreviewProvider {
    static var previews: some View {
        Path { p in
            p.addCone(in: CGRect(x: 0, y: 0, width: 100, height: 100), radius: 40)
        }
        .frame(width: 100, height: 100)
        .border(Color.black)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
