//
// Reactions App
//

import SwiftUI

public struct FixedText: View {

    let value: String
    public init(_ value: String) {
        self.value = value
    }

    public var body: some View {
        Text(value)
            .fixedSize()
    }
}

struct FixedText_Previews: PreviewProvider {
    static var previews: some View {
        FixedText("hello, world")
    }
}
