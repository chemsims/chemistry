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
            scene.onDissolve = model.onDissolve
        }
    }
}

enum BeakerSoluteState: Equatable {
    case addingSolute(type: SoluteType, clearPrevious: Bool)
    case addingSaturatedPrimary
    case dissolvingSuperSaturatedPrimary

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
    var onWaterEntry: (SoluteType) -> Void
    var onDissolve: (SoluteType) -> Void

    var soluteState: BeakerSoluteState {
        didSet {
            handleBeakerStateUpdate(oldValue: oldValue)
        }
    }

    init(
        size: CGSize,
        soluteWidth: CGFloat,
        waterHeight: CGFloat,
        soluteState: BeakerSoluteState,
        onWaterEntry: @escaping (SoluteType) -> Void,
        onDissolve: @escaping (SoluteType) -> Void
    ) {
        self.soluteWidth = soluteWidth
        self.waterHeight = waterHeight
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
        backgroundColor = .clear
    }

    func addParticle(at position: CGPoint) {
        let sideLength = soluteWidth / 2
        let node = SKSoluteNode(sideLength: sideLength, soluteType: soluteState.soluteType)
        node.position = position.offset(dx: -sideLength, dy: 0)

        addChild(node)

        node.physicsBody?.applyTorque(CGFloat.random(in: -0.01...0.01))

        if case .addingSolute = soluteState {
            node.willDissolve = true
            let action = SKAction.run {
                node.dissolve()
                self.onDissolve(node.soluteType)
            }
            let delay = SKAction.wait(forDuration: 2)
            self.run(SKAction.sequence([delay, action]))
        }
    }

    private func hideSolute() {
        mapSolute { solute in
            if !solute.willDissolve {
                solute.hide()
            }
        }
    }

    private func removeSolute() {
        mapSolute { solute in
            solute.removeFromParent()
        }
    }

    private func showHiddenSolute() {
        mapSolute { solute in
            if solute.isHidden {
                solute.show()
            }
        }
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
        default:
            break
        }
    }

    private func mapSolute(_ f: (SKSoluteNode) -> Void) {
        for child in children {
            if let solute = child as? SKSoluteNode {
                f(solute)
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        mapSolute { solute in
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
