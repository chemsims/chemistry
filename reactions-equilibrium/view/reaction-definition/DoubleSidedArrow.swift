//
// Reactions App
//


import SwiftUI

struct DoubleSidedArrow: View {

    let topHighlight: Color?
    let reverseHighlight: Color?

    var body: some View {
        VStack(spacing: 2) {
            Image("top-right-harpoon")
                .foregroundColor(topHighlight ?? .black)
            Image("top-right-harpoon")
                .foregroundColor(reverseHighlight ?? .black)
                .rotationEffect(.degrees(180))

        }
    }
}

struct DoubleSidedArrow_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Text("2A + 3B")
            DoubleSidedArrow(topHighlight: nil, reverseHighlight: .orangeAccent)
        }
        .font(.system(size: 30))
    }
}
