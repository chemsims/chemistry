//
// Reactions App
//


import SwiftUI

struct TestView: View {

    @State private var showFirstImage = false

    var body: some View {
        Image(systemName: showFirstImage ? "checkmark.seal.fill" : "xmark.seal.fill")
            .resizable()
            .onTapGesture {
                withAnimation {
                    showFirstImage.toggle()
                }
            }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
