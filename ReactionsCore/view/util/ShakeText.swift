//
// Reactions App
//

import SwiftUI

public struct ShakeText: View {

    public init() { }

    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.up.fill")
            Text("shake")
            Image(systemName: "arrowtriangle.down.fill")
        }
        .foregroundColor(.darkGray)
        .accessibility(hidden: true)
    }
}

struct ShakeText_Previews: PreviewProvider {
    static var previews: some View {
        ShakeText()
    }
}
