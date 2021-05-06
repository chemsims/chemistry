//
// Reactions App
//

import SwiftUI

struct AnimatingDoubleSidedArrow: View {

    let width: CGFloat
    let direction: ReactionDefinitionArrowDirection

    private let duration: TimeInterval = 0.75

    var body: some View {
        Group {
            switch direction {
            case .equilibrium: AnimatingDoubleArrow(width: width, duration: duration)
            case .forward: topArrowRunning
            case .reverse: bottomArrowRunning
            default: DoubleArrow(width: width)
            }
        }
    }

    private var topArrowRunning: some View {
        ArrowStack(
            width: width,
            topArrow: SingleAnimatingArrow(width: width, isForward: true, duration: 0.75),
            bottomArrow: SingleArrow(width: width, offset: 0, isForward: false)
        )
    }

    private var bottomArrowRunning: some View {
        ArrowStack(
            width: width,
            topArrow: SingleArrow(width: width, offset: 0, isForward: true),
            bottomArrow: SingleAnimatingArrow(width: width, isForward: false, duration: 0.75)
        )
    }

}

fileprivate struct SingleAnimatingArrow: View {

    let width: CGFloat
    let isForward: Bool
    let duration: TimeInterval
    @State private var offset: CGFloat = 0

    var body: some View {
        SingleArrow(width: width, offset: offset, isForward: isForward)
            .foregroundColor(.orangeAccent)
            .onAppear {
                let animation = Animation.linear(duration: duration).repeatForever(autoreverses: false)
                withAnimation(animation) {
                    offset = width
                }
            }
    }
}

private struct AnimatingDoubleArrow: View {

    let width: CGFloat
    let duration: TimeInterval
    @State private var offset: CGFloat = 0

    var body: some View {
        ArrowStack(
            width: width,
            topArrow: SingleArrow(width: width, offset: offset, isForward: true),
            bottomArrow: SingleArrow(width: width, offset: offset, isForward: false)
        )
        .foregroundColor(.orangeAccent)
        .onAppear {
            let animation = Animation.linear(duration: duration).repeatForever(autoreverses: false)
            withAnimation(animation) {
                offset = width
            }
        }
    }
}

fileprivate struct DoubleArrow: View {

    let width: CGFloat

    var body: some View {
        ArrowStack(
            width: width,
            topArrow: SingleArrow(width: width, offset: 0, isForward: true),
            bottomArrow: SingleArrow(width: width, offset: 0, isForward: false)
        )
    }
}

private struct ArrowStack<TopArrow: View, BottomArrow: View>: View {
    let width: CGFloat
    let topArrow: TopArrow
    let bottomArrow: BottomArrow

    var body: some View {
        VStack(spacing: 2) {
            topArrow
            bottomArrow
        }
        .frame(width: width)
        .clipped()
    }
}

private struct SingleArrow: View {

    let width: CGFloat
    let offset: CGFloat
    let isForward: Bool

    var body: some View {
        imageStack
            .rotationEffect(isForward ? .zero : .degrees(180))
            .offset(x: isForward ? offset : -offset)
    }

    private var imageStack: some View {
        HStack(spacing: 0) {
            image
            image
        }
        .offset(x: -width / 2)
    }
    private var image: some View {
        Image("top-right-harpoon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
    }
}


struct DoubleSidedArrow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text("2A + 3B")
                AnimatingDoubleSidedArrow(
                    width: 40,
                    direction: .forward
                )
                .frame(width: 40)
            }
        }
            .font(.system(size: 30))
    }
}
