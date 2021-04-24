//
// Reactions App
//


import SwiftUI

struct AnimatingDoubleSidedArrow: View {

    let topHighlight: Color?
    let bottomHighlight: Color?
    let width: CGFloat

    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: 2) {
            imageStack
                .foregroundColor(topHighlight ?? .black)
                .offset(x: offset)
            imageStack
                .foregroundColor(bottomHighlight ?? .black)
                .rotationEffect(.degrees(180))
                .offset(x: -offset)
        }
        .frame(width: width)
        .onAppear {
            let animation = Animation.linear(duration: 0.75).repeatForever(autoreverses: false)
            withAnimation(animation) {
                offset = width
            }
        }
        .clipped()
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

struct DoubleSidedArrow: View {

    let topHighlight: Color?
    let reverseHighlight: Color?

    var body: some View {
        VStack(spacing: 2) {
            image
                .foregroundColor(topHighlight ?? .black)
            image
                .foregroundColor(reverseHighlight ?? .black)
                .rotationEffect(.degrees(180))
        }
    }

    private var image: some View {
        Image("top-right-harpoon")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct DoubleSidedArrow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text("2A + 3B")
                DoubleSidedArrow(topHighlight: nil, reverseHighlight: .orangeAccent)
                    .frame(width: 40)
            }
            HStack {
                Text("2A + 3B")
                AnimatingDoubleSidedArrow(
                    topHighlight: nil,
                    bottomHighlight: .orangeAccent,
                    width: 40
                )
                .frame(width: 40)
            }

        }
        .font(.system(size: 30))
    }
}
