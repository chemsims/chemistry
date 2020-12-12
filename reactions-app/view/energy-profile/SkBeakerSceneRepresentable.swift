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
    let reactionHasStarted: Bool
    let emitterPosition: CGPoint
    let emitting: Bool
    let catalystColor: UIColor
    let canReactToC: Bool
    let reactionHasEnded: Bool

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = SKBeakerScene(
            size: CGSize(width: width, height: height),
            waterHeight: waterHeight,
            updateConcentrationC: updateConcentrationC,
            emitterPosition: emitterPosition,
            emitting: emitting,
            catalystColor: catalystColor
        )
        scene.scaleMode = .aspectFit
        view.allowsTransparency = true
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? SKBeakerScene {
            scene.extraSpeed = speed
            scene.reactionHasStarted = reactionHasStarted
            scene.reactionHasEnded = reactionHasEnded
            scene.emitting = emitting
            scene.catalystColor = catalystColor
            scene.canReactToC = canReactToC
        }
    }
}
