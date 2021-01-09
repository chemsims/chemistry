//
// Reactions App
//
  

import SwiftUI

struct QuizLayoutSettings {
    let geometry: GeometryProxy

    var width: CGFloat {
        geometry.size.width
    }

    var progressWidth: CGFloat {
        0.8 * geometry.size.width
    }

    var contentWidth: CGFloat {
        geometry.size.width - (2 * navTotalWidth)
    }

    var progressHeight: CGFloat {
        0.03 * geometry.size.height
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

    var h2FontSize: CGFloat {
        0.7 * fontSize
    }

    var progressFontSize: CGFloat {
        0.6 * fontSize
    }

    var progressLabelWidth: CGFloat {
        6 * progressHeight
    }

    var navPadding: CGFloat {
        0.5 * navSize
    }

    var navTotalWidth: CGFloat {
        navSize + (2 * navPadding)
    }

    var progressBarPadding: CGFloat {
        0.4 * navSize
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

    var questionReviewPadding: CGFloat {
        2
    }

    var tableWidthReviewCard: CGFloat {
        0.95 * tableWidthQuestionCard
    }

    var tableWidthQuestionCard: CGFloat {
        contentWidth
    }
}
