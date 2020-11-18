//
// Reactions App
//
  

import SwiftUI

struct RootNavigationView: View {

    @ObservedObject var model: RootNavigationViewModel

    var body: some View {
        model.view
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView(model: RootNavigationViewModel())
    }
}
