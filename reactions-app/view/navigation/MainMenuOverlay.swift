//
// Reactions App
//
  

import SwiftUI

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let leadingPadding: CGFloat

    @State private var showPanel: Bool = false

    let navigation =
        RootNavigationViewModel(
            persistence: InMemoryReactionInputPersistence()
        )

    var body: some View {
        ZStack(alignment: .leading) {
            icon

            if (showPanel) {
                panel
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        )
                    )
                    .animation(.easeOut)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private var icon: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                MenuButton(action: toggleMenu)
                .frame(width: size, height: size)
                .padding(.top, topPadding)
                .padding(.leading, leadingPadding)

                Spacer()
            }
            Spacer()
        }
    }

    private var panel: some View {
        HStack(alignment: .top) {
            VStack {
                Spacer()
                navIcon(image: "zeroordericon", action: {})
                navIcon(image: "zeroordericon", action: {})
                navIcon(image: "zeroordericon", action: {})
                navIcon(image: "zeroordericon", action: {})
                navIcon(image: "zeroordericon", action: {})
            }
            .frame(width: 2 * size)

            MenuButton(action: toggleMenu)
                .frame(width: size, height: size)
                .padding(.horizontal, leadingPadding)
        }
        .padding(.top, topPadding)
        .padding(.leading, leadingPadding)
        .background(RGB(r: 230, g: 230, b: 230).color)
    }

    private func navIcon(image: String, action: () -> Void) -> some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(0.2 * size)
    }

    private func toggleMenu() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPanel.toggle()
        }
    }
}

struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            size: 50,
            topPadding: 10,
            leadingPadding: 10
        )
    }
}
