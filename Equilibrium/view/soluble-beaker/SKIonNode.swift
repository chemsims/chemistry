//
// Reactions App
//

import SpriteKit
import SwiftUI


class SKIonNode: SKNode {

    let radius: CGFloat
    let charge: IonCharge

    init(radius: CGFloat, charge: IonCharge) {
        self.radius = radius
        self.charge = charge
        super.init()

        let node = SKShapeNode(circleOfRadius: radius)
        node.strokeColor = .clear
        node.fillColor = charge.isPositive ? .orange : .purple

        let physics = SKPhysicsBody(circleOfRadius: radius)
        physics.affectedByGravity = false
        physics.linearDamping = 0
        physics.angularDamping = 0
        physics.mass = 0.5
        physics.charge = charge.isPositive ? 0.4 : -0.4

        self.physicsBody = physics
        addChild(node)

        if charge.isPositive {
            addPlus()
        } else {
            addMinus()
        }
    }

    private var innerPadding: CGFloat {
        0.3 * radius
    }

    private func addPlus() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -radius + innerPadding, y: 0))
        path.addLine(to: CGPoint(x: radius - innerPadding, y: 0))

        path.move(to: CGPoint(x: 0, y: -radius + innerPadding))
        path.addLine(to: CGPoint(x: 0, y: radius - innerPadding))

        addSignPath(path)
    }

    private func addMinus() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -radius + innerPadding, y: 0))
        path.addLine(to: CGPoint(x: radius - innerPadding, y: 0))
        addSignPath(path)
    }

    private func addSignPath(_ path: CGPath) {
        let node = SKShapeNode(path: path)
        node.lineWidth = 0.15 * radius
        node.strokeColor = .white
        addChild(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum IonCharge {
    case positive, negative

    var isPositive: Bool {
        self == .positive
    }
}


struct SKIonNode_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NodeRepresentable(charge: .negative)
                .frame(width: NodeRepresentable.sceneSize, height: NodeRepresentable.sceneSize)

            NodeRepresentable(charge: .positive)
                .frame(width: NodeRepresentable.sceneSize, height: NodeRepresentable.sceneSize)
        }
    }

    struct NodeRepresentable: UIViewRepresentable {
        typealias UIView = SKView

        let charge: IonCharge

        func makeUIView(context: Context) -> SKView {
            let view = SKView()
            view.allowsTransparency = true
            let scene = SKScene(size: CGSize(width: Self.sceneSize, height: Self.sceneSize))
            scene.backgroundColor = .clear
            view.presentScene(scene)
            let node = SKIonNode(radius: Self.radius, charge: charge)
            node.position = CGPoint(
                x: (Self.sceneSize / 2),
                y: (Self.sceneSize / 2)
            )
            scene.addChild(node)
            return view
        }

        func updateUIView(_ uiView: SKView, context: Context) {

        }

        static let radius: CGFloat = 20
        static let sceneSize: CGFloat = 100
    }
}
