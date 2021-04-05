//
// Reactions App
//

import SpriteKit
import SwiftUI

struct SolubleBeakerSceneRepresentable: UIViewRepresentable {
    typealias UIView = SKView

    let size: CGSize
    let particlePosition: CGPoint
    let soluteWidth: CGFloat
    let waterHeight: CGFloat
    let canEmit: Bool
    let onEmit: () -> Void
    let onDissolve: () -> Void
    @Binding var shouldAddParticle: Bool

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = SKSolubleBeakerScene(
            size: size,
            soluteWidth: soluteWidth,
            waterHeight: waterHeight,
            onDissolve: onDissolve
        )
        scene.scaleMode = .aspectFit
        view.allowsTransparency = true
        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? SKSolubleBeakerScene {
            if shouldAddParticle && canEmit {
                scene.addParticle(at: particlePosition)
                onEmit()
                shouldAddParticle = false
            }
            scene.soluteWidth = soluteWidth
            scene.waterHeight = waterHeight
            scene.onDissolve = onDissolve
        }
    }
}

class SKSolubleBeakerScene: SKScene {

    var soluteWidth: CGFloat
    var waterHeight: CGFloat
    var onDissolve: () -> Void

    init(
        size: CGSize,
        soluteWidth: CGFloat,
        waterHeight: CGFloat,
        onDissolve: @escaping () -> Void
    ) {
        self.soluteWidth = soluteWidth
        self.waterHeight = waterHeight
        self.onDissolve = onDissolve
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = .clear
    }

    func addParticle(at position: CGPoint) {
        let sideLength = soluteWidth / 2
        let node = SKSoluteNode(sideLength: sideLength)
        node.position = position.offset(dx: -sideLength, dy: 0)

        addChild(node)

        node.physicsBody?.applyTorque(CGFloat.random(in: -0.01...0.01))

        let action = SKAction.run {
            node.dissolve()
            self.onDissolve()
        }
        let delay = SKAction.wait(forDuration: 2)
        self.run(SKAction.sequence([delay, action]))
    }

    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if let solute = child as? SKSoluteNode, let physics = solute.physicsBody {
                if solute.position.y < waterHeight {
                    physics.linearDamping = 50
                    physics.angularDamping = 1
                }
            }
        }
    }

    private func demoJoinedNodesAndMagneticField() {
        func addNode() {
            let radius: CGFloat = 10

            let x0: CGFloat = CGFloat.random(in: 0..<size.width)
            let y0: CGFloat = CGFloat.random(in: 0..<size.height)

            let node1 = SKShapeNode(circleOfRadius: radius)
            let physics1 = SKPhysicsBody(circleOfRadius: radius)
            physics1.charge = 1
            physics1.affectedByGravity = false
            node1.physicsBody = physics1
            node1.fillColor = .purple

            let node2 = SKShapeNode(circleOfRadius: radius)
            let physics2 = SKPhysicsBody(circleOfRadius: radius)
            physics2.charge = -1
            physics2.affectedByGravity = false
            node2.physicsBody = physics2
            node2.fillColor = .blue

            node1.position = CGPoint(x: x0, y: y0)
            node2.position = CGPoint(x: x0 + (3 * radius), y: y0)

            let joint = SKPhysicsJointFixed.joint(
                withBodyA: physics1,
                bodyB: physics2,
                anchor: CGPoint(x: x0 + (2.5 * radius), y: y0 + (0.5 * radius))
            )

            self.addChild(node1)
            self.addChild(node2)
            self.physicsWorld.add(joint)

            let mag = 1
            physics1.applyImpulse(CGVector(dx: mag, dy: mag))
        }


        let magneticField = SKFieldNode.magneticField()
        magneticField.strength = 0.2
        self.addChild(magneticField)


        (0...10).forEach { _ in addNode() }
    }

    private func demoElectricField() {
        let electricField = SKFieldNode.electricField()
        self.addChild(electricField)

        func addNode(_ color: UIColor, _ charge: CGFloat) {
            let radius: CGFloat = 10
            let node = SKShapeNode(circleOfRadius: radius)
            let physics = SKPhysicsBody(circleOfRadius: radius)
            node.fillColor = color

            physics.charge = charge
            physics.affectedByGravity = false
            physics.restitution = 0.1
            physics.linearDamping = 0.1

            node.physicsBody = physics

            let position = CGPoint(
                x: CGFloat.random(in: 0..<size.width),
                y: CGFloat.random(in: 0..<size.height)
            )
            node.position = position
            addChild(node)
        }

        (0..<10).forEach { _ in addNode(.purple, 0.01) }
        (0..<10).forEach { _ in addNode(.blue, -0.01) }
    }

    private func demoMagneticField() {
        let magneticField = SKFieldNode.magneticField()
        magneticField.strength = 0.2
        self.addChild(magneticField)

        func addNode(_ color: UIColor, _ charge: CGFloat) {
            let radius: CGFloat = 10
            let node = SKShapeNode(circleOfRadius: radius)
            let physics = SKPhysicsBody(circleOfRadius: radius)
            node.fillColor = color

            physics.charge = charge
            physics.affectedByGravity = false
            physics.restitution = 0.1
            physics.linearDamping = 0.1

            node.physicsBody = physics

            let position = CGPoint(
                x: CGFloat.random(in: 0..<size.width),
                y: CGFloat.random(in: 0..<size.height)
            )
            node.position = position
            addChild(node)
            let mag: CGFloat = 2
            physics.applyImpulse(CGVector(dx: CGFloat.random(in: -mag...mag), dy: CGFloat.random(in: -mag...mag)))
        }

        (0..<10).forEach { _ in addNode(.purple, 0.01) }
        (0..<10).forEach { _ in addNode(.blue, -0.01) }
    }
}
