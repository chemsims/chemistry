//
// Reactions App
//

import Foundation

public enum Orientation {
    case landscape, portrait
    
    var sliderOrientation: SliderOrientation {
        switch self {
        case .landscape:
            return .landscape
        case .portrait:
            return .portrait
        }
    }
}
