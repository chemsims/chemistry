//
// Reactions App
//

import SwiftUI
import UIKit

public struct PageViewController<Page: View>: UIViewControllerRepresentable {

    public init(pages: [Page], currentPage: Binding<Int>) {
        self.pages = pages
        self._currentPage = currentPage
    }

    var pages: [Page]
    @Binding var currentPage: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.backgroundColor = .clear
        return controller
    }

    public func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let visibleViewController = pageViewController.viewControllers?.first
        let visibleIndex = visibleViewController.flatMap { context.coordinator.controllers.firstIndex(of: $0) }
        let direction: UIPageViewController.NavigationDirection = (visibleIndex ?? currentPage) < currentPage ? .forward : .reverse
        pageViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]],
            direction: direction,
            animated: !reduceMotion
        )
    }

    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        var parent: PageViewController
        var controllers = [UIViewController]()

        init(_ pageViewController: PageViewController) {
            parent = pageViewController
            controllers = parent.pages.map { UIHostingController(rootView: $0) }
            controllers.forEach { c in
                c.view.backgroundColor = .clear
            }
        }

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index > 0 else {
                return nil
            }
            return controllers[index - 1]
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index + 1 < controllers.count else {
                return nil
            }
            return controllers[index + 1]
        }

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}

private extension UIView {
    func removeAllBackgroundColors() {
        self.backgroundColor = .clear
        self.subviews.forEach { v in
            v.removeAllBackgroundColors()
        }
    }
}
