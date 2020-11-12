//
// Reactions App
//
  

import SwiftUI

struct EquationPlaceholderView: View {

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .stroke(style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .square,
                            lineJoin: .round,
                            miterLimit: 0,
                            dash: dash(geometry),
                            dashPhase: dashPhase(geometry)
                        )
                )
        }
    }

    private func dash(_ geometry: GeometryProxy) -> [CGFloat] {
        let phase = dashPhase(geometry)
        return [2 * phase, phase]
    }

    private func dashPhase(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 6
    }
}

struct EquationPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        EquationPlaceholderView()
    }
}
