//
// Reactions App
//
  

import SwiftUI
import SpriteKit


struct MoleculeEneregyUIViewRepresentable: UIViewRepresentable {

    typealias UIViewType = SKView

    let width: CGFloat
    let height: CGFloat
    let waterHeight: CGFloat
    let speed: CGFloat
    let updateConcentrationC: (CGFloat) -> Void
    let allowReactionsToC: Bool
    let emitterPosition: CGPoint
    let emitting: Bool
    let catalystColor: UIColor

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
            scene.allowReactionsToC = allowReactionsToC
            scene.emitting = emitting
            scene.catalystColor = catalystColor
        }
    }
}
