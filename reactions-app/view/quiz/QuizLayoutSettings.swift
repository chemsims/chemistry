//
// Reactions App
//
  

import SwiftUI

struct QuizLayoutSettings {
    let geometry: GeometryProxy

    var progressWidth: CGFloat {
        0.8 * geometry.size.width
    }

    var progressHeight: CGFloat {
        0.07 * geometry.size.height
    }

    var progressCornerRadius: CGFloat {
        0.01 * geometry.size.height
    }

    var navSize: CGFloat {
        0.05 * geometry.size.width
    }

    var questionFontSize: CGFloat {
        0.05 * geometry.size.height
    }

    var answerFontSize: CGFloat {
        0.9 * questionFontSize
    }

    var fontSize: CGFloat {
        0.04 * geometry.size.width
    }

    var progressFontSize: CGFloat {
        0.7 * fontSize
    }

    var progressLabelWidth: CGFloat {
        0.1 * progressWidth
    }

    var navPadding: CGFloat {
        0.5 * navSize
    }

    var navTotalWidth: CGFloat {
        navSize + (2 * navPadding)
    }

    var progressBarPadding: CGFloat {
        navPadding
    }

    var activeLineWidth: CGFloat {
        3
    }

    var standardLineWidth: CGFloat {
        1
    }

    var maxImageHeight: CGFloat {
        0.8 * geometry.size.height
    }

    var retryIconWidth: CGFloat {
        progressHeight
    }

    var retryLabelWidth: CGFloat {
        2 * retryIconWidth
    }

    var retryPadding: CGFloat {
        0.1 * retryIconWidth
    }

    var retryLabelFontSize: CGFloat {
        0.8 * answerFontSize
    }

    var skipFontSize: CGFloat {
        0.55 * fontSize
    }

}
