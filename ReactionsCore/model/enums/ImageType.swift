//
// Reactions App
//

import Foundation

public enum ImageType {

    /// Image provided by framework
    case framework(_ name: String, bundle: Bundle?)

    /// Image provided by the core framework
    case core(_ name: CoreImage)

    /// System provided image
    case system(_ name: String)
}

public enum CoreImage {
    case quizIcon
    case quizIconSelected
    case filingCabinet
    case filingCabinetSelected
    case openHand
    case closedHand

    var name: String {
        switch self {
        case .quizIcon, .quizIconSelected: return "text-book-closed"
        case .filingCabinet, .filingCabinetSelected: return "archivebox-thinner"
        case .openHand: return "openhand"
        case .closedHand: return "closedhand"
        }
    }
}
