//
// Reactions App
//

import SpriteKit

class SolidParticleNode: SKShapeNode {

    init(sideLength: CGFloat) {
        super.init()

        let height = sideLength * 0.866
        let center = CGPoint(x: sideLength / 2, y: height)
        var angleRad: CGFloat = 0
        var triangleRotation = CGFloat.pi
        let angleDelta = (60 * CGFloat.pi) / 180
        for _ in 0..<7 {
            let dx = (height / 2) * sin(angleRad)
            let dy = (height / 2) * cos(angleRad)
            let node = ParticleTrianglePart(
                sideLength: sideLength,
                height: height
            )
            node.position = CGPoint(
                x: center.x + dx,
                y: center.y + dy
            )
            node.zRotation = triangleRotation
            angleRad += angleDelta
            triangleRotation -= angleDelta
            addChild(node)
        }
    }

    func dissolve() {
        self.children.forEach { child in
            if let elem = child as? ParticleTrianglePart {
                elem.dissolve()
            }
        }
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

    func dissolve() {
        let scale = SKAction.scale(by: CGFloat.random(in: 0.05...0.15), duration: 1)
        let fade = SKAction.fadeOut(withDuration: 1)
        let move = SKAction.move(by: CGVector(dx: 0, dy: -sideLength), duration: 1)
        let group = SKAction.group([scale, fade, move])
        children.forEach { $0.run(group) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
