//
// Reactions App
//

import SwiftUI

struct SupportStudentsModalSettings {

    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }

    init(geometry: GeometryProxy) {
        self.init(width: geometry.size.width, height: geometry.size.height)
    }

    private let width: CGFloat
    private let height: CGFloat

    var modalSize: CGSize {
        CGSize(width: modalWidth, height: modalHeight)
    }

    var modalHeight: CGFloat {
        let maxHeight: CGFloat = 450
        return min(maxHeight, 0.95 * height)
    }

    var modalWidth: CGFloat {
        let maxWidth: CGFloat = 550
        return min(maxWidth, 0.8 * width)
    }

    var shareModalWidth: CGFloat {
        let maxWidth: CGFloat = 450
        return min(maxWidth, 0.75 * width)
    }

    var mainContentWidth: CGFloat {
        modalWidth - (2 * cornerRadius)
    }

    var mainContentScrollViewHPadding: CGFloat {
        (modalWidth - mainContentWidth) * 0.2
    }

    var tipSliderSize: CGSize {
        CGSize(
            width: 0.9 * mainContentWidth,
            height: 0.1 * modalHeight
        )
    }

    var cornerRadius: CGFloat {
        0.06 * modalHeight
    }

    var vSpacing: CGFloat {
        0.03 * modalHeight
    }

    var bannerHeight: CGFloat {
        0.35 * modalHeight
    }

    var headingHeight: CGFloat {
        0.15 * modalHeight
    }

    var hyperLearningImageSize: CGSize {
        CGSize(
            width: mainContentWidth,
            height: 0.8 * bannerHeight
        )
    }

    var supportButtonSize: CGSize {
        CGSize(
            width: 0.25 * mainContentWidth,
            height: tippingButtonsHeight
        )
    }

    var extraTipSize: CGSize {
        CGSize(
            width: 0.35 * mainContentWidth,
            height: tippingButtonsHeight
        )
    }

    var skipButtonSize: CGSize {
        CGSize(
            width: 0.2 * mainContentWidth,
            height: tippingButtonsHeight
        )
    }

    var tippingButtonsCornerRadius: CGFloat {
        0.5 * cornerRadius
    }

    var tippingButtonsFontSize: CGFloat {
        0.55 * tippingButtonsHeight
    }

    var tipAmountLabelHeight: CGFloat {
        0.75 * tippingButtonsHeight
    }

    private var tippingButtonsHeight: CGFloat {
        0.3 * bannerHeight
    }
}
