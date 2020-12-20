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
        // The button is scaled by 2 to increase the touch target, as it's a little small otherwise.
        // The button body must be scaled by 0.5 to return it to its original size
        Button(action: action) {
            ZStack {
                VStack(spacing: size / 5) {
                    line(size: size)
                    line(size: size)
                    line(size: size)
                }
                .frame(width: size, height: size)
                .border(Color.black)
                .foregroundColor(.black)
                .background(Color.white)
                .scaleEffect(0.5)
            }
        }.scaleEffect(2)
    }

    private func line(size: CGFloat) -> some View {
        Rectangle()
            .frame(width: 0.65 * size, height: max(size * 0.02, 1))
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MenuButton(action: {})
            .frame(width: 50, height: 50)
    }
}
