//
// Reactions App
//
  

import SwiftUI
import SpriteKit


struct MoleculeEneregyUIViewRepresentable: UIViewRepresentable {

    typealias UIViewType = SKView

    let width: CGFloat
    let height: CGFloat
    let scene = MoleculeEnergyScene()

    func makeUIView(context: Context) -> SKView {
        SKView()
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        scene.size = CGSize(width: width, height: height)
        scene.scaleMode = .aspectFit
        uiView.presentScene(scene)
    }
}



struct MoleculeEnergyUIViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeEneregyUIViewRepresentable(width: 300, height: 300)
            .frame(width: 300, height: 200)
            .border(Color.black)
    }
}
