//
// Reactions App
//

import SwiftUI

public struct DigitalScales: View {

    public init(
        label: String?,
        layout: DigitalScalesLayout,
        emphasise: Bool
    ) {
        self.label = label
        self.layout = layout
        self.emphasise = emphasise
    }

    let label: String?
    let layout: DigitalScalesLayout
    let emphasise: Bool

    public var body: some View {
        VStack(spacing: 0) {
            container
            display
        }
        .frame(width: layout.width, height: layout.height)
    }

    private let lightColor = Color.gray
    private let darkColor = Color.darkGray

    private var container: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .stroke(lineWidth: emphasise ? 2 : 1)
                .foregroundColor(emphasise ? .orangeAccent : lightColor)

            VStack(spacing: 0) {
                Rectangle()
                    .frame(size: layout.platformSize)
                    .foregroundColor(darkColor)

                Rectangle()
                    .frame(height: layout.containerBaseHeight)
                    .foregroundColor(lightColor)
            }
        }
        .frame(size: layout.containerSize)
    }

    private var display: some View {
        ZStack {
            RoundedRectangle(cornerRadius: layout.displayCornerRadius)
                .foregroundColor(darkColor)

            displayText
        }
        .frame(height: layout.displayHeight)
    }

    private var displayText: some View {
        ZStack {
            RoundedRectangle(cornerRadius: layout.displayTextFrameCornerRadius)
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: layout.displayTextFrameCornerRadius)
                .stroke()
                .foregroundColor(lightColor)

            if let label = label {
                Text(label)
                    .font(.system(size: layout.fontSize))
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(size: layout.displayTextFrameSize)
    }
}

public struct DigitalScalesLayout {

    public init(width: CGFloat) {
        self.width = width
        self.height = Self.idealHeightToWidth * width
    }

    public let width: CGFloat
    public let height: CGFloat

    var containerSize: CGSize {
        CGSize(width: 0.8 * width, height: 0.7 * height)
    }

    var containerBaseHeight: CGFloat {
        0.06 * containerSize.height
    }

    var platformSize: CGSize {
        CGSize(
            width: 0.4 * containerSize.width,
            height: 0.06 * containerSize.height
        )
    }

    var displayHeight: CGFloat {
        height - containerSize.height
    }

    var displayCornerRadius: CGFloat {
        0.25 * displayHeight
    }

    var displayTextFrameSize: CGSize {
        CGSize(
            width: 0.65 * width,
            height: 0.6 * displayHeight
        )
    }

    var displayTextFrameCornerRadius: CGFloat {
        0.1 * displayTextFrameSize.height
    }

    var fontSize: CGFloat {
        0.75 * displayTextFrameSize.height
    }

    static let idealHeightToWidth: CGFloat = 1
}

extension DigitalScalesLayout {

    /// Returns the top of the weighing area, as measured from the top of the frame
    public var topOfWeighingArea: CGFloat {
        containerSize.height - containerBaseHeight - platformSize.height
    }
}

struct DigitalScales_Previews: PreviewProvider {
    static var previews: some View {
        DigitalScales(
            label: "1.0 g",
            layout: .init(width: 300),
            emphasise: true
        )
    }
}
