//
// Reactions App
//
  

import CoreGraphics

extension CGFloat {
    func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }

    func rounded(decimals: Int) -> CGFloat {
        let power = pow(10, CGFloat(decimals))
        let multiplied = self * power
        let rounded = multiplied.rounded()
        return rounded / power
    }
}
