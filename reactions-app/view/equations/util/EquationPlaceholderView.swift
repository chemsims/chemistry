//
// Reactions App
//


import SwiftUI

struct DefaultPlaceholder: View {
    let settings: EquationGeometrySettings

    var body: some View {
        EquationPlaceholderView()
            .padding(settings.boxPadding)
            .frame(width: settings.boxWidth, height: settings.boxWidth)
    }
}

func termOrBox(_ term: String?, settings: EquationGeometrySettings) -> some View {
    if let term = term {
        return AnyView(Text(term))
    }
    return AnyView(DefaultPlaceholder(settings: settings))
}

struct EquationPlaceholderView: View {

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .stroke(style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .square,
                            lineJoin: .round,
                            miterLimit: 0,
                            dash: dash(geometry),
                            dashPhase: dashPhase(geometry)
                        )
                )
        }
    }

    private func dash(_ geometry: GeometryProxy) -> [CGFloat] {
        let phase = dashPhase(geometry)
        return [2 * phase, phase]
    }

    private func dashPhase(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 6
    }
}


