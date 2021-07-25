//
// Reactions App
//

import SpriteKit

class SKBeakerScene: SKScene, SKPhysicsContactDelegate {

    var allowReactionsToC: Bool = false {
        willSet {
            if allowReactionsToC && !newValue && cMolecules > 0 {
                resetCollisions()
            }
        }
    }

    var extraSpeed: CGFloat = 0 {
        didSet {
            let minV = MoleculeEnergySettings.minVelocity
            let maxV = MoleculeEnergySettings.maxVelocity
            self.velocity = minV + (extraSpeed * (maxV - minV))
            updateSpeeds()
        }
    }

    var updateConcentrationC: ((CGFloat) -> Void)?

    @objc
    private func updateSpeeds() {
        molecules.forEach { m in
            let magnitude = m.velocity.magnitude
            let factor = velocity / magnitude
            m.velocity = m.velocity.scale(by: factor)
        }
    }

    private func resetCollisions() {
        self.physicsWorld.removeAllJoints()
        var aMoleculesToAdd = cMolecules / 2
        cMolecules = 0
        collisionsSinceLastCMolecule = 0
        molecules.forEach { molecule in
            if molecule.categoryBitMask == moleculeCCategory,
               let node = molecule.node as? SKShapeNode {
                let addA = aMoleculesToAdd > 0
                let color: UIColor = addA ? .moleculeA : .moleculeB
                let category = addA ? moleculeACategory : moleculeBCategory
                aMoleculesToAdd -= 1
                node.fillColor = color
                molecule.categoryBitMask = category
            }

        }
    }

    private let moleculeACategory: UInt32 = 0x1 << 0
    private let moleculeBCategory: UInt32 = 0x1 << 1
    private let moleculeCCategory: UInt32 = 0x1 << 2
    private let wallCategory: UInt32 = 0x1 << 3
    private let collisionBitMask: UInt32 = 0x1 << 0

    private var velocity: CGFloat = MoleculeEnergySettings.minVelocity

    private var collisionsSinceLastCMolecule = 0

    private var molecules = [SKPhysicsBody]()

    private var cMolecules: Int = 0

    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.categoryBitMask = wallCategory
        borderBody.contactTestBitMask = 1
        self.physicsBody = borderBody
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        self.backgroundColor = Styling.beakerLiquidSK

        for _ in 0..<MoleculeEnergySettings.aMolecules {
            addMolecule(color: UIColor.moleculeA, category: moleculeACategory)
        }

        for _ in 0..<MoleculeEnergySettings.bMolecules {
            addMolecule(color: UIColor.moleculeB, category: moleculeBCategory)
        }

        addWedges()
        self.physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSpeeds), userInfo: nil, repeats: true)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard allowReactionsToC else {
            return
        }
        collisionsSinceLastCMolecule += 1
        let catA = contact.bodyA.categoryBitMask
        let catB = contact.bodyB.categoryBitMask
        if catA == moleculeACategory && catB == moleculeBCategory {
            if let nodeA = contact.bodyA.node as? SKShapeNode,
               let nodeB = contact.bodyB.node as? SKShapeNode,
               shouldCollide() {
                collisionsSinceLastCMolecule = 0
                contact.bodyA.categoryBitMask = moleculeCCategory
                contact.bodyB.categoryBitMask = moleculeCCategory
                contact.bodyA.allowsRotation = true
                contact.bodyB.allowsRotation = true
                let joint = SKPhysicsJointFixed.joint(
                    withBodyA: contact.bodyA,
                    bodyB: contact.bodyB,
                    anchor: contact.contactPoint
                )
                self.physicsWorld.add(joint)
                nodeA.fillColor = SKColor(cgColor: UIColor.moleculeC.cgColor)
                nodeB.fillColor = SKColor(cgColor: UIColor.moleculeC.cgColor)
                cMolecules += 2
                if let updateC = updateConcentrationC {
                    let concentration = CGFloat(cMolecules) / CGFloat(MoleculeEnergySettings.aMolecules + MoleculeEnergySettings.bMolecules)
                    updateC(concentration)
                }
            }
        }
    }

    private func shouldCollide() -> Bool {
        collisionsSinceLastCMolecule >= MoleculeEnergySettings.collisionsForC
    }

    private func addMolecule(
        color: UIColor,
        category: UInt32
    ) {
        let radius = MoleculeEnergySettings.moleculeRadius(width: size.width)
        let molecule = SKShapeNode(circleOfRadius: radius)
        let x = CGFloat.random(in: 0...size.width)
        let y = CGFloat.random(in: 0...size.height)

        molecule.position = CGPoint(x: x, y: y)
        molecule.fillColor = color

        let moleculePhysics = SKPhysicsBody(circleOfRadius: radius)
        moleculePhysics.restitution = 1
        moleculePhysics.friction = 0
        moleculePhysics.linearDamping = 0
        moleculePhysics.angularDamping = 0
        moleculePhysics.allowsRotation = true
        moleculePhysics.categoryBitMask = category
        moleculePhysics.contactTestBitMask = 1
        moleculePhysics.mass = 1
        moleculePhysics.usesPreciseCollisionDetection = true
        molecule.physicsBody = moleculePhysics
        addChild(molecule)
        molecules.append(moleculePhysics)

        let angle = CGFloat.random(in: 0.2...0.8) * CGFloat.pi
        let direction: CGFloat = Bool.random() ? 1 : -1
        let dx = velocity * sin(angle) * direction
        let dy = velocity * cos(angle) * direction
        moleculePhysics.velocity = CGVector(dx: dx, dy: dy)
    }

    /// The wedges are added to prevent molecules becoming 'stuck' in the corners, or along edges.
    private func addWedges() {
        let width = MoleculeEnergySettings.moleculeRadius(width: size.width)
        let height = width * 2

        func addWedge(
            leftXEdge: Bool,
            bottomYEdge: Bool
        ) {
            let x1 = leftXEdge ? 0 : size.width
            let y1 = bottomYEdge ? 0 : size.height
            let xDir: CGFloat = leftXEdge ? 1 : -1
            let yDir: CGFloat = bottomYEdge ? 1 : -1

            let x2 = x1 + (xDir * width)
            let y2 = y1 + (yDir * height)

            let p = UIBezierPath()
            p.move(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y1))
            p.addLine(to: CGPoint(x: x1, y: y2))
            p.addLine(to: CGPoint(x: x1, y: y1))
            let node = SKShapeNode(path: p.cgPath)
            node.physicsBody = SKPhysicsBody(polygonFrom: p.cgPath)
            node.physicsBody?.friction = 0
            node.physicsBody?.isDynamic = false
            addChild(node)
        }

        addWedge(leftXEdge: true, bottomYEdge: true)
        addWedge(leftXEdge: true, bottomYEdge: false)
        addWedge(leftXEdge: false, bottomYEdge: true)
        addWedge(leftXEdge: false, bottomYEdge: false)
    }
}

struct MoleculeEnergySettings {

    static let aMolecules = 15
    static let bMolecules = 15
    static let collisionsForC = 50
    static let minVelocity: CGFloat = 3
    static let maxVelocity: CGFloat = 100

    static func moleculeRadius(width: CGFloat) -> CGFloat {
        MoleculeGridSettings.moleculeRadius(width: width)
    }

}

extension CGVector {
    var magnitude: CGFloat {
        sqrt(pow(dx, 2) + pow(dy, 2))
    }

    func scale(by factor: CGFloat) -> CGVector {
        CGVector(
            dx: dx * factor,
            dy: dy * factor
        )
    }
}
