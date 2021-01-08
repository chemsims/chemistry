//
// Reactions App
//
  

import SwiftUI
import SpriteKit

struct SkBeakerSceneRepresentable: UIViewRepresentable {

    typealias UIViewType = SKView

    let width: CGFloat
    let height: CGFloat
    let waterHeight: CGFloat
    let speed: CGFloat
    let updateConcentrationC: (CGFloat) -> Void
    let emitterPosition: CGPoint
    let particleState: CatalystParticleState
    let catalystColor: UIColor
    let canReactToC: Bool
    let reactionState: EnergyReactionState
    let input: EnergyProfileReactionInput

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = SKBeakerScene(
            size: CGSize(width: width, height: height),
            waterHeight: waterHeight,
            updateConcentrationC: updateConcentrationC,
            emitterPosition: emitterPosition,
            particleState: particleState,
            catalystColor: catalystColor,
            reactionState: reactionState,
            moleculeAColor: input.moleculeA.color.uiColor,
            moleculeBColor: input.moleculeB.color.uiColor,
            moleculeCColor: input.moleculeC.color.uiColor
        )
        scene.scaleMode = .aspectFit
        view.allowsTransparency = true
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? SKBeakerScene {
            scene.extraSpeed = speed
            scene.reactionState = reactionState
            scene.particleState = particleState
            scene.catalystColor = catalystColor
            scene.canReactToC = canReactToC
            scene.moleculeAColor = input.moleculeA.color.uiColor
            scene.moleculeBColor = input.moleculeB.color.uiColor
            scene.moleculeCColor = input.moleculeC.color.uiColor
        }
    }
}
