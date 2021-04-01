//
// Reactions App
//


import SwiftUI

struct PrimaryNextButton: View {

    let action: () -> Void

    var body: some View {
        GeometryReader { geo in
            PrimaryNextButtonWithGeometry(
                action: action,
                geometry: geo
            )
        }
    }
}

private struct PrimaryNextButtonWithGeometry: View {
    let action: () -> Void
    let geometry: GeometryProxy

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(NavButtonButtonStyle(scaleDelta: 0.02))
        .accessibility(label: Text("Next"))
    }

    private var content: some View {
        ZStack(alignment: .trailing) {
            pill
            iconWithText
        }
    }

    private var pill: some View {
        ZStack {
            PillShape()
                .foregroundColor(Styling.speechBubble)

            PillShape()
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(.orangeAccent)
        }

    }

    private var iconWithText: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: height / 2)
            Text("Next")
                .frame(width: width - (1.5 * height))
                .foregroundColor(.orangeAccent)
                .font(.system(size: fontSize, weight: .semibold))
                .minimumScaleFactor(0.5)
            icon
        }
        .frame(width: width)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .foregroundColor(.orangeAccent)

            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.speechBubble)
                .padding(iconPadding)
        }
        .frame(width: height, height: height)
    }
}

private extension PrimaryNextButtonWithGeometry {
    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    var lineWidth: CGFloat {
        0.08 * height
    }

    var iconPadding: CGFloat {
        0.3 * height
    }

    var fontSize: CGFloat {
        0.6 * height
    }
}


struct PrimaryNextButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNextButton(action: {})
            .frame(width: 200, height: 50)
    }
}
