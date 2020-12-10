//
// Reactions App
//
  

import SwiftUI

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let leadingPadding: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                MenuButton(
                    action: {}
                )
                .frame(width: size, height: size)
                .padding(.top, topPadding)
                .padding(.leading, leadingPadding)

                Spacer()
            }
            Spacer()
        }
    }
}

struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            size: 50,
            topPadding: 10,
            leadingPadding: 10
        )
    }
}
