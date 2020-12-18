//
// Reactions App
//
  

import SpriteKit

class SKBeakerScene: SKScene, SKPhysicsContactDelegate {

    let waterHeight: CGFloat
    let updateConcentrationC: ((CGFloat) -> Void)
    let emitterPosition: CGPoint
    var catalystColor: UIColor
    var emitting: Bool {
        willSet {
            if (!emitting && newValue) {
                addCatalysts()
            } else if (emitting && !newValue) {
                resetCatalysts()
            }
        }
    }
    var canReactToC: Bool = false
    var reactionHasStarted: Bool = false {
        willSet {
            if (reactionHasStarted != newValue) {
                if (!newValue) {
                    resetCollisions()
                }
            }
        }
    }
    
    var reactionHasEnded: Bool = false {
        willSet {
            if (newValue != reactionHasEnded) {
                if (newValue) {
                    endReaction()
                } else {
                    removeAllActions()
                }
            }
        }
    }

    init(
        size: CGSize,
        waterHeight: CGFloat,
        updateConcentrationC: @escaping (CGFloat) -> Void,
        emitterPosition: CGPoint,
        emitting: Bool,
        catalystColor: UIColor
    ) {
        self.waterHeight = waterHeight
        self.updateConcentrationC = updateConcentrationC
        self.emitterPosition = emitterPosition
        self.emitting = emitting
        self.catalystColor = catalystColor
        self.settings = SKBeakerSceneSettings(width: size.width, height: size.height)
        self.velocity = settings.minVelocity
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let settings: SKBeakerSceneSettings

    private let moleculeACategory: UInt32 = 0b1
    private let moleculeBCategory: UInt32 = 0b10
    private let moleculeCCategory: UInt32 = 0b100
    private let beakerCategory: UInt32 = 0b1000
    private let catalystCategory: UInt32 = 0b10000
    private let sceneFrameCategory: UInt32 = 0b100000
    private let allCollisions: UInt32 = 0b111111

    private var velocity: CGFloat
    private var collisionsSinceLastCMolecule = 0

    private var molecules = [SKPhysicsBody]()
    private var fallingCatalysts = [SKShapeNode]()
    private var catalystsInLiquid = [SKShapeNode]()
    private var cMolecules: Int = 0

    private let updateSpeedDelay = 0.5
    private let catalystFallDelay = 0.2

    private let runCatalystKey = "AddCatalysts"

    var extraSpeed: CGFloat = 0 {
        didSet {
            let minV = settings.minVelocity
            let maxV = settings.maxVelocity
            self.velocity = minV + (extraSpeed * (maxV - minV))
            updateSpeeds(allowRapidChange: true)
        }
    }

    @objc
    private func updateSpeeds(
        allowRapidChange: Bool
    ) {
        func updateSpeed(_ body: SKPhysicsBody) {
            let magnitude = body.velocity.magnitude
            let factor = velocity / magnitude

            let maxFactor = allowRapidChange ? factor :  1.4
            let minFactor = allowRapidChange ? factor : 0.6

            let adjustedFactor = min(maxFactor, max(minFactor, factor))
            body.velocity = body.velocity.scale(by: adjustedFactor)
        }
        molecules.forEach(updateSpeed)
        catalystsInLiquid.forEach { c in
            if let body = c.physicsBody {
                updateSpeed(body)
            }
        }
    }

    private func endReaction() {
        let aMolecules = molecules.withCategory(moleculeACategory).compactMap { $0.node as? SKShapeNode }
        let bMolecules = molecules.withCategory(moleculeBCategory).compactMap { $0.node as? SKShapeNode }

        let minCount = min(aMolecules.count, bMolecules.count)

        for i in 0..<minCount {
            let aMolecule = aMolecules[i]
            let bMolecule = bMolecules[i]

            let aPos = aMolecule.position
            let bPos = bMolecule.position

            let midPos = CGPoint(x: (aPos.x + bPos.x) / 2, y: (aPos.y + bPos.y) / 2)
            let aFinalPos = CGPoint(x: midPos.x - settings.moleculeRadius, y: midPos.y)
            let bFinalPos = CGPoint(x: midPos.x + settings.moleculeRadius, y: midPos.y)

            if let bodyA = aMolecule.physicsBody, let bodyB = bMolecule.physicsBody {
                let duration: TimeInterval = 0.5
                bodyA.collisionBitMask = 0
                bodyB.collisionBitMask = 0

                aMolecule.run(SKAction.move(to: aFinalPos, duration: duration))
                bMolecule.run(SKAction.move(to: bFinalPos, duration: duration))

                let join = SKAction.run { [self] in
                    joinMolecules(bodyA: bodyA, nodeA: aMolecule, bodyB: bodyB, nodeB: bMolecule, anchor: midPos)
                    bodyA.collisionBitMask = allCollisions
                    bodyB.collisionBitMask = allCollisions
                }
                let delay = SKAction.wait(forDuration: duration)
                self.run(SKAction.sequence([delay, join]))
            }
        }
    }

    private func resetCollisions() {
        self.physicsWorld.removeAllJoints()
        var aMoleculesToAdd = cMolecules / 2
        cMolecules = 0
        molecules.forEach { molecule in
            molecule.collisionBitMask = allCollisions
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

    private func resetCatalysts() {
        removeAction(forKey: runCatalystKey)
        removeChildren(in: fallingCatalysts)
        removeChildren(in: catalystsInLiquid)
    }

    override func didMove(to view: SKView) {
        let water = CGRect(x: 0, y: 0, width: size.width, height: waterHeight)
        let borderBody = SKPhysicsBody(edgeLoopFrom: water)
        borderBody.friction = 0
        borderBody.categoryBitMask = beakerCategory
        self.physicsBody = borderBody
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let edgeOfBeaker = SKPhysicsBody(edgeLoopFrom: frame)
        edgeOfBeaker.friction = 0
        edgeOfBeaker.isDynamic = false
        edgeOfBeaker.categoryBitMask = sceneFrameCategory
        let edgeOfBeakerNode = SKShapeNode(rect: frame)
        edgeOfBeakerNode.physicsBody = edgeOfBeaker
        edgeOfBeakerNode.lineWidth = 0
        self.addChild(edgeOfBeakerNode)

        self.backgroundColor = .clear

        for _ in 0..<settings.aMolecules {
            addMolecule(color: UIColor.moleculeA, category: moleculeACategory)
        }

        for _ in 0..<settings.bMolecules {
            addMolecule(color: UIColor.moleculeB, category: moleculeBCategory)
        }

        addWedges()
        if (emitting) {
            addCatalysts()
        }
        self.physicsWorld.contactDelegate = self
        let updateSpeedAction = SKAction.run { self.updateSpeeds(allowRapidChange: false) }
        let wait = SKAction.wait(forDuration: updateSpeedDelay)
        let sequence = SKAction.sequence([wait, updateSpeedAction])
        self.run(SKAction.repeatForever(sequence))
    }

    private func addCatalysts() {
        let wait = SKAction.wait(forDuration: catalystFallDelay)
        let run = SKAction.run {
            self.addCatalyst()
        }
        let sequence = SKAction.sequence([run, wait])
        let repeatAction = SKAction.repeat(sequence, count: settings.catalystParticles)
        self.run(repeatAction, withKey: runCatalystKey)
    }

    private func addCatalyst() {
        let radius = settings.moleculeRadius
        let path = CGMutablePath()

        let radians18 = 18 * (CGFloat.pi / 180)
        let radians54 = -54 * (CGFloat.pi / 180)
        let topRightX = radius * cos(radians18)
        let topRightY = radius * sin(radians18)
        let bottomRightX = radius * cos(radians54)
        let bottomRightY = radius * sin(radians54)

        path.addLines(between: [
            CGPoint(x: 0, y: radius),                   // Top
            CGPoint(x: topRightX, y: topRightY),        // Top right
            CGPoint(x: bottomRightX, y: bottomRightY),  // Bottom right
            CGPoint(x: -bottomRightX, y: bottomRightY), // Bottom left
            CGPoint(x: -topRightX, y: topRightY),       // Top left
            CGPoint(x: 0, y: radius)                    // Top
        ])

        let catalyst = SKShapeNode(path: path)
        catalyst.lineWidth = 0

        let catalystPhysics = SKPhysicsBody(polygonFrom: path)
        catalystPhysics.affectedByGravity = false
        catalystPhysics.linearDamping = 0
        catalystPhysics.angularDamping = 0
        catalystPhysics.restitution = 1
        catalystPhysics.mass = 0.3
        catalystPhysics.usesPreciseCollisionDetection = true

        catalystPhysics.categoryBitMask = catalystCategory
        catalystPhysics.collisionBitMask = sceneFrameCategory

        let maxDx = self.size.width * 0.01
        let centerX = emitterPosition.x - radius
        let centerY = emitterPosition.y - radius
        let minX = centerX - maxDx
        let maxX = centerX + maxDx
        let randomX = CGFloat.random(in: minX...maxX)

        catalyst.position = CGPoint(x: randomX, y: centerY)

        let verticalMagnitude: CGFloat = settings.catalystVerticalMagnitude
        let angle = CGFloat.random(in: settings.catalystMinAngle...settings.catalystMaxAngle)
        let radians = angle * (CGFloat.pi / 180)

        // y component is always `verticalMagnitude`, so x component is tan of the angle.
        let xVelocity = verticalMagnitude * tan(radians)

        catalystPhysics.velocity = CGVector(dx: xVelocity, dy: -verticalMagnitude)

        catalyst.physicsBody = catalystPhysics
        catalyst.fillColor = catalystColor
        catalyst.lineWidth = 0.01 * radius
        catalyst.strokeColor = .white
        addChild(catalyst)
        fallingCatalysts.append(catalyst)
    }

    private var catalystFallVelocity: CGFloat {
        -100
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard reactionHasStarted else {
            return
        }
        collisionsSinceLastCMolecule += 1
        let catA = contact.bodyA.categoryBitMask
        let catB = contact.bodyB.categoryBitMask
        if (catA == moleculeACategory && catB == moleculeBCategory) {
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
                let concentrationC = CGFloat(cMolecules) / CGFloat(settings.aMolecules + settings.bMolecules)
                updateConcentrationC(concentrationC)

                UIImpactFeedbackGenerator(style: .light).impactOccurred()

            }
        }
    }

    private func joinMolecules(
        bodyA: SKPhysicsBody,
        nodeA: SKShapeNode,
        bodyB: SKPhysicsBody,
        nodeB: SKShapeNode,
        anchor: CGPoint
    ) {
        bodyA.categoryBitMask = moleculeCCategory
        bodyB.categoryBitMask = moleculeCCategory
        bodyA.allowsRotation = true
        bodyB.allowsRotation = true
        let joint = SKPhysicsJointFixed.joint(
            withBodyA: bodyA,
            bodyB: bodyB,
            anchor: anchor
        )
        self.physicsWorld.add(joint)
        nodeA.fillColor = SKColor(cgColor: UIColor.moleculeC.cgColor)
        nodeB.fillColor = SKColor(cgColor: UIColor.moleculeC.cgColor)
        cMolecules += 2
    }

    override func didFinishUpdate() {
        for (i, catalyst) in fallingCatalysts.enumerated().reversed() {
            if let body = catalyst.physicsBody, catalyst.position.y < waterHeight {
                body.collisionBitMask = allCollisions
                let impulse = SKAction.applyForce(CGVector(dx: 0, dy: -0.2 * catalystFallVelocity), duration: 0.5)
                catalyst.run(impulse)
                fallingCatalysts.remove(at: i)
                catalystsInLiquid.append(catalyst)
            }
        }
    }

    private func shouldCollide() -> Bool {
        canReactToC && !reactionHasEnded && collisionsSinceLastCMolecule >= settings.collisionsForC
    }

    private func addMolecule(
        color: UIColor,
        category: UInt32
    ) {
        let radius = settings.moleculeRadius
        let molecule = SKShapeNode(circleOfRadius: radius)
        let x = CGFloat.random(in: 0...size.width)
        let y = CGFloat.random(in: 0...waterHeight)

        molecule.position = CGPoint(x: x, y: y)
        molecule.fillColor = color
        molecule.lineWidth = 0

        let moleculePhysics = SKPhysicsBody(circleOfRadius: radius)
        moleculePhysics.restitution = 1
        moleculePhysics.friction = 0
        moleculePhysics.linearDamping = 0
        moleculePhysics.angularDamping = 0
        moleculePhysics.allowsRotation = false
        moleculePhysics.categoryBitMask = category
        moleculePhysics.contactTestBitMask = 1
        moleculePhysics.mass = 1
        moleculePhysics.usesPreciseCollisionDetection = true
        moleculePhysics.affectedByGravity = false
        moleculePhysics.collisionBitMask = allCollisions
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
        let width = settings.moleculeRadius
        let height = width * 2

        func addWedge(
            leftXEdge: Bool,
            bottomYEdge: Bool
        ) {
            let x1 = leftXEdge ? 0 : size.width
            let y1 = bottomYEdge ? 0 : waterHeight
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
            node.physicsBody?.categoryBitMask = beakerCategory
            node.lineWidth = 0
            addChild(node)
        }

        addWedge(leftXEdge: true, bottomYEdge: true)
        addWedge(leftXEdge: true, bottomYEdge: false)
        addWedge(leftXEdge: false, bottomYEdge: true)
        addWedge(leftXEdge: false, bottomYEdge: false)
    }
}


fileprivate struct SKBeakerSceneSettings {

    let width: CGFloat
    let height: CGFloat

    let aMolecules = 15
    let bMolecules = 15
    let collisionsForC = 15
    let minVelocity: CGFloat = 3
    let maxVelocity: CGFloat = 100
    let catalystParticles = 7

    var catalystVerticalMagnitude: CGFloat {
        0.3 * height
    }
    let catalystMinAngle: CGFloat = 5
    let catalystMaxAngle: CGFloat = 30

    var moleculeRadius: CGFloat {
        MoleculeGridSettings.moleculeRadius(width: width)
    }

}

fileprivate extension Array where Array.Element == SKPhysicsBody {
    func withCategory(_ category: UInt32) -> [Element] {
        filter { $0.categoryBitMask == category }
    }
}

fileprivate extension CGVector {
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
