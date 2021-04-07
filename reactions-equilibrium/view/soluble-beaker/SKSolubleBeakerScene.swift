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
    let model: SolubilityViewModel
    @Binding var shouldAddParticle: Bool

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = SKSolubleBeakerScene(
            size: size,
            soluteWidth: soluteWidth,
            waterHeight: waterHeight,
            soluteState: model.beakerSoluteState,
            saturatedReactionDuration: model.timing.equilibrium - model.timing.start,
            onWaterEntry: model.onParticleWaterEntry,
            onDissolve: model.onDissolve
        )
        scene.scaleMode = .aspectFit
        view.allowsTransparency = true
        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? SKSolubleBeakerScene {
            if shouldAddParticle && model.canEmit {
                scene.addParticle(at: particlePosition)
                model.onParticleEmit(soluteType: model.beakerSoluteState.soluteType)
                shouldAddParticle = false
            }
            scene.soluteWidth = soluteWidth
            scene.waterHeight = waterHeight
            scene.onWaterEntry = model.onParticleWaterEntry
            scene.soluteState = model.beakerSoluteState
            scene.saturatedReactionDuration = model.timing.equilibrium - model.timing.start
            scene.onDissolve = model.onDissolve
        }
    }
}

enum BeakerSoluteState: Equatable {
    case addingSolute(type: SoluteType, clearPrevious: Bool)
    case addingSaturatedPrimary
    case dissolvingSuperSaturatedPrimary
    case completedSuperSaturatedReaction

    var soluteType: SoluteType {
        switch self {
        case let .addingSolute(type: type, clearPrevious: _):
            return type
        default: return .primary
        }
    }
}

class SKSolubleBeakerScene: SKScene {

    var soluteWidth: CGFloat
    var waterHeight: CGFloat
    var saturatedReactionDuration: CGFloat
    var onWaterEntry: (SoluteType) -> Void
    var onDissolve: (SoluteType) -> Void

    var soluteState: BeakerSoluteState {
        didSet {
            handleBeakerStateUpdate(oldValue: oldValue)
        }
    }

    private let saturatedReactionKey = "soluteReactionKey"

    struct Category {
        static let water: UInt32 = 0b1
        static let solute: UInt32 = 0b10
        static let ion: UInt32 = 0b100
    }


    init(
        size: CGSize,
        soluteWidth: CGFloat,
        waterHeight: CGFloat,
        soluteState: BeakerSoluteState,
        saturatedReactionDuration: CGFloat,
        onWaterEntry: @escaping (SoluteType) -> Void,
        onDissolve: @escaping (SoluteType) -> Void
    ) {
        self.soluteWidth = soluteWidth
        self.waterHeight = waterHeight
        self.saturatedReactionDuration = saturatedReactionDuration
        self.soluteState = soluteState
        self.onWaterEntry = onWaterEntry
        self.onDissolve = onDissolve
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        let field = SKFieldNode.magneticField()
        field.strength = 0.5
        addChild(field)
        backgroundColor = .clear

        let waterRect = CGRect(x: 0, y: 0, width: size.width, height: waterHeight)
        let water = SKShapeNode(rect: waterRect)
        let waterPhysics = SKPhysicsBody(edgeLoopFrom: waterRect)
        waterPhysics.categoryBitMask = Category.water
        waterPhysics.collisionBitMask = Category.ion
        water.physicsBody = waterPhysics
        addChild(water)
    }

    func addParticle(at position: CGPoint) {
        let factor: CGFloat = soluteState.soluteType == .acid ? 0.75 : 1
        let sideLength = (soluteWidth / 2) * factor
        let node = SKSoluteNode(sideLength: sideLength, soluteType: soluteState.soluteType)
        node.position = position.offset(dx: -sideLength, dy: 0)
        node.zPosition = 1

        addChild(node)

        node.physicsBody?.applyTorque(CGFloat.random(in: -1...1))
        node.physicsBody?.collisionBitMask = Category.solute | Category.ion
        node.physicsBody?.categoryBitMask = Category.solute
        node.physicsBody?.mass = 1

        if case .addingSolute = soluteState {
            node.willDissolve = true
            let action = SKAction.run { [weak self] in
                self?.addIons(at: node.position.offset(dx: sideLength, dy: 0))
                node.dissolve()
                self?.onDissolve(node.soluteType)
            }
            let delay = SKAction.wait(forDuration: 2)
            self.run(SKAction.sequence([delay, action]))
        }
    }

