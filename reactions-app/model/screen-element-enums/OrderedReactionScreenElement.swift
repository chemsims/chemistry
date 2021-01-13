//
// Reactions App
//
  

import Foundation

enum OrderedReactionScreenElement: CaseIterable {
    case rateConstantEquation,
         halfLifeEquation,
         concentrationChart,
         secondaryChart,
         rateEquation,
         rateCurveLhs,
         rateCurveRhs,
         concentrationTable,
         reactionToggle
}

extension Array where Element == OrderedReactionScreenElement {
    static let charts: [OrderedReactionScreenElement] = [.concentrationChart, .secondaryChart]
}
