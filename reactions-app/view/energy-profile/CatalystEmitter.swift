//
// Reactions App
//
  

import SpriteKit
import SwiftUI

struct CatalystEmitterView: UIViewRepresentable {

    let width: CGFloat
    let height: CGFloat
    let emitterPosition: CGPoint
    let emitting: Bool
    let color: UIColor

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = CatalystEmitterScene()
        scene.emitterPosition = emitterPosition
        scene.size = CGSize(width: width, height: height)
        view.presentScene(scene)
        view.allowsTransparency = true
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? CatalystEmitterScene {
            scene.emitting = emitting
            scene.particleColor = color
        }
    }
}


class CatalystEmitterScene: SKScene {

    private var emitter: SKEmitterNode?

    var emitterPosition: CGPoint?
    var emitting: Bool = false {
        didSet {
            if let emitter = emitter {
                emitter.particleBirthRate = emitting ? birthRate : 0
            }
        }
    }
    var particleColor: UIColor? {
        didSet {
            if let emitter = emitter {
                emitter.particleColor = particleColor ?? .black
            }
        }
    }

    private let birthRate: CGFloat = 10

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .clear
        if let emitter = SKEmitterNode(fileNamed: "CatalystParticles"),
           let position = emitterPosition {
            self.emitter = emitter
            emitter.position = position
            emitter.particleBirthRate = emitting ? birthRate : 0
            emitter.particleColorSequence = nil
            emitter.particleColor = particleColor ?? .red
            emitter.particleSize = CGSize(width: size.width * 0.04, height: size.width * 0.04)
            addChild(emitter)
        }
    }
}
