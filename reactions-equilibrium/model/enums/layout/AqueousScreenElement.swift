//
// Reactions App
//

import Foundation

enum AqueousScreenElement {
    case quotientToConcentrationDefinition,
         quotientToEquilibriumConstantDefinition,
         chartEquilibrium,
         waterSlider,
         moleculeContainers,
         reactionDefinition,
         reactionToggle

    // These are actually on the integration screen, but in the interest of reusing the
    // aqueous view model, they are defined here
    case integrationRateDefinitions,
         integrationRateValues
}
