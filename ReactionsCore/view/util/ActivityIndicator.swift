//
// Reactions App
//

import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {

    public init(style: UIActivityIndicatorView.Style = .medium) {
        self.style = style
    }

    private let style: UIActivityIndicatorView.Style

    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
        uiView.style = style
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
