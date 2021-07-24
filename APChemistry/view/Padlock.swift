//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct Padlock: View {
    var body: some View {
        image
            .overlay(gradient.mask(image))
    }

    private var gradient: some View {
        LinearGradient(
            gradient: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var colors: Gradient {
        Gradient(colors: [
            lockOuter,
            lockInner,
            lockOuter
        ])
    }

    private var image: some View {
        Image(systemName: "lock.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private let lockOuter = RGB(r: 221, g: 177, b: 51).color
    private let lockInner = RGB(r: 238, g: 212, b: 87).color
}

struct Padlock_Previews: PreviewProvider {
    static var previews: some View {
        Padlock()
            .font(.system(size: 200))
    }
}
