//
// Reactions App
//
  

import SwiftUI

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let leadingPadding: CGFloat
    let navigation: RootNavigationViewModel

    var body: some View {
        GeometryReader { geo in
            MainMenuOverlayWithSettings(
                navigation: navigation,
                settings: MainMenuLayoutSettings(
                    geometry: geo,
                    menuSize: size,
                    topPadding: topPadding,
                    leadingPadding: leadingPadding
                )
            )
        }
    }
}

fileprivate struct MainMenuOverlayWithSettings: View {

    let navigation: RootNavigationViewModel
    let settings: MainMenuLayoutSettings

    @State private var showPanel: Bool = false
    @State private var extraOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {
            icon
            panel
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { gesture in
                            extraOffset = min(0, gesture.translation.width)
                        }.onEnded { _ in
                            toggleMenu()
                            extraOffset = 0
                        }
                )
                .offset(
                    x: showPanel ? 0 + extraOffset : -settings.totalMenuWidth - (settings.panelBorder / 2)
                )
                .edgesIgnoringSafeArea(.all)
        }
    }

    private var icon: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                MenuButton(action: toggleMenu)
                    .frame(width: settings.menuSize, height: settings.menuSize)
                    .padding(.top, settings.topPadding)
                    .padding(.leading, settings.leadingPadding)
                Spacer()
            }
            Spacer()
        }
    }

    private var panel: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
                .frame(width: settings.leadingPanelSpace)
            panelContent
            grabHandle
        }
        .background(panelBackground)
        .compositingGroup()
        .shadow(radius: showPanel ? 3 : 0)
    }

    private var grabHandle: some View {
        VStack(spacing: 3) {
            grabLine
            grabLine
            grabLine
        }
        .frame(width: settings.menuSize, height: settings.menuSize)
        .padding(settings.leadingPadding)
        .foregroundColor(.black)
    }

    private var grabLine: some View {
        Rectangle()
            .frame(
                width: settings.grabLineWidth,
                height: settings.grabLineHeight
            )
    }

    private var panelContent: some View {
        VStack {
            Spacer()
                .frame(height: settings.tabHeight / 2)
            navIcon(image: "zeroordericon", action: navigation.goToZeroOrder)
            navIcon(image: "firstordericon", action: navigation.goToFirstOrder)
            navIcon(image: "secondordericon", action: navigation.goToSecondOrder)
            navIcon(image: "comparisonicon", action: navigation.goToComparison)
            navIcon(image: "kineticsicon", action: navigation.goToEnergyProfile)
        }
        .frame(width: settings.panelWidth)
    }

    private var panelBackground: some View {
        ZStack {
            panelShape
                .fill()
                .foregroundColor(Styling.menuPanel)

            panelShape
                .stroke(lineWidth: settings.panelBorder)
        }
    }

    private var panelShape: some Shape {
        MainMenuPanel(
            panelWidthFraction: settings.panelWidthFraction,
            panelHeightFraction: settings.panelHeightFraction,
            cornerRadius: 0.5 * settings.menuSize
        )
    }

    private func navIcon(image: String, action: @escaping () -> Void) -> some View {
        Button(action: goToScreen(action: action)) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(0.2 * settings.menuSize)
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
}

fileprivate struct MainMenuLayoutSettings {
    let geometry: GeometryProxy
    let menuSize: CGFloat
    let topPadding: CGFloat
    let leadingPadding: CGFloat

    var height: CGFloat {
        geometry.size.height
    }

    var grabLineWidth: CGFloat {
        0.6 * menuSize
    }

    var grabLineHeight: CGFloat {
        max(0.015 * menuSize, 1)
    }

    var panelWidth: CGFloat {
        2.2 * menuSize
    }

    var tabHeight: CGFloat {
        1.1 * (menuSize + (2 * topPadding))
    }

    var tabWidth: CGFloat {
        menuSize
    }

    var totalMenuWidth: CGFloat {
        panelWidth + tabWidth + (2 * leadingPadding) + leadingPanelSpace
    }

    var panelWidthFraction: CGFloat {
        (panelWidth + leadingPanelSpace) / totalMenuWidth
    }

    var panelHeightFraction: CGFloat {
        1 - (tabHeight / height)
    }

    var leadingPanelSpace: CGFloat {
        let leading = geometry.safeAreaInsets.leading
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft) {
            return leading
        }
        return leading / 2
    }

    var panelBorder: CGFloat {
        0.75
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
