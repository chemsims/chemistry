//
// Reactions App
//
  

import SwiftUI

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let leadingPadding: CGFloat
    let navigation: RootNavigationViewModel

    @State private var showPanel: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                icon

                panel(height: geo.size.height)
                    .offset(x: showPanel ? 0 : -totalMenuWidth)
            }
            .edgesIgnoringSafeArea(.all)
        }
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

    private func panel(height: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 0) {
            panel2(height: height)
            grabHandle
        }
        .background(panelBackground(height: height))
        .compositingGroup()
        .shadow(radius: 3)
    }

    private var grabHandle: some View {
        Button(action: toggleMenu) {
            VStack(spacing: 3) {
                grabLine
                grabLine
                grabLine
            }
            .frame(width: size, height: size)
            .padding(leadingPadding)
            .foregroundColor(.black)
        }
    }

    private var grabLine: some View {
        Rectangle()
            .frame(width: 0.6 * size, height: max(0.015 * size, 1))
    }


    private func panel2(height: CGFloat) -> some View {
        VStack {
            Spacer()
                .frame(height: tabHeight / 2)
            navIcon(image: "zeroordericon", action: navigation.goToZeroOrder)
            navIcon(image: "firstordericon", action: navigation.goToFirstOrder)
            navIcon(image: "secondordericon", action: navigation.goToSecondOrder)
            navIcon(image: "comparisonicon", action: navigation.goToComparison)
            navIcon(image: "kineticsicon", action: navigation.goToEnergyProfile)
        }
        .frame(width: panelWidth)
    }

    private func panelBackground(height: CGFloat) -> some View {
        ZStack {
            panelShape(height: height)
                .fill()
                .foregroundColor(Styling.menuPanel)

            panelShape(height: height)
                .stroke(lineWidth: 0.75)
        }
    }

    private func panelShape(height: CGFloat) -> some Shape {
        MainMenuPanel(
            panelWidthFraction: panelWidth / totalMenuWidth,
            panelHeightFraction: 1 - (tabHeight / height),
            cornerRadius: 0.5 * size
        )
    }

    private func navIcon(image: String, action: @escaping () -> Void) -> some View {
        Button(action: goToScreen(action: action)) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(0.2 * size)
        }
    }

    private func goToScreen(action: @escaping () -> Void) -> () -> Void {
        {
            action()
            toggleMenu()
        }
    }

    private func toggleMenu() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPanel.toggle()
        }
    }

    private var panelWidth: CGFloat {
        2.2 * size
    }

    private var tabWidth: CGFloat {
        size
    }

    private var totalMenuWidth: CGFloat {
        panelWidth + tabWidth + (2 * leadingPadding)
    }

    private var tabHeight: CGFloat {
        1.1 * (size + (2 * topPadding))
    }
}

struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            size: 50,
            topPadding: 10,
            leadingPadding: 10,
            navigation: RootNavigationViewModel(
                persistence: InMemoryReactionInputPersistence()
            )
        )
    }
}
