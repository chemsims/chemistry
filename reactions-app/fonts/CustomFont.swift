//
// Reactions App
//

import SwiftUI

struct CustomFont: View {
    var body: some View {
        Text("Hello, world!")
            .font(.roboto(size: 20))
    }
}

extension Font {
    static func roboto(size: CGFloat) -> Font {
        Font.custom("Roboto Slab", size: size)
    }
}

struct CustomFont_Previews: PreviewProvider {
    static var previews: some View {
        CustomFont()
    }
}
