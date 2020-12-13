//
// Reactions App
//
  

import SwiftUI

struct MenuButton: View {

    let action: () -> Void

    var body: some View {
        GeometryReader { geo in
            makeView(size: min(geo.size.width, geo.size.height))
        }
    }

    private func makeView(size: CGFloat) -> some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .stroke(lineWidth: size * 0.02)

                VStack(spacing: size / 5) {
                    line(size: size)
                    line(size: size)
                    line(size: size)
                }
            }.frame(width: size, height: size)
        }
        .foregroundColor(.black)
    }

    private func line(size: CGFloat) -> some View {
        Rectangle()
            .frame(width: 0.65 * size, height: size * 0.02)
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MenuButton(action: {})
            .frame(width: 50, height: 50)
    }
}
