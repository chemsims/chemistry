//
// Reactions App
//
  

import SwiftUI

struct FixedText: View {

    let value: String
    init(_ value: String) {
        self.value = value
    }

    var body: some View {
        Text(value)
            .fixedSize()
    }
}

struct FixedText_Previews: PreviewProvider {
    static var previews: some View {
        FixedText("hello, world")
    }
}
