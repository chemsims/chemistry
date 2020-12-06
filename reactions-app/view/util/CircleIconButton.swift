//
// Reactions App
//
  

import SwiftUI

struct CircleIconButton: View {

    let action: () -> Void
    let systemImage: String
    let background: Color
    let border: Color
    let foreground: Color

    var body: some View {
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
