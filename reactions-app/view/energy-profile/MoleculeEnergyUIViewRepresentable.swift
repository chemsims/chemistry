//
// Reactions App
//
  

import SwiftUI
import SpriteKit


struct MoleculeEneregyUIViewRepresentable: UIViewRepresentable {

    typealias UIViewType = SKView

    let width: CGFloat
    let height: CGFloat
    let speed: CGFloat
    let updateConcentrationC: (CGFloat) -> Void

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = MoleculeEnergyScene()
        scene.size = CGSize(width: width, height: height)
        scene.updateConcentrationC = updateConcentrationC
        scene.scaleMode = .aspectFit
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? MoleculeEnergyScene {
            scene.extraSpeed = speed
        }
    }
}



struct MoleculeEnergyUIViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeEneregyUIViewRepresentable(
            width: 300,
            height: 300,
            speed: 0,
            updateConcentrationC: {_ in }
        )
        .frame(width: 300, height: 200)
        .border(Color.black)
    }
}
