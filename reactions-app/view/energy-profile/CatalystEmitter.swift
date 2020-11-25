//
// Reactions App
//
  

import SpriteKit
import SwiftUI

struct CatalystEmitterView: UIViewRepresentable {

    let width: CGFloat
    let height: CGFloat
    let emitterPosition: CGPoint

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = CatalystEmitter()
        scene.emitterPosition = emitterPosition
        scene.size = CGSize(width: width, height: height)
        view.presentScene(scene)
        view.allowsTransparency = true
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {

    }
}


class CatalystEmitter: SKScene {

    private var emitter: SKEmitterNode?

    var emitterPosition: CGPoint?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .clear
        if let emitter = SKEmitterNode(fileNamed: "CatalystParticles"),
           let position = emitterPosition {
            self.emitter = emitter

            print("Frame bounds: \(self.frame)")
            print("Point: \(position)")

            emitter.position = position
            addChild(emitter)
        }
    }

}
