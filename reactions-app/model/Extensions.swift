//
// Reactions App
//
  

import Foundation

extension Double {
    func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }
}
