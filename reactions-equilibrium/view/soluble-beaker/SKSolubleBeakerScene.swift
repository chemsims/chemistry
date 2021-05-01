//
// Reactions App
//

import SpriteKit
import SwiftUI

/// Enum to control adding a particle without calling any callbacks when particle emits, enters water or dissolves.
/// This is useful in accessibility for example, where the timing of these functions can be run sequentially to avoid
/// the user having to wait until the solute particle to actually dissolves for state to be updated.
enum AddManualParticle {
    /// Adds a particle
    /// - Parameters:
    ///   - forceEmit: Forces this particle to be emitted, regardless of model state.
    case add(forceDissolve: Bool)

    /// Does not add a particle
    case none
}

struct SolubleBeakerSceneRepresentable: UIViewRepresentable {
    typealias UIView = SKView

    let size: CGSize
    let particlePosition: CGPoint
    let soluteWidth: CGFloat
    let waterHeight: CGFloat
    let model: SolubilityViewModel
    @Binding var shouldAddParticle: Bool
    @Binding var addManualParticle: AddManualParticle

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = SKSolubleBeakerScene(
            size: size,
            soluteWidth: soluteWidth,
            waterHeight: waterHeight,
            saturatedReactionDuration: model.timing.equilibrium - model.timing.start,
            reaction: model.selectedReaction,
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
                scene.addParticle(at: particlePosition, runCallback: true, forceDissolve: false)
                model.onParticleEmit(soluteType: model.beakerState.state.soluteType, onBeakerState: model.beakerState.state)
                shouldAddParticle = false
            }
            if case let .add(forceDissolve) = addManualParticle {
                scene.addParticle(at: particlePosition, runCallback: false, forceDissolve: forceDissolve)
                addManualParticle = .none
            }
            scene.soluteWidth = soluteWidth
            scene.waterHeight = waterHeight
            scene.onWaterEntry = model.onParticleWaterEntry
            scene.saturatedReactionDuration = model.timing.equilibrium - model.timing.start
            scene.onDissolve = model.onDissolve
            scene.transition = model.beakerState
            scene.reaction = model.selectedReaction
        }
    }
}

private class SKSolubleBeakerScene: SKScene {

    typealias SoluteClosure = (SoluteType, BeakerState) -> Void

    var soluteWidth: CGFloat
    var waterHeight: CGFloat
    var saturatedReactionDuration: CGFloat
    var onWaterEntry: SoluteClosure
    var onDissolve: SoluteClosure
    var reaction: SolubleReactionType

    var transition: BeakerStateTransition {
        didSet {
            guard transition != oldValue else {
                return
            }
            transition.actions.forEach(handleAction)
        }
    }

    var soluteState: BeakerState {
        transition.state
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
        saturatedReactionDuration: CGFloat,
        reaction: SolubleReactionType,
        onWaterEntry: @escaping SoluteClosure,
        onDissolve: @escaping SoluteClosure
    ) {
        self.soluteWidth = soluteWidth
        self.waterHeight = waterHeight
        self.saturatedReactionDuration = saturatedReactionDuration
        self.reaction = reaction
        self.onWaterEntry = onWaterEntry
        self.onDissolve = onDissolve
        self.transition = BeakerStateTransition()
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        let field = SKFieldNode.magneticField()
        field.strength = 0.75
        addChild(field)
        backgroundColor = .clear

        let waterRect = CGRect(x: 0, y: 0, width: size.width, height: waterHeight)
        let water = SKShapeNode(rect: waterRect)
        water.strokeColor = .clear
        let waterPhysics = SKPhysicsBody(edgeLoopFrom: waterRect)
        waterPhysics.categoryBitMask = Category.water
        waterPhysics.collisionBitMask = Category.ion
        water.physicsBody = waterPhysics
        addChild(water)
    }

