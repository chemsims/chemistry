//
// Reactions App
//

import SpriteKit

class SKSoluteNode: SKShapeNode {

    private let geometry: HexagonGeometry
    private let sideLength: CGFloat

    init(sideLength: CGFloat) {
        self.sideLength = sideLength
        self.geometry = HexagonGeometry(sideLength: sideLength)
        super.init()

        addParts()

        let physics = SKPhysicsBody(polygonFrom: geometry.path())
        self.physicsBody = physics
    }

    private func addParts() {
        let halfHeight = geometry.totalHeight / 2
        let center = CGPoint(x: sideLength / 2, y: halfHeight)
        let angleDelta = (60 * CGFloat.pi) / 180

        for i in 0..<7 {
            let centerAngle = CGFloat(i) * angleDelta
            let triangleRotation = CGFloat.pi - (CGFloat(i) * angleDelta)

            let dx = (halfHeight / 2) * sin(centerAngle)
            let dy = (halfHeight / 2) * cos(centerAngle)

            let node = ParticleTrianglePart(
                sideLength: sideLength,
                height: halfHeight
            )
            node.position = CGPoint(
                x: center.x + dx,
                y: center.y + dy
            )
            node.zRotation = triangleRotation
            addChild(node)
        }
    }

    func dissolve() {
        let duration: TimeInterval = 1
        self.children.forEach { child in
            if let part = child as? ParticleTrianglePart {
                part.dissolve(duration: duration)
            }
        }
        let delay = SKAction.wait(forDuration: duration)
        let remove = SKAction.removeFromParent()
        let group = SKAction.sequence([delay, remove])
        self.run(group)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ParticleTrianglePart: SKShapeNode {

    private let sideLength: CGFloat

    init(sideLength: CGFloat, height: CGFloat) {
        self.sideLength = sideLength
        super.init()
        let path = CGMutablePath()
        path.addLines(
            between: [
                CGPoint(x: -sideLength / 2, y: -(height / 2)),
                CGPoint(x: sideLength / 2, y: -(height / 2)),
                CGPoint(x: 0, y: height / 2),
            ]
        )
        let node = SKShapeNode(path: path)
        node.fillColor = .purple
        node.strokeColor = .clear
        addChild(node)
    }

    func dissolve(duration: TimeInterval) {

        let scale = SKAction.scale(by: CGFloat.random(in: 0.05...0.15), duration: duration)
        let fade = SKAction.fadeOut(withDuration: duration)
        let move = SKAction.move(by: CGVector(dx: 0, dy: -sideLength), duration: duration)
        let group = SKAction.group([scale, fade, move])
        children.forEach { $0.run(group) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct HexagonGeometry {

    let sideLength: CGFloat
    let totalHeight: CGFloat
    init(sideLength: CGFloat) {
        self.sideLength = sideLength
        self.totalHeight = 2 * sideLength * 0.866
    }

    func path() -> CGPath {
        let path = CGMutablePath()
        let dh = sideLength * 0.866 // sin(60 degrees)
        let dw = sideLength * 0.5   // cos(60 degrees)

        path.addLines(
            between: [
                CGPoint(x: 0 + dw, y: 0),
                CGPoint(x: 0 + dw + sideLength, y: 0),
                CGPoint(x: 0 + (2 * dw) + sideLength, y: 0 + dh),
                CGPoint(x: 0 + (2 * dw) + sideLength, y: 0 + dh + sideLength),
                CGPoint(x: 0 + dw + sideLength, y: 0 + (2 * dh) + sideLength),
                CGPoint(x: 0 + dw, y: 0 + (2 * dh) + sideLength),
                CGPoint(x: 0, y: 0 + dh + sideLength),
                CGPoint(x: 0, y: 0 + dh),
            ]
        )
        return path
    }
}
