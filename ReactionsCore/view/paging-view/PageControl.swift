//
// Reactions App
//

import SwiftUI

public struct PageControl: UIViewRepresentable {

    public init(
        pages: Int,
        currentPage: Binding<Int>,
        pageIndicatorColor: UIColor? = nil,
        currentPageIndicatorColor: UIColor? = nil
    ) {
        self.pages = pages
        self._currentPage = currentPage
        self.pageIndicatorColor = pageIndicatorColor
        self.currentPageIndicatorColor = currentPageIndicatorColor
    }

    var pages: Int
    @Binding var currentPage: Int
    var pageIndicatorColor: UIColor?
    var currentPageIndicatorColor: UIColor?

    public func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = pages
        control.currentPage = currentPage
        control.pageIndicatorTintColor = pageIndicatorColor
        control.currentPageIndicatorTintColor = currentPageIndicatorColor
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        return control
    }

    public func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = pages
        uiView.currentPage = currentPage
        uiView.pageIndicatorTintColor = pageIndicatorColor
        uiView.currentPageIndicatorTintColor = currentPageIndicatorColor
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject {

        init(_ control: PageControl) {
            self.control = control
        }

        var control: PageControl

        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageControl_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {
        @State var page = 0

        var body: some View {
            PageControl(
                pages: 2,
                currentPage: $page,
                pageIndicatorColor: .gray,
                currentPageIndicatorColor: .purple
            )
            .border(Color.red)
        }
    }
}