    private func addIons(at position: CGPoint) {
        for _ in 0..<3 {
            addIon(at: position, charge: .positive)
            addIon(at: position, charge: .negative)
        }
    }

    private func addIon(at position: CGPoint, charge: IonCharge) {
        let radius = soluteWidth / 4
        let ion = SKIonNode(radius: radius, charge: charge)

        func randomOffset() -> CGFloat {
            0
//            CGFloat.random(in: -radius...radius)
        }
        ion.position = CGPoint(x: position.x + randomOffset(), y: position.y + randomOffset())

        ion.physicsBody?.categoryBitMask = Category.ion
        ion.physicsBody?.collisionBitMask = Category.water | Category.solute

        ion.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: size.width), y: SKRange(lowerLimit: 0, upperLimit: waterHeight))
        ]

        addChild(ion)

        func randomImpulse() -> CGFloat { CGFloat.random(in: -50...50) }
        ion.physicsBody?.applyImpulse(CGVector(dx: randomImpulse(), dy: randomImpulse()))
    }

    private func hideSolute() {
        removeSolute()
    }

    private func removeSolute() {
        runOnSolute { solute in
            solute.removeFromParent()
        }
    }

    private func showHiddenSolute() {
//        mapSolute { solute in
//            if solute.isHidden {
//                solute.show()
//            }
//        }
    }

    private func handleBeakerStateUpdate(oldValue: BeakerSoluteState) {
        guard soluteState != oldValue else {
            return
        }

        switch (soluteState, oldValue) {
        case (.addingSolute(type: .primary, clearPrevious: _), .addingSaturatedPrimary):
            removeSolute()
        case (.addingSolute(type: _, clearPrevious: true), _):
            hideSolute()
        case (.addingSaturatedPrimary, .addingSolute(type: _, clearPrevious: true)):
            showHiddenSolute()
        case (.dissolvingSuperSaturatedPrimary, _):
            runSuperSaturatedReaction(duration: saturatedReactionDuration)
        case (.addingSolute(type: .acid, clearPrevious: _), .dissolvingSuperSaturatedPrimary):
            cancelSaturatedReaction()
            reAddSaturatedReactionSolute()
        case (.completedSuperSaturatedReaction, _):
            endSuperSaturatedReaction()
        case (_, .dissolvingSuperSaturatedPrimary):
            cancelSaturatedReaction()
        default:
            break
        }
    }

    private var saturatedNodesReacted = [SKSoluteNode]()
    private func runSuperSaturatedReaction(duration: CGFloat) {
        let primaryNodes: [SKSoluteNode] = children.compactMap {
            if let solute = $0 as? SKSoluteNode, solute.soluteType == .primary, !solute.willDissolve {
                return solute
            }
            return nil
        }
        guard !primaryNodes.isEmpty else {
            return
        }
        let dt = duration / CGFloat(primaryNodes.count)
        (0..<primaryNodes.count).forEach { i in
            let node = primaryNodes[i]
            let delay = SKAction.wait(forDuration: Double(i + 1) * Double(dt))
            let dissolve = SKAction.run {
                self.saturatedNodesReacted.append(node.copyNode())
                node.dissolve()
                self.onDissolve(node.soluteType)
            }
            let action = SKAction.sequence([delay, dissolve])
            node.run(action, withKey: saturatedReactionKey)
        }
    }

    private func endSuperSaturatedReaction() {
        cancelSaturatedReaction()
        runSuperSaturatedReaction(duration: 0.5)
    }
    

    private func reAddSaturatedReactionSolute() {
        saturatedNodesReacted.forEach(addChild)
        saturatedNodesReacted.removeAll()
    }

    private func cancelSaturatedReaction() {
        children.forEach { $0.removeAction(forKey: saturatedReactionKey) }
    }

    private func runOnSolute(_ f: (SKSoluteNode) -> Void) {
        for child in children {
            if let solute = child as? SKSoluteNode {
                f(solute)
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        runOnSolute { solute in
            if let physics = solute.physicsBody {
                if solute.position.y < waterHeight && !solute.hasEnteredWater {
                    solute.hasEnteredWater = true
                    physics.linearDamping = 50
                    physics.angularDamping = 1
                    onWaterEntry(solute.soluteType)
                }
            }
        }
    }
}
