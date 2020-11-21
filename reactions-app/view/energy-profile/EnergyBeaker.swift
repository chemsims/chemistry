//
// Reactions App
//
  

import SwiftUI

struct EnergyBeaker: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                FilledBeaker(
                    moleculesA: [],
                    moleculesB: [],
                    moleculeBOpacity: 0
                ).frame(height: geometry.size.height / 1.5)
                beakerStand(geometry: geometry)
                slider(geometry: geometry)
            }
        }
    }

    private func beakerStand(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(height: 0.2 * geometry.size.height)
    }

    private func slider(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(height: 0.05 * geometry.size.height)

    }
}

struct EnergyBeaker_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBeaker()
    }
}
