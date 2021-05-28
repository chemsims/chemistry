//
// Reactions App
//

import SwiftUI

public struct Beaky: View {

    public init() { }

    public var body: some View {
        Image("beaky", bundle: Bundle.reactionsCore, label: Text("test tube with a smiling face"))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    static let widthToHeight: CGFloat = 0.542
}

struct Beaky_Previews: PreviewProvider {
    static var previews: some View {
        Beaky()
    }
}
