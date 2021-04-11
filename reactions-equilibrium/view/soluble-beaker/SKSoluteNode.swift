//
// Reactions App
//

import SpriteKit
import SwiftUI

class SKSoluteNode: SKShapeNode {

    private let geometry: HexagonGeometry
    private let sideLength: CGFloat
    let soluteType: SoluteType

    var hasEnteredWater = false
    var willDissolve = false
    var willHide = false

    init(sideLength: CGFloat, soluteType: SoluteType) {
        self.sideLength = sideLength
        self.geometry = HexagonGeometry(sideLength: sideLength)
        self.soluteType = soluteType
        super.init()

        addParts()

        let physics = SKPhysicsBody(polygonFrom: geometry.path())
        self.physicsBody = physics
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func copyNode() -> SKSoluteNode {
        let newCopy = SKSoluteNode(sideLength: sideLength, soluteType: soluteType)
        newCopy.hasEnteredWater = hasEnteredWater
        newCopy.willDissolve = willDissolve
        newCopy.position = position
        newCopy.fillColor = fillColor
        if let physics = physicsBody?.copy() as? SKPhysicsBody {
            newCopy.physicsBody = physics
        }
        return newCopy
    }

    private func addParts() {
        let halfHeight = geometry.totalHeight / 2
        let center = CGPoint(x: sideLength, y: halfHeight)
        let angleDelta = (60 * CGFloat.pi) / 180

        for i in 0..<7 {
            let centerAngle = CGFloat(i) * angleDelta
            let triangleRotation = CGFloat.pi - (CGFloat(i) * angleDelta)

            let dx = (halfHeight / 2) * sin(centerAngle)
            let dy = (halfHeight / 2) * cos(centerAngle)

            let node = ParticleTrianglePart(
                sideLength: sideLength,
                height: halfHeight,
                fillColor: soluteType.color.uiColor
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
        self.physicsBody?.collisionBitMask = 0
        self.run(group)
    }

    func hide() {
        self.isHidden = true
        self.physicsBody?.isDynamic = false
        self.physicsBody?.collisionBitMask = 0
    }

    func show() {
        self.isHidden = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.collisionBitMask = UInt32.max
    }
}

private class ParticleTrianglePart: SKShapeNode {

    private let sideLength: CGFloat

    init(sideLength: CGFloat, height: CGFloat, fillColor: UIColor) {
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
        node.fillColor = fillColor
        node.strokeColor = .clear
        addChild(node)
    }

    func dissolve(duration: TimeInterval) {
        let scale = SKAction.scale(by: CGFloat.random(in: 0.05...0.15), duration: duration)
        let fade = SKAction.fadeOut(withDuration: duration)
        let move = SKAction.move(by: CGVector(dx: 0, dy: -sideLength), duration: duration)

        let maxRotation = 2 * CGFloat.pi
        let rotation = CGFloat.random(in: -maxRotation...maxRotation)
        let rotate = SKAction.rotate(byAngle: rotation, duration: duration)

        let group = SKAction.group([scale, fade, move, rotate])
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
        let dx = sideLength * 0.5 // cos(60)

        path.addLines(
            between: [
                CGPoint(x: 0, y: totalHeight / 2),  // Center left
                CGPoint(x: dx, y: 0),               // Bottom left
                CGPoint(x: dx + sideLength, y: 0),  // Bottom right
                CGPoint(x: (2 * dx) + sideLength, y: totalHeight / 2), // Center right
                CGPoint(x: dx + sideLength, y: totalHeight), // Top right
                CGPoint(x: dx, y: totalHeight)               // Top left
            ]
        )
        return path
    }
}


struct SKSoluteNode_Previews: PreviewProvider {
    static var previews: some View {
        NodeRepresentable()
            .frame(width: NodeRepresentable.sceneSize, height: NodeRepresentable.sceneSize)
            .border(Color.red)
    }

    struct NodeRepresentable: UIViewRepresentable {
        typealias UIView = SKView

        func makeUIView(context: Context) -> SKView {
            let view = SKView()
            view.allowsTransparency = true
            let scene = SKScene(size: CGSize(width: Self.sceneSize, height: Self.sceneSize))
            scene.backgroundColor = .clear
            view.presentScene(scene)
            let node = SKSoluteNode(sideLength: Self.sideLength, soluteType: .primary)
            node.position = CGPoint(
                x: (Self.sceneSize / 2) - Self.sideLength,
                y: (Self.sceneSize / 2) - Self.sideLength
            )
            scene.addChild(node)
            return view
        }

        func updateUIView(_ uiView: SKView, context: Context) {

        }

        static let sideLength: CGFloat = 20
        static let sceneSize: CGFloat = 100
    }
}
