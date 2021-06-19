//
// Reactions App
//


import SwiftUI

struct TitrationPhChart: View {

    let layout: TitrationScreenLayout

    var body: some View {
        Rectangle()
            .stroke()
            .frame(square: layout.common.chartSize)
    }
}

