//
// Reactions App
//


import SwiftUI

struct PHScaleBar: View {

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    gradient: PHScaleColors.gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius(geo))
                )

                RoundedRectangle(cornerRadius: cornerRadius(geo))
                    .stroke()
            }
        }
    }

    private func cornerRadius(_ geo: GeometryProxy) -> CGFloat {
        geo.size.height * 0.1
    }
}

struct PHScaleBar_Previews: PreviewProvider {
    static var previews: some View {
        PHScaleBar()
            .previewLayout(.fixed(width: 400, height: 120))
            .padding()
    }
}