    func addParticle(at position: CGPoint, runCallback: Bool, forceDissolve: Bool) {
        let factor: CGFloat = soluteState.soluteType == .acid ? 0.75 : 1
        let sideLength = (soluteWidth / 2) * factor
        let node = SKSoluteNode(
            sideLength: sideLength,
            reaction: reaction,
            stateOnEmit: soluteState,
            runCallback: runCallback
        )
        node.position = position.offset(dx: -sideLength, dy: 0)
        node.zPosition = 1

        addChild(node)

        node.physicsBody?.applyTorque(CGFloat.random(in: -1...1))
        node.physicsBody?.collisionBitMask = Category.solute | Category.ion
        node.physicsBody?.categoryBitMask = Category.solute
        node.physicsBody?.mass = 1

        if soluteState.shouldDissolve || forceDissolve {
            let action = SKAction.run { [weak self, weak node] in
                guard let strongSelf = self, let strongNode = node else {
                    return
                }

                strongNode.dissolve()
                if strongNode.runCallback {
                    strongSelf.onDissolve(strongNode.soluteType, strongNode.stateOnEmit)
                }

                if strongSelf.soluteState == .demoReaction {
                    strongSelf.addIons(
                        at: strongNode.position.offset(dx: sideLength, dy: 0)
                    )
                }
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

        ion.position = CGPoint(x: position.x, y: position.y)

        ion.physicsBody?.categoryBitMask = Category.ion
        ion.physicsBody?.collisionBitMask = Category.water | Category.solute

        ion.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: size.width), y: SKRange(lowerLimit: 0, upperLimit: waterHeight))
        ]

        addChild(ion)

        func randomImpulse() -> CGFloat {
            CGFloat.random(in: 25...50) * (Bool.random() ? 1 : -1)

        }
        let impulse = CGVector(dx: randomImpulse(), dy: randomImpulse())
        let action = SKAction.applyImpulse(impulse, duration: 0.5)
        ion.run(action)
    }

    private func hideSolute(duration: TimeInterval) {
        runOnSolute { solute in
            solute.willHide = true
            let fadeOut = SKAction.fadeOut(withDuration: duration)
            let hide = SKAction.run { [weak solute] in
                guard let strongSolute = solute, strongSolute.willHide else {
                    return
                }
                strongSolute.hide()
                strongSolute.physicsBody?.categoryBitMask = 0
            }

            solute.run(SKAction.sequence([fadeOut, hide]))
        }
    }

    private func showHiddenSolute(duration: TimeInterval) {
        runOnSolute { solute in
            if solute.isHidden || solute.willHide {
                solute.willHide = false
                let show = SKAction.run { [weak solute] in
                    solute?.show()
                    solute?.physicsBody?.categoryBitMask = Category.solute
                }
                let fadeIn = SKAction.fadeIn(withDuration: duration)
                solute.run(SKAction.sequence([show, fadeIn]))
            }
        }
    }

    private func removeSolute(duration: TimeInterval) {
        runOnSolute { solute in
            if !solute.isHidden {
                let fadeOut = SKAction.fadeOut(withDuration: duration)
                let remove = SKAction.removeFromParent()
                solute.run(SKAction.sequence([fadeOut, remove]))
            }
        }
    }

    private var saturatedNodesReacted = [SKSoluteNode]()
    private func runSuperSaturatedReaction(duration: CGFloat) {
        let primaryNodes: [SKSoluteNode] = children.compactMap {
            if let solute = $0 as? SKSoluteNode,
               solute.soluteType == .primary,
               !solute.willDissolve, !solute.isHidden {
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
                self.onDissolve(node.soluteType, node.stateOnEmit)
            }
            let action = SKAction.sequence([delay, dissolve])
            node.run(action, withKey: saturatedReactionKey)
        }
    }

    private func endSuperSaturatedReaction() {
        cancelSaturatedReaction()
        runSuperSaturatedReaction(duration: 0.25)
    }
    

    private func reAddSaturatedReactionSolute() {
        saturatedNodesReacted.forEach(addChild)
        saturatedNodesReacted.removeAll()
    }

    private func cancelSaturatedReaction() {
        children.forEach { $0.removeAction(forKey: saturatedReactionKey) }
    }

    private func cleanupDemoReaction() {
        for child in children {
            if child is SKSoluteNode || child is SKIonNode {
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                child.run(SKAction.sequence([fadeOut, remove]))
            }
        }
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
                    if solute.runCallback {
                        onWaterEntry(solute.soluteType, solute.stateOnEmit)
                    }
                }
            }
        }
    }
}

extension SKSolubleBeakerScene {
    private func handleAction(_ action: SKSoluteBeakerAction) {
        switch action {
        case .runReaction:
            runSuperSaturatedReaction(duration: saturatedReactionDuration)
        case .completeReaction:
            endSuperSaturatedReaction()
        case .undoReaction:
            cancelSaturatedReaction()
            reAddSaturatedReactionSolute()
        case .cleanupDemoReaction:
            cleanupDemoReaction()
        case let .removeSolute(duration: duration):
            removeSolute(duration: duration)
        case let .hideSolute(duration: duration):
            hideSolute(duration: duration)
        case let .reAddSolute(duration: duration):
            showHiddenSolute(duration: duration)
        case .none:
            break;
        }
    }
}
