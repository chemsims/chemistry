//
// Reactions App
//

import SwiftUI

public struct CircleIconButton: View {

    let action: () -> Void
    let systemImage: String
    let background: Color
    let border: Color
    let foreground: Color

    public init(
        action: @escaping () -> Void,
        systemImage: String,
        background: Color,
        border: Color,
        foreground: Color
    ) {
        self.action = action
        self.systemImage = systemImage
        self.background = background
        self.border = border
        self.foreground = foreground
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                GeometryReader { geo in
                    Circle()
                        .fill(background)

                    Circle()
                        .stroke(border)
                        .foregroundColor(foreground)
                        .overlay(
                            Image(systemName: systemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(foreground)
                                .padding(geo.size.width / 3)
                        )
                }
            }
        }.buttonStyle(NavButtonButtonStyle())
    }
}
