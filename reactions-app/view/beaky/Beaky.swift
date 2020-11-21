//
// Reactions App
//
  

import SwiftUI

struct Beaky: View {
    var body: some View {
        Image("beaky")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct Beaky_Previews: PreviewProvider {
    static var previews: some View {
        Beaky()
    }
}
